import 'package:cloud_firestore/cloud_firestore.dart';

class CleanTestData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Nettoie les commandes de test avec des coordonnées incorrectes
  static Future<void> cleanTestOrders() async {
    try {
      // Supprimer les commandes de test
      final ordersQuery = await _firestore.collection('orders').get();

      for (var doc in ordersQuery.docs) {
        final data = doc.data();
        final latitude = data['latitude'] as double?;
        final longitude = data['longitude'] as double?;

        // Supprimer les commandes avec des coordonnées d'Abidjan ou incorrectes
        if (latitude != null && longitude != null) {
          if (latitude < 6.0 || longitude > -4.5) {
            // Coordonnées d'Abidjan ou incorrectes
            await doc.reference.delete();
            print(
                'Commande supprimée: ${doc.id} - Coordonnées: $latitude, $longitude');
          }
        }
      }

      print('✅ Nettoyage des commandes de test terminé');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }

  /// Met à jour les coordonnées des commandes existantes vers Yamoussoukro
  static Future<void> updateCoordinatesToYamoussoukro() async {
    try {
      final ordersQuery = await _firestore.collection('orders').get();

      for (var doc in ordersQuery.docs) {
        final data = doc.data();
        final latitude = data['latitude'] as double?;
        final longitude = data['longitude'] as double?;

        // Mettre à jour les coordonnées incorrectes
        if (latitude != null && longitude != null) {
          if (latitude < 6.0 || longitude > -4.5) {
            await doc.reference.update({
              'latitude': 6.8270,
              'longitude': -5.2890,
              'address': 'Yamoussoukro, Région des Lacs, Côte d\'Ivoire',
            });
            print('Coordonnées mises à jour: ${doc.id}');
          }
        }
      }

      print('✅ Mise à jour des coordonnées terminée');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour: $e');
    }
  }
}
