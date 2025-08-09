import 'package:cloud_firestore/cloud_firestore.dart';

class DishPopularityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialise les champs de popularité pour un nouveau plat
  static Future<void> initializeDishPopularity(String dishId) async {
    try {
      await _firestore.collection('dishes').doc(dishId).update({
        'order_count': 0,
        'view_count': 0,
        'rating_count': 0,
        'last_ordered': null,
        'last_viewed': null,
        'popularity_score': 0.0,
      });
      print('✅ Champs de popularité initialisés pour le plat: $dishId');
    } catch (e) {
      print('❌ Erreur initialisation popularité: $e');
    }
  }

  /// Met à jour le compteur de commandes d'un plat
  static Future<void> incrementOrderCount(String dishId) async {
    try {
      final dishRef = _firestore.collection('dishes').doc(dishId);

      await dishRef.update({
        'order_count': FieldValue.increment(1),
        'last_ordered': FieldValue.serverTimestamp(),
      });

      // Recalculer le score de popularité
      await _updatePopularityScore(dishId);

      print('✅ Compteur de commandes mis à jour pour le plat: $dishId');
    } catch (e) {
      print('❌ Erreur mise à jour compteur commandes: $e');
    }
  }

  /// Met à jour le compteur de vues d'un plat
  static Future<void> incrementViewCount(String dishId) async {
    try {
      await _firestore.collection('dishes').doc(dishId).update({
        'view_count': FieldValue.increment(1),
        'last_viewed': FieldValue.serverTimestamp(),
      });

      // Recalculer le score de popularité (moins fréquent pour les vues)
      await _updatePopularityScore(dishId);
    } catch (e) {
      print('❌ Erreur mise à jour compteur vues: $e');
    }
  }

  /// Met à jour le rating d'un plat
  static Future<void> addRating(String dishId, double newRating) async {
    try {
      final dishDoc = await _firestore.collection('dishes').doc(dishId).get();

      if (dishDoc.exists) {
        final dishData = dishDoc.data()!;
        final currentRating = (dishData['rating'] ?? 0.0).toDouble();
        final currentRatingCount = (dishData['rating_count'] ?? 0).toInt();

        // Calcul de la nouvelle moyenne
        final totalRating = (currentRating * currentRatingCount) + newRating;
        final newRatingCount = currentRatingCount + 1;
        final newAverageRating = totalRating / newRatingCount;

        await dishDoc.reference.update({
          'rating': newAverageRating,
          'rating_count': newRatingCount,
        });

        // Recalculer le score de popularité
        await _updatePopularityScore(dishId);

        print(
            '✅ Rating mis à jour pour le plat: $dishId - Nouveau rating: ${newAverageRating.toStringAsFixed(2)}');
      }
    } catch (e) {
      print('❌ Erreur mise à jour rating: $e');
    }
  }

  /// Calcule et met à jour le score de popularité d'un plat
  static Future<void> _updatePopularityScore(String dishId) async {
    try {
      final dishDoc = await _firestore.collection('dishes').doc(dishId).get();

      if (dishDoc.exists) {
        final dishData = dishDoc.data()!;
        final popularityScore = _calculatePopularityScore(dishData);

        await dishDoc.reference.update({
          'popularity_score': popularityScore,
          'popularity_updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ Erreur mise à jour score popularité: $e');
    }
  }

  /// Calcule le score de popularité d'un plat
  static double _calculatePopularityScore(Map<String, dynamic> dishData) {
    final orderCount = (dishData['order_count'] ?? 0).toDouble();
    final viewCount = (dishData['view_count'] ?? 0).toDouble();
    final rating = (dishData['rating'] ?? 0.0).toDouble();
    final ratingCount = (dishData['rating_count'] ?? 0).toDouble();

    // Bonus pour les plats récemment commandés (dans les 7 derniers jours)
    double recencyBonus = 0.0;
    final lastOrdered = dishData['last_ordered'];
    if (lastOrdered != null) {
      final lastOrderedDate = lastOrdered is DateTime
          ? lastOrdered
          : (lastOrdered as Timestamp).toDate();
      final daysSinceLastOrder =
          DateTime.now().difference(lastOrderedDate).inDays;
      if (daysSinceLastOrder <= 7) {
        recencyBonus = 50.0 - (daysSinceLastOrder * 7.0);
      }
    }

    // Formule de calcul du score
    // order_count a plus de poids que les vues et ratings
    final score = (orderCount * 15.0) +
        (rating * ratingCount * 2.0) +
        (viewCount * 0.1) +
        recencyBonus;

    return score;
  }

  /// Initialise tous les plats existants avec les champs de popularité
  static Future<void> initializeAllExistingDishes() async {
    try {
      print(
          '🔥 Début initialisation des champs de popularité pour tous les plats...');

      final dishesSnapshot = await _firestore.collection('dishes').get();
      int updatedCount = 0;

      for (final doc in dishesSnapshot.docs) {
        final dishData = doc.data();
        bool needsUpdate = false;
        Map<String, dynamic> updateData = {};

        // Vérifier et ajouter les champs manquants
        if (!dishData.containsKey('order_count')) {
          updateData['order_count'] = 0;
          needsUpdate = true;
        }

        if (!dishData.containsKey('view_count')) {
          updateData['view_count'] = 0;
          needsUpdate = true;
        }

        if (!dishData.containsKey('rating_count')) {
          updateData['rating_count'] = 0;
          needsUpdate = true;
        }

        if (!dishData.containsKey('popularity_score')) {
          updateData['popularity_score'] = 0.0;
          needsUpdate = true;
        }

        if (needsUpdate) {
          await doc.reference.update(updateData);
          updatedCount++;
          print('✅ Plat initialisé: ${dishData['name']} (${doc.id})');
        }
      }

      print(
          '🔥 Initialisation terminée. $updatedCount plats mis à jour sur ${dishesSnapshot.docs.length}');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation: $e');
    }
  }

  /// Recalcule tous les scores de popularité
  static Future<void> recalculateAllPopularityScores() async {
    try {
      print('🔥 Recalcul de tous les scores de popularité...');

      final dishesSnapshot = await _firestore.collection('dishes').get();

      for (final doc in dishesSnapshot.docs) {
        await _updatePopularityScore(doc.id);
      }

      print('🔥 Recalcul terminé pour ${dishesSnapshot.docs.length} plats');
    } catch (e) {
      print('❌ Erreur lors du recalcul: $e');
    }
  }
}
