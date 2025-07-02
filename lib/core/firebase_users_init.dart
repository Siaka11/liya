import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseUsersInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Structure de données utilisateur basée sur la requête SQL
  static Future<void> createUser({
    required String id,
    required String phoneNumber,
    required String name,
    required String lastname,
    required String email,
    required String address,
    required String phone,
    required DateTime createdAt,
    required String role,
  }) async {
    try {
      await _firestore.collection('users').doc(id).set({
        'id': id,
        'phone_number': phoneNumber,
        'name': name,
        'lastname': lastname,
        'email': email,
        'address': address,
        'phone': phone,
        'created_at': Timestamp.fromDate(createdAt),
        'role': role,
      });
      print('✅ Utilisateur créé avec succès: $name $lastname');
    } catch (e) {
      print('❌ Erreur lors de la création de l\'utilisateur: $e');
    }
  }

  // Méthode pour créer plusieurs utilisateurs de test
  static Future<void> initializeTestUsers() async {
    print('🚀 Début de l\'initialisation des utilisateurs...');

    // Liste d'utilisateurs de test
    final List<Map<String, dynamic>> testUsers = [
      {
        'id': '0701234567',
        'phone_number': '0701234567',
        'name': 'Konan',
        'lastname': 'Alex',
        'email': 'konan.alex@example.com',
        'address': 'Yamoussoukro, Côte d\'Ivoire',
        'phone': '0701234567',
        'created_at': DateTime.now().subtract(Duration(days: 30)),
        'role': 'client',
      },
      {
        'id': '0702345678',
        'phone_number': '0702345678',
        'name': 'Traoré',
        'lastname': 'Fatou',
        'email': 'traore.fatou@example.com',
        'address': 'Abidjan, Côte d\'Ivoire',
        'phone': '0702345678',
        'created_at': DateTime.now().subtract(Duration(days: 25)),
        'role': 'client',
      },
      {
        'id': '0703456789',
        'phone_number': '0703456789',
        'name': 'Kouassi',
        'lastname': 'Jean',
        'email': 'kouassi.jean@example.com',
        'address': 'Bouaké, Côte d\'Ivoire',
        'phone': '0703456789',
        'created_at': DateTime.now().subtract(Duration(days: 20)),
        'role': 'livreur',
      },
      {
        'id': '0704567890',
        'phone_number': '0704567890',
        'name': 'Diabaté',
        'lastname': 'Mariam',
        'email': 'diabate.mariam@example.com',
        'address': 'San-Pédro, Côte d\'Ivoire',
        'phone': '0704567890',
        'created_at': DateTime.now().subtract(Duration(days: 15)),
        'role': 'client',
      },
      {
        'id': '0705678901',
        'phone_number': '0705678901',
        'name': 'Yao',
        'lastname': 'Koffi',
        'email': 'yao.koffi@example.com',
        'address': 'Korhogo, Côte d\'Ivoire',
        'phone': '0705678901',
        'created_at': DateTime.now().subtract(Duration(days: 10)),
        'role': 'livreur',
      },
      {
        'id': '0706789012',
        'phone_number': '0706789012',
        'name': 'Bamba',
        'lastname': 'Aïcha',
        'email': 'bamba.aicha@example.com',
        'address': 'Man, Côte d\'Ivoire',
        'phone': '0706789012',
        'created_at': DateTime.now().subtract(Duration(days: 5)),
        'role': 'client',
      },
      {
        'id': '0707890123',
        'phone_number': '0707890123',
        'name': 'N\'Guessan',
        'lastname': 'Pierre',
        'email': 'nguessan.pierre@example.com',
        'address': 'Gagnoa, Côte d\'Ivoire',
        'phone': '0707890123',
        'created_at': DateTime.now().subtract(Duration(days: 3)),
        'role': 'admin',
      },
      {
        'id': '0708901234',
        'phone_number': '0708901234',
        'name': 'Ouattara',
        'lastname': 'Sylvie',
        'email': 'ouattara.sylvie@example.com',
        'address': 'Daloa, Côte d\'Ivoire',
        'phone': '0708901234',
        'created_at': DateTime.now().subtract(Duration(days: 1)),
        'role': 'client',
      },
    ];

    // Création des utilisateurs
    for (final userData in testUsers) {
      await createUser(
        id: userData['id'],
        phoneNumber: userData['phone_number'],
        name: userData['name'],
        lastname: userData['lastname'],
        email: userData['email'],
        address: userData['address'],
        phone: userData['phone'],
        createdAt: userData['created_at'],
        role: userData['role'],
      );
    }

    print('✅ Initialisation des utilisateurs terminée !');
  }

  // Méthode pour créer un utilisateur spécifique
  static Future<void> createSpecificUser({
    required String id,
    required String phoneNumber,
    required String name,
    required String lastname,
    required String email,
    required String address,
    required String phone,
    required DateTime createdAt,
    required String role,
  }) async {
    await createUser(
      id: id,
      phoneNumber: phoneNumber,
      name: name,
      lastname: lastname,
      email: email,
      address: address,
      phone: phone,
      createdAt: createdAt,
      role: role,
    );
  }

  // Méthode pour lister tous les utilisateurs
  static Future<void> listAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      print('📋 Liste des utilisateurs dans Firestore:');
      print('Total: ${snapshot.docs.length} utilisateurs');

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print(
            '👤 ${data['name']} ${data['lastname']} - ${data['role']} - ${data['phone_number']}');
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  // Méthode pour supprimer tous les utilisateurs (attention !)
  static Future<void> deleteAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('🗑️ Tous les utilisateurs ont été supprimés');
    } catch (e) {
      print('❌ Erreur lors de la suppression des utilisateurs: $e');
    }
  }
}
