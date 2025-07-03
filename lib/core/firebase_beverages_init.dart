import 'package:cloud_firestore/cloud_firestore.dart';

// Script pour initialiser les données de boissons dans Firebase
// À exécuter une seule fois pour configurer la collection 'beverages'

class FirebaseBeveragesInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeBeverages() async {
    try {
      final beverages = [
        {
          'id': 'coca_cola',
          'name': 'Coca Cola',
          'imageUrl':
              'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=200',
          'category': 'soda',
          'sizes': {'small': 300, 'medium': 500, 'large': 800},
          'isAvailable': true,
          'description': 'Boisson gazeuse rafraîchissante',
        },
        {
          'id': 'fanta',
          'name': 'Fanta',
          'imageUrl':
              'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=200',
          'category': 'soda',
          'sizes': {'small': 300, 'medium': 500, 'large': 800},
          'isAvailable': true,
          'description': 'Boisson gazeuse aux fruits',
        },
        {
          'id': 'sprite',
          'name': 'Sprite',
          'imageUrl':
              'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=200',
          'category': 'soda',
          'sizes': {'small': 300, 'medium': 500, 'large': 800},
          'isAvailable': true,
          'description': 'Boisson gazeuse citron-lime',
        },
        {
          'id': 'pepsi',
          'name': 'Pepsi',
          'imageUrl':
              'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=200',
          'category': 'soda',
          'sizes': {'small': 300, 'medium': 500, 'large': 800},
          'isAvailable': true,
          'description': 'Boisson gazeuse rafraîchissante',
        },
        {
          'id': 'water_mineral',
          'name': 'Eau minérale',
          'imageUrl':
              'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=200',
          'category': 'water',
          'sizes': {'small': 200, 'medium': 400, 'large': 600},
          'isAvailable': true,
          'description': 'Eau minérale naturelle',
        },
        {
          'id': 'water_sparkling',
          'name': 'Eau gazeuse',
          'imageUrl':
              'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=200',
          'category': 'water',
          'sizes': {'small': 250, 'medium': 450, 'large': 650},
          'isAvailable': true,
          'description': 'Eau minérale gazeuse',
        },
        {
          'id': 'orange_juice',
          'name': 'Jus d\'orange',
          'imageUrl':
              'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200',
          'category': 'juice',
          'sizes': {'small': 400, 'medium': 600, 'large': 900},
          'isAvailable': true,
          'description': 'Jus d\'orange frais',
        },
        {
          'id': 'apple_juice',
          'name': 'Jus de pomme',
          'imageUrl':
              'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200',
          'category': 'juice',
          'sizes': {'small': 400, 'medium': 600, 'large': 900},
          'isAvailable': true,
          'description': 'Jus de pomme naturel',
        },
        {
          'id': 'pineapple_juice',
          'name': 'Jus d\'ananas',
          'imageUrl':
              'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200',
          'category': 'juice',
          'sizes': {'small': 450, 'medium': 650, 'large': 950},
          'isAvailable': true,
          'description': 'Jus d\'ananas tropical',
        },
        {
          'id': 'mango_juice',
          'name': 'Jus de mangue',
          'imageUrl':
              'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200',
          'category': 'juice',
          'sizes': {'small': 450, 'medium': 650, 'large': 950},
          'isAvailable': true,
          'description': 'Jus de mangue exotique',
        },
      ];

      // Ajouter chaque boisson à la collection
      for (final beverage in beverages) {
        await _firestore
            .collection('beverages')
            .doc(beverage['id'] as String)
            .set(beverage);
      }

      print('✅ Données de boissons initialisées avec succès dans Firebase');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des boissons: $e');
    }
  }

  // Méthode pour vérifier si les données existent déjà
  static Future<bool> beveragesExist() async {
    try {
      final snapshot = await _firestore.collection('beverages').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Méthode pour nettoyer la collection (à utiliser avec précaution)
  static Future<void> clearBeverages() async {
    try {
      final snapshot = await _firestore.collection('beverages').get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Collection beverages nettoyée');
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }
}

// Instructions d'utilisation:
// 1. Pour initialiser les données (une seule fois):
//    await FirebaseBeveragesInitializer.initializeBeverages();
//
// 2. Pour vérifier si les données existent:
//    final exists = await FirebaseBeveragesInitializer.beveragesExist();
//
// 3. Pour nettoyer (attention!):
//    await FirebaseBeveragesInitializer.clearBeverages();
