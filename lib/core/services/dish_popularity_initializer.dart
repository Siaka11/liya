import 'package:cloud_firestore/cloud_firestore.dart';

class DishPopularityInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialise les champs de popularité pour tous les plats existants
  static Future<void> initializePopularityFields() async {
    try {
      print('🔥 Début initialisation des champs de popularité...');

      final dishesSnapshot = await _firestore.collection('dishes').get();

      int updatedCount = 0;
      for (final doc in dishesSnapshot.docs) {
        final dishData = doc.data();

        // Vérifier si les champs existent déjà
        bool needsUpdate = false;
        Map<String, dynamic> updateData = {};

        if (!dishData.containsKey('order_count')) {
          updateData['order_count'] = 0;
          needsUpdate = true;
        }

        if (!dishData.containsKey('view_count')) {
          updateData['view_count'] = 0;
          needsUpdate = true;
        }

        if (!dishData.containsKey('rating')) {
          updateData['rating'] = 0.0;
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
          print('✅ Plat mis à jour: ${dishData['name']} (${doc.id})');
        }
      }

      print(
          '🔥 Initialisation terminée. $updatedCount plats mis à jour sur ${dishesSnapshot.docs.length}');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation: $e');
    }
  }

  /// Assigne une popularité initiale basée sur l'ordre de création
  static Future<void> assignInitialPopularity() async {
    try {
      print('🔥 Attribution de popularité initiale...');

      final dishesSnapshot = await _firestore
          .collection('dishes')
          .orderBy('createdAt', descending: false) // Plus ancien en premier
          .get();

      for (int i = 0; i < dishesSnapshot.docs.length; i++) {
        final doc = dishesSnapshot.docs[i];
        final dishData = doc.data();

        // Assigner un order_count basé sur l'ancienneté (plus ancien = plus populaire)
        final initialOrderCount = (dishesSnapshot.docs.length - i) *
            2; // Multiplier par 2 pour espacer

        await doc.reference.update({
          'order_count': initialOrderCount,
          'popularity_score':
              initialOrderCount * 10.0, // Score basé sur les commandes
        });

        print(
            '✅ Popularité assignée: ${dishData['name']} - ${initialOrderCount} commandes');
      }

      print('🔥 Attribution terminée pour ${dishesSnapshot.docs.length} plats');
    } catch (e) {
      print('❌ Erreur lors de l\'attribution: $e');
    }
  }
}
