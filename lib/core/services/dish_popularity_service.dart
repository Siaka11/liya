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
        final popularityScore = calculatePopularityScore(dishData);

        await dishDoc.reference.update({
          'popularity_score': popularityScore,
          'popularity_updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ Erreur mise à jour score popularité: $e');
    }
  }

  /// Calcule le score de popularité d'un plat - MOYENNE SIMPLE ET COHÉRENTE (0-100)
  static double calculatePopularityScore(Map<String, dynamic> dishData) {
    final orderCount = (dishData['order_count'] ?? 0).toDouble();
    final viewCount = (dishData['view_count'] ?? 0).toDouble();
    final rating = (dishData['rating'] ?? 0.0).toDouble();
    final ratingCount = (dishData['rating_count'] ?? 0).toDouble();

    // CALCUL DE MOYENNE SIMPLE - Chaque composant sur 25 points (total = 100)

    // 1. Score des commandes (25 points max)
    // 1 commande = 5 points, plafonné à 25
    double orderScore = (orderCount * 5.0).clamp(0, 25);

    // 2. Score des vues (25 points max)
    // 1 vue = 0.5 point, plafonné à 25
    double viewScore = (viewCount * 0.5).clamp(0, 25);

    // 3. Score des ratings (25 points max)
    // Rating moyen × 5, mais seulement si au moins 1 avis
    double ratingScore = 0.0;
    if (ratingCount > 0 && rating > 0) {
      ratingScore = (rating * 5.0).clamp(0, 25);
    }

    // 4. Score de récence (25 points max)
    // Bonus si commande récente (derniers 30 jours)
    double recencyScore = 0.0;
    final lastOrdered = dishData['last_ordered'];
    if (lastOrdered != null && orderCount > 0) {
      final lastOrderedDate = lastOrdered is DateTime
          ? lastOrdered
          : (lastOrdered as Timestamp).toDate();
      final daysSinceLastOrder =
          DateTime.now().difference(lastOrderedDate).inDays;

      if (daysSinceLastOrder <= 30) {
        // 25 points si commandé aujourd'hui, décroit linéairement
        recencyScore = (25.0 * (30 - daysSinceLastOrder) / 30).clamp(0, 25);
      }
    }

    // MOYENNE SIMPLE: addition des 4 composants
    final totalScore = orderScore + viewScore + ratingScore + recencyScore;

    // Score final entre 0 et 100
    return totalScore.clamp(0, 100);
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

  /// Recalcule tous les scores de popularité avec la formule unifiée
  static Future<void> recalculateAllPopularityScoresUnified() async {
    try {
      print('🔄 Recalcul unifié de tous les scores de popularité...');

      final dishesSnapshot = await _firestore.collection('dishes').get();
      int updatedCount = 0;

      for (final doc in dishesSnapshot.docs) {
        try {
          final dishData = doc.data();
          final newScore = calculatePopularityScore(dishData);

          await doc.reference.update({
            'popularity_score': newScore,
            'popularity_updated_at': FieldValue.serverTimestamp(),
          });

          updatedCount++;

          print(
              '✅ Score mis à jour: ${dishData['name']} - Nouveau score: ${newScore.toStringAsFixed(2)}/100');
        } catch (e) {
          print('❌ Erreur mise à jour plat ${doc.id}: $e');
        }
      }

      print(
          '✅ Recalcul terminé: $updatedCount plats mis à jour sur ${dishesSnapshot.docs.length}');
    } catch (e) {
      print('❌ Erreur recalcul global des scores: $e');
    }
  }

  /// Réinitialise toutes les données de popularité à zéro (supprime les valeurs par défaut)
  static Future<void> resetAllPopularityToZero() async {
    try {
      print(
          '🔄 Réinitialisation de toutes les données de popularité à zéro...');

      final dishesSnapshot = await _firestore.collection('dishes').get();
      int resetCount = 0;

      for (final doc in dishesSnapshot.docs) {
        try {
          final dishData = doc.data();

          await doc.reference.update({
            'order_count': 0,
            'view_count': 0,
            'rating_count': 0,
            'popularity_score': 0.0,
            'last_ordered': null,
            'last_viewed': null,
            'popularity_updated_at': FieldValue.serverTimestamp(),
          });

          resetCount++;

          print('✅ Données remises à zéro: ${dishData['name']}');
        } catch (e) {
          print('❌ Erreur réinitialisation plat ${doc.id}: $e');
        }
      }

      print(
          '✅ Réinitialisation terminée: $resetCount plats remis à zéro sur ${dishesSnapshot.docs.length}');
      print('📊 Tous les plats commencent maintenant avec un score de 0/100');
    } catch (e) {
      print('❌ Erreur réinitialisation globale: $e');
    }
  }
}
