import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PromotionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Types de promotions
  static const String TYPE_DISH_DISCOUNT = 'dish_discount';
  static const String TYPE_ORDER_DISCOUNT = 'order_discount';
  static const String TYPE_DELIVERY_FREE = 'delivery_free';

  // Types de réduction
  static const String DISCOUNT_PERCENTAGE = 'percentage';
  static const String DISCOUNT_FIXED = 'fixed_amount';

  /// Récupérer toutes les promotions actives
  Future<List<Map<String, dynamic>>> getActivePromotions() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('promotions')
          .where('is_active', isEqualTo: true)
          .where('start_date', isLessThanOrEqualTo: now)
          .where('end_date', isGreaterThanOrEqualTo: now)
          .orderBy('priority', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des promotions: $e');
      return [];
    }
  }

  /// Récupérer les promotions applicables à un plat
  Future<List<Map<String, dynamic>>> getDishPromotions(String dishId) async {
    try {
      final promotions = await getActivePromotions();
      final List<Map<String, dynamic>> applicablePromotions = [];

      for (final promo in promotions) {
        // Vérifier si la promotion s'applique au plat
        final applicableDishes =
            promo['applicable_dishes'] as List<dynamic>? ?? [];
        final applicableCategories =
            promo['applicable_categories'] as List<dynamic>? ?? [];

        // Récupérer les infos du plat
        final dishDoc = await _firestore.collection('dishes').doc(dishId).get();
        if (!dishDoc.exists) continue;

        final dishData = dishDoc.data()!;
        final dishCategory = dishData['categorie'] as String?;
        final dishRestaurant = dishData['restaurant_id'] as String?;

        // Vérifier si le plat est dans la liste
        if (applicableDishes.contains(dishId)) {
          applicablePromotions.add(promo);
          continue;
        }

        // Vérifier si la catégorie est dans la liste
        if (applicableCategories.contains(dishCategory)) {
          applicablePromotions.add(promo);
          continue;
        }

        // Vérifier si le restaurant est dans la liste
        final applicableRestaurants =
            promo['applicable_restaurants'] as List<dynamic>? ?? [];
        if (applicableRestaurants.contains(dishRestaurant)) {
          applicablePromotions.add(promo);
        }
      }

      return applicablePromotions;
    } catch (e) {
      print('Erreur lors de la récupération des promotions du plat: $e');
      return [];
    }
  }

  /// Calculer le prix final d'un plat avec promotions
  Future<Map<String, dynamic>> calculateDishPrice(
      String dishId, double basePrice) async {
    try {
      final promotions = await getDishPromotions(dishId);
      double finalPrice = basePrice;
      double totalDiscount = 0;
      List<Map<String, dynamic>> appliedPromotions = [];

      for (final promo in promotions) {
        if (await _canApplyPromotion(promo)) {
          final discountAmount = _calculateDiscountAmount(
            basePrice,
            promo['discount_type'],
            promo['discount_value'],
            promo['max_discount'],
          );

          finalPrice -= discountAmount;
          totalDiscount += discountAmount;

          appliedPromotions.add({
            'promotion_id': promo['id'],
            'title': promo['title'],
            'discount_type': promo['discount_type'],
            'discount_value': promo['discount_value'],
            'discount_amount': discountAmount,
          });
        }
      }

      return {
        'original_price': basePrice,
        'final_price': finalPrice,
        'total_discount': totalDiscount,
        'discount_percentage':
            basePrice > 0 ? (totalDiscount / basePrice) * 100 : 0,
        'applied_promotions': appliedPromotions,
        'is_on_sale': appliedPromotions.isNotEmpty,
      };
    } catch (e) {
      print('Erreur lors du calcul du prix: $e');
      return {
        'original_price': basePrice,
        'final_price': basePrice,
        'total_discount': 0,
        'discount_percentage': 0,
        'applied_promotions': [],
        'is_on_sale': false,
      };
    }
  }

  /// Convertir une heure au format "HH:MM" en minutes
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  /// Vérifier si une promotion peut être appliquée
  Future<bool> _canApplyPromotion(Map<String, dynamic> promotion) async {
    try {
      // Vérifier les limites d'utilisation
      if (promotion['max_uses'] != null) {
        if (promotion['used_count'] >= promotion['max_uses']) return false;
      }

      // Vérifier les limites par utilisateur
      if (promotion['max_uses_per_user'] != null) {
        final user = _auth.currentUser;
        if (user != null) {
          final userPromoDoc = await _firestore
              .collection('user_promotions')
              .doc('${user.uid}_${promotion['id']}')
              .get();

          if (userPromoDoc.exists) {
            final usedCount = userPromoDoc.data()!['used_count'] ?? 0;
            if (usedCount >= promotion['max_uses_per_user']) return false;
          }
        }
      }

      // Vérifier les heures actives
      if (promotion['active_hours'] != null) {
        final now = DateTime.now();
        final startHour = promotion['active_hours']['start'] as String;
        final endHour = promotion['active_hours']['end'] as String;

        final currentTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

        // Convertir en minutes pour comparaison
        final currentMinutes = _timeToMinutes(currentTime);
        final startMinutes = _timeToMinutes(startHour);
        final endMinutes = _timeToMinutes(endHour);

        if (currentMinutes < startMinutes || currentMinutes > endMinutes)
          return false;
      }

      return true;
    } catch (e) {
      print('Erreur lors de la vérification de la promotion: $e');
      return false;
    }
  }

  /// Calculer le montant de la réduction
  double _calculateDiscountAmount(
    double basePrice,
    String discountType,
    double discountValue,
    double? maxDiscount,
  ) {
    double discountAmount = 0;

    if (discountType == DISCOUNT_PERCENTAGE) {
      discountAmount = (basePrice * discountValue) / 100;
    } else if (discountType == DISCOUNT_FIXED) {
      discountAmount = discountValue;
    }

    // Appliquer le plafond de réduction
    if (maxDiscount != null && discountAmount > maxDiscount) {
      discountAmount = maxDiscount;
    }

    // S'assurer que la réduction ne dépasse pas le prix de base
    if (discountAmount > basePrice) {
      discountAmount = basePrice;
    }

    return discountAmount;
  }

  /// Appliquer une promotion (incrémenter le compteur d'utilisation)
  Future<void> applyPromotion(String promotionId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Incrémenter le compteur global
      await _firestore.collection('promotions').doc(promotionId).update({
        'used_count': FieldValue.increment(1),
      });

      // Incrémenter le compteur utilisateur
      final userPromoRef = _firestore
          .collection('user_promotions')
          .doc('${user.uid}_$promotionId');

      await userPromoRef.set({
        'user_id': user.uid,
        'promotion_id': promotionId,
        'used_count': FieldValue.increment(1),
        'last_used': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erreur lors de l\'application de la promotion: $e');
    }
  }

  /// Créer une nouvelle promotion (pour l'admin)
  Future<void> createPromotion(Map<String, dynamic> promotionData) async {
    try {
      await _firestore.collection('promotions').add({
        ...promotionData,
        'used_count': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la création de la promotion: $e');
      rethrow;
    }
  }

  /// Mettre à jour une promotion
  Future<void> updatePromotion(
      String promotionId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('promotions').doc(promotionId).update({
        ...updates,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la promotion: $e');
      rethrow;
    }
  }

  /// Supprimer une promotion
  Future<void> deletePromotion(String promotionId) async {
    try {
      await _firestore.collection('promotions').doc(promotionId).delete();
    } catch (e) {
      print('Erreur lors de la suppression de la promotion: $e');
      rethrow;
    }
  }
}
