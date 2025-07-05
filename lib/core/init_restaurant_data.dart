import 'package:cloud_firestore/cloud_firestore.dart';

class InitRestaurantData {
  static Future<void> initializeRestaurantData() async {
    try {
      final restaurants = [
        {
          'name': 'RESTAURANT DK DELICE',
          'description':
              'Ambiance typique ivoirienne avec spécialités attiéké et poulet braisé.',
          'address': 'MOROFE CAFOP',
          'city': 'Abidjan',
          'country': 'Côte d\'ivoire',
          'phone': '+225 07 14 72 16 37',
          'email': 'contact@maquisboulevard.ci',
          'latitude': 6.854697018917422,
          'longitude': -5.2818702023580135,
          'openingHours': {
            'mon': '11:00-23:00',
            'tue': '11:00-23:00',
            'wed': '11:00-23:00',
            'thu': '11:00-23:00',
            'fri': '11:00-00:00',
            'sat': '11:00-00:00',
            'sun': '12:00-22:00',
          },
          'coverImage':
              'http://api-restaurant.toptelsig.com/uploads/dkdelice.jpg',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'RESTAURANT CHEZ MAMAN JACQUELINE',
          'description':
              'Cuisine traditionnelle ivoirienne dans un cadre familial.',
          'address': 'Sopim mosqué diarra',
          'city': 'Abidjan',
          'country': 'Côte d\'ivoire',
          'phone': '+225 05 05 05 05 05',
          'email': 'awa@restaurant.ci',
          'latitude': 6.80175458644123,
          'longitude': -5.264818146539934,
          'openingHours': {
            'mon': '10:00-22:00',
            'tue': '10:00-22:00',
            'wed': '10:00-22:00',
            'thu': '10:00-22:00',
            'fri': '10:00-23:00',
            'sat': '10:00-23:00',
            'sun': 'Fermé',
          },
          'coverImage':
              'http://api-restaurant.toptelsig.com/uploads/jacqueline.jpg',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'RESTAURANT SARALA VILLAGE',
          'description':
              'Restaurant lounge avec vue panoramique sur la lagune. Restaurant spécialisé dans la cuisine africaine ; doté d\'un beau cadre',
          'address': 'Plateau, Tour D',
          'city': 'Abidjan',
          'country': 'Côte d\'ivoire',
          'phone': '+225 0170787815',
          'email': 'info@rooftop.ci',
          'latitude': 6.819814487064557,
          'longitude': -5.272940308433262,
          'openingHours': {
            'mon': '17:00-01:00',
            'tue': '17:00-01:00',
            'wed': '17:00-01:00',
            'thu': '17:00-01:00',
            'fri': '17:00-02:00',
            'sat': '17:00-02:00',
            'sun': '17:00-00:00',
          },
          'coverImage':
              'http://api-restaurant.toptelsig.com/uploads/sarala.jpeg',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'RESTAURANT DE LA FIESTA',
          'description':
              'RESTAURANT SPECIALISE DANS LA CUISINE DES PLATS AFRICAINE',
          'address': 'ASSABOU',
          'city': 'Grand-Bassam',
          'country': 'Côte d\'ivoire',
          'phone': '+225 0170787815',
          'email': 'resa@terrassebassam.ci',
          'latitude': 6.826236236808081,
          'longitude': -5.271080786458151,
          'openingHours': {
            'mon': '12:00-22:00',
            'tue': '12:00-22:00',
            'wed': '12:00-22:00',
            'thu': '12:00-22:00',
            'fri': '12:00-23:00',
            'sat': '12:00-23:00',
            'sun': '12:00-21:00',
          },
          'coverImage':
              'http://api-restaurant.toptelsig.com/uploads/restaurant-fiesta.jpeg',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'GARBA CHOCO CHEZ ANDY',
          'description':
              'Spécialités locales avec produits frais de la région. plat et gateau de garba / poulet',
          'address': 'Avenue Charles de Gaulle',
          'city': 'Bouaké',
          'country': 'Côte d\'ivoire',
          'phone': '+225 0777550726',
          'email': 'odelices@bouake.ci',
          'latitude': 6.816963231673649,
          'longitude': -5.258767099587541,
          'openingHours': {
            'mon': '11:00-22:00',
            'tue': '11:00-22:00',
            'wed': '11:00-22:00',
            'thu': '11:00-22:00',
            'fri': '11:00-23:00',
            'sat': '11:00-23:00',
            'sun': '11:00-21:00',
          },
          'coverImage': 'http://api-restaurant.toptelsig.com/uploads/andy.jpg',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'RESTAURANT YAKRO GRILL',
          'description': 'Spécialités locales avec produits frais de la région',
          'address': 'feu de visitation 220',
          'city': 'Bouaké',
          'country': 'Côte d\'ivoire',
          'phone': '+225 07 77 11 62 68',
          'email': 'odelices@bouake.ci',
          'latitude': 6.813807836012079,
          'longitude': -5.252187050247887,
          'openingHours': {
            'mon': '11:00-22:00',
            'tue': '11:00-22:00',
            'wed': '11:00-22:00',
            'thu': '11:00-22:00',
            'fri': '11:00-23:00',
            'sat': '11:00-23:00',
            'sun': '11:00-21:00',
          },
          'coverImage':
              'http://api-restaurant.toptelsig.com/uploads/yakro.jpeg',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = FirebaseFirestore.instance.batch();

      for (final restaurantData in restaurants) {
        final docRef =
            FirebaseFirestore.instance.collection('restaurants').doc();
        batch.set(docRef, restaurantData);
      }

      await batch.commit();
      print('✅ Données des restaurants initialisées avec succès!');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des restaurants: $e');
      rethrow;
    }
  }
}
