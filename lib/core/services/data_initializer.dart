import 'package:cloud_firestore/cloud_firestore.dart';
import 'dish_popularity_service.dart';

class DataInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialise toutes les données nécessaires pour le système de popularité
  static Future<void> initializePopularitySystem() async {
    print('🚀 Initialisation complète du système de popularité...');

    try {
      // 1. Initialiser les champs de popularité pour tous les plats
      await DishPopularityService.initializeAllExistingDishes();

      // 2. Assigner des valeurs initiales basées sur les données existantes
      await _assignInitialPopularityValues();

      // 3. Recalculer tous les scores
      await DishPopularityService.recalculateAllPopularityScores();

      print('✅ Système de popularité initialisé avec succès !');
    } catch (e) {
      print('❌ Erreur initialisation système popularité: $e');
    }
  }

  /// Assigne des valeurs initiales de popularité basées sur les ratings existants
  static Future<void> _assignInitialPopularityValues() async {
    try {
      print('📊 Attribution des valeurs initiales de popularité...');

      final dishesSnapshot = await _firestore
          .collection('dishes')
          .orderBy('rating', descending: true)
          .get();

      for (int i = 0; i < dishesSnapshot.docs.length; i++) {
        final doc = dishesSnapshot.docs[i];
        final dishData = doc.data();

        // Calculer order_count basé sur le rating et la position
        final rating = (dishData['rating'] ?? 0.0).toDouble();
        final position = i + 1;

        int initialOrderCount;
        if (rating >= 4.5) {
          initialOrderCount = 25 + (10 - (position % 10)); // 25-35 commandes
        } else if (rating >= 4.0) {
          initialOrderCount = 15 + (5 - (position % 5)); // 15-20 commandes
        } else if (rating >= 3.5) {
          initialOrderCount = 8 + (3 - (position % 3)); // 8-11 commandes
        } else if (rating > 0) {
          initialOrderCount = 2 + (position % 3); // 2-5 commandes
        } else {
          initialOrderCount = position % 2; // 0-1 commandes pour les non-notés
        }

        // Assigner view_count basé sur order_count
        final viewCount = initialOrderCount * 5 + (position % 20);

        await doc.reference.update({
          'order_count': initialOrderCount,
          'view_count': viewCount,
          'last_ordered':
              initialOrderCount > 0 ? FieldValue.serverTimestamp() : null,
        });

        print(
            '✅ Popularité assignée: ${dishData['name']} - $initialOrderCount commandes, $viewCount vues');
      }

      print('📊 Attribution terminée pour ${dishesSnapshot.docs.length} plats');
    } catch (e) {
      print('❌ Erreur attribution popularité: $e');
    }
  }

  /// Réinitialise toutes les données de popularité (pour les tests)
  static Future<void> resetAllPopularityData() async {
    try {
      print('🔄 Réinitialisation de toutes les données de popularité...');

      final dishesSnapshot = await _firestore.collection('dishes').get();

      for (final doc in dishesSnapshot.docs) {
        await doc.reference.update({
          'order_count': 0,
          'view_count': 0,
          'rating_count': 0,
          'popularity_score': 0.0,
          'last_ordered': null,
          'last_viewed': null,
        });
      }

      print('✅ Toutes les données de popularité réinitialisées');
    } catch (e) {
      print('❌ Erreur réinitialisation: $e');
    }
  }

  /// Affiche les statistiques actuelles de popularité
  static Future<void> showPopularityStats() async {
    try {
      print('📊 Statistiques de popularité:');

      final dishesSnapshot = await _firestore
          .collection('dishes')
          .orderBy('order_count', descending: true)
          .limit(10)
          .get();

      print('🏆 Top 10 des plats les plus commandés:');
      for (int i = 0; i < dishesSnapshot.docs.length; i++) {
        final doc = dishesSnapshot.docs[i];
        final data = doc.data();
        print(
            '${i + 1}. ${data['name']} - ${data['order_count']} commandes (Score: ${data['popularity_score']})');
      }
    } catch (e) {
      print('❌ Erreur affichage stats: $e');
    }
  }
}
