import 'package:cloud_firestore/cloud_firestore.dart';

class PopularityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calcule le score de popularité d'un plat
  /// Formule : (order_count * 10) + (rating * rating_count) + view_count + bonus_recency
  static double calculatePopularityScore(Map<String, dynamic> dishData) {
    final orderCount = (dishData['order_count'] ?? 0).toDouble();
    final rating = (dishData['rating'] ?? 0.0).toDouble();
    final ratingCount = (dishData['rating_count'] ?? 0).toDouble();
    final viewCount = (dishData['view_count'] ?? 0).toDouble();

    // Bonus pour les plats récemment commandés (dans les 7 derniers jours)
    double recencyBonus = 0.0;
    final lastOrdered = dishData['last_ordered'];
    if (lastOrdered != null) {
      final lastOrderedDate =
          lastOrdered is DateTime ? lastOrdered : lastOrdered.toDate();
      final daysSinceLastOrder =
          DateTime.now().difference(lastOrderedDate).inDays;
      if (daysSinceLastOrder <= 7) {
        recencyBonus = 50.0 -
            (daysSinceLastOrder *
                7.0); // Plus c'est récent, plus le bonus est élevé
      }
    }

    // Calcul du score final
    final score = (orderCount * 10.0) +
        (rating * ratingCount) +
        (viewCount * 0.1) +
        recencyBonus;
    return score;
  }

  /// Met à jour le compteur de commandes d'un plat
  static Future<void> incrementOrderCount(String dishId) async {
    try {
      await _firestore.collection('dishes').doc(dishId).update({
        'order_count': FieldValue.increment(1),
        'last_ordered': FieldValue.serverTimestamp(),
      });
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
    } catch (e) {
      print('❌ Erreur mise à jour compteur vues: $e');
    }
  }

  /// Met à jour le rating d'un plat
  static Future<void> updateRating(String dishId, double newRating) async {
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

        await _firestore.collection('dishes').doc(dishId).update({
          'rating': newAverageRating,
          'rating_count': newRatingCount,
        });

        print(
            '✅ Rating mis à jour pour le plat: $dishId - Nouveau rating: ${newAverageRating.toStringAsFixed(2)}');
      }
    } catch (e) {
      print('❌ Erreur mise à jour rating: $e');
    }
  }

  /// Recalcule et met à jour le score de popularité pour tous les plats
  static Future<void> updateAllPopularityScores() async {
    try {
      final dishesSnapshot = await _firestore.collection('dishes').get();

      for (final doc in dishesSnapshot.docs) {
        final dishData = doc.data();
        final popularityScore = calculatePopularityScore(dishData);

        await doc.reference.update({
          'popularity_score': popularityScore,
          'popularity_updated_at': FieldValue.serverTimestamp(),
        });
      }

      print(
          '✅ Scores de popularité mis à jour pour ${dishesSnapshot.docs.length} plats');
    } catch (e) {
      print('❌ Erreur mise à jour scores popularité: $e');
    }
  }
}
