import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert'; // Added for jsonDecode
import '../../../../core/local_storage_factory.dart';
import '../../../../core/singletons.dart';
import '../../domain/entities/delivery_user.dart';
import '../../../../core/services/notification_service.dart';

class DeliveryLocationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static StreamSubscription<Position>? _locationSubscription;
  static Timer? _updateTimer;

  // ===== GESTION DES STATUTS LIVREUR =====
  //
  // DIFFÉRENCE ENTRE LES CHAMPS :
  // - 'active': Disponibilité générale (peut recevoir des commandes)
  // - 'is_online': Statut de connexion (partage sa position en temps réel)
  //
  // FLUX DES STATUTS :
  // 1. Connexion → active: true, is_online: false
  // 2. GO ONLINE → active: true, is_online: true + mise à jour position
  // 3. ARRÊTER → active: true, is_online: false + arrêt mise à jour
  // 4. Déconnexion → active: false, is_online: false

  /// Connecter un livreur (disponible mais pas en course)
  static Future<void> connectDeliveryUser(String phoneNumber) async {
    try {
      print('🔵 Connexion livreur: $phoneNumber (disponible)');

      // Récupérer la position actuelle même en mode "disponible"
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _firestore.collection('users').doc(phoneNumber).update({
        'active': true,
        'is_online': false, // Pas encore en course
        'current_latitude': position.latitude,
        'current_longitude': position.longitude,
        'last_location_update': FieldValue.serverTimestamp(),
        'connection_time': FieldValue.serverTimestamp(),
      });

      print(
          '✅ Livreur connecté (disponible) avec position: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Erreur connexion livreur: $e');
    }
  }

  /// Déconnecter un livreur (fermeture de l'app)
  static Future<bool> disconnectDeliveryUser(String phoneNumber) async {
    try {
      print('🔌 Déconnexion du livreur: $phoneNumber');

      await _firestore.collection('users').doc(phoneNumber).update({
        'active': false, // Plus disponible
        'is_online': false, // Plus en ligne
        'last_disconnection': FieldValue.serverTimestamp(),
      });

      // Arrêter toutes les mises à jour
      await stopAutomaticLocationUpdate(phoneNumber);

      print('✅ Livreur déconnecté avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur déconnexion livreur: $e');
      return false;
    }
  }

  /// Activer un livreur (GO ONLINE - démarrage course avec partage position)
  static Future<bool> activateDeliveryUser(String phoneNumber) async {
    try {
      print('🚀 Activation du livreur (démarrage course): $phoneNumber');

      // S'assurer que l'utilisateur est authentifié
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      // Vérifier les permissions de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permission de localisation refusée');
          return false;
        }
      }

      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Position obtenue: ${position.latitude}, ${position.longitude}');

      // Mettre à jour le livreur dans Firestore
      await _firestore.collection('users').doc(phoneNumber).update({
        'active': true, // Disponible pour recevoir des commandes
        'is_online': true, // En course (partage position)
        'current_latitude': position.latitude,
        'current_longitude': position.longitude,
        'last_location_update': FieldValue.serverTimestamp(),
        'last_activation': FieldValue.serverTimestamp(),
      });

      print('✅ Livreur activé avec succès (démarrage course)');
      return true;
    } catch (e) {
      print('❌ Erreur activation livreur: $e');
      return false;
    }
  }

  /// Désactiver un livreur (ARRÊTER - fin course mais reste disponible)
  static Future<bool> deactivateDeliveryUser(String phoneNumber) async {
    try {
      print('🛑 Désactivation du livreur (fin course): $phoneNumber');

      await _firestore.collection('users').doc(phoneNumber).update({
        'active': true, // Reste disponible pour recevoir des commandes
        'is_online': false, // Fin course (arrêt partage position)
        'last_deactivation': FieldValue.serverTimestamp(),
      });

      // Arrêter le partage de position
      await stopAutomaticLocationUpdate(phoneNumber);

      print(
          '✅ Livreur désactivé avec succès (fin course mais reste disponible)');
      return true;
    } catch (e) {
      print('❌ Erreur désactivation livreur: $e');
      return false;
    }
  }

  /// Mettre à jour la position du livreur
  static Future<void> _updateDeliveryLocation(
      String phoneNumber, Position position) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).update({
        'current_latitude': position.latitude,
        'current_longitude': position.longitude,
        'last_location_update': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erreur mise à jour position: $e');
    }
  }

  /// Mettre à jour la position d'un livreur
  static Future<void> _updateDriverPosition(String phoneNumber) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _firestore.collection('users').doc(phoneNumber).update({
        'current_latitude': position.latitude,
        'current_longitude': position.longitude,
        'last_location_update': FieldValue.serverTimestamp(),
      });

      print(
          '📍 Position mise à jour pour $phoneNumber: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Erreur mise à jour position: $e');
    }
  }

  // ===== ASSIGNATION INTELLIGENTE =====

  /// Assigner une commande au livreur le plus proche avec sa VRAIE position
  static Future<DeliveryUser?> assignOrderToNearestDriver(
    String orderId,
    double destinationLat,
    double destinationLon,
  ) async {
    try {
      print('🎯 Assignation commande $orderId au livreur le plus proche');

      // Récupérer les livreurs en ligne avec leur VRAIE position
      final onlineDrivers = await getOnlineDeliveryUsers();

      if (onlineDrivers.isEmpty) {
        print('❌ Aucun livreur en ligne disponible');
        return null;
      }

      print('📊 ${onlineDrivers.length} livreurs en ligne trouvés');

      // Trouver le livreur le plus proche avec sa VRAIE position
      DeliveryUser? nearestDriver;
      double shortestDistance = double.infinity;

      for (final driver in onlineDrivers) {
        // Vérifier que le livreur a une position valide
        if (driver.currentLatitude != null && driver.currentLongitude != null) {
          // FORCER une mise à jour de position avant calcul
          print(
              '🔄 Mise à jour position pour ${driver.name} avant assignation...');
          final updatedPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // Mettre à jour la position dans Firestore
          await _firestore.collection('users').doc(driver.phoneNumber).update({
            'current_latitude': updatedPosition.latitude,
            'current_longitude': updatedPosition.longitude,
            'last_location_update': FieldValue.serverTimestamp(),
          });

          print(
              '📍 Position mise à jour: ${updatedPosition.latitude}, ${updatedPosition.longitude}');

          final distance = Geolocator.distanceBetween(
            updatedPosition.latitude, // ← POSITION ACTUELLE
            updatedPosition.longitude, // ← POSITION ACTUELLE
            destinationLat,
            destinationLon,
          );

          print(
              '📏 ${driver.name} ${driver.lastname}: ${distance.toStringAsFixed(0)}m depuis sa position ACTUELLE');

          if (distance < shortestDistance) {
            shortestDistance = distance;
            nearestDriver = driver;
          }
        } else {
          print(
              '⚠️ ${driver.name} ${driver.lastname}: Pas de position disponible');
        }
      }

      if (nearestDriver != null) {
        print(
            '✅ Livreur sélectionné: ${nearestDriver.name} ${nearestDriver.lastname} à ${shortestDistance.toStringAsFixed(0)}m');

        // Récupérer la position la plus récente du livreur sélectionné
        final finalPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Assigner la commande avec les VRAIES coordonnées ACTUELLES
        await _firestore.collection('orders').doc(orderId).update({
          'delivery_phone_number': nearestDriver.phoneNumber,
          'delivery_name': '${nearestDriver.name} ${nearestDriver.lastname}',
          'status': 'enRoute',
          'assigned_at': FieldValue.serverTimestamp(),
          'destination_coordinates': {
            'latitude': destinationLat,
            'longitude': destinationLon,
          },
          'driver_coordinates': {
            // Position RÉELLE et ACTUELLE du livreur au moment de l'assignation
            'latitude': finalPosition.latitude,
            'longitude': finalPosition.longitude,
          },
        });

        // Mettre à jour le livreur avec les informations de la commande
        await _firestore
            .collection('users')
            .doc(nearestDriver.phoneNumber)
            .update({
          'current_order_id': orderId,
          'destination_coordinates': {
            'latitude': destinationLat,
            'longitude': destinationLon,
          },
        });

        // Envoyer une notification au livreur
        try {
          await NotificationService().notifyOrderAssignedToDelivery(
            orderId: orderId,
            deliveryUserPhone: nearestDriver.phoneNumber,
            customerAddress:
                'Adresse de livraison', // À récupérer depuis la commande
            total: 0.0, // À récupérer depuis la commande
          );
          print(
              '✅ Notification envoyée au livreur ${nearestDriver.phoneNumber}');
        } catch (e) {
          print('⚠️ Erreur envoi notification: $e');
        }

        print(
            '✅ Commande assignée avec succès avec position ACTUELLE du livreur');
        return nearestDriver;
      }

      print('❌ Aucun livreur disponible avec position valide');
      return null;
    } catch (e) {
      print('❌ Erreur assignation: $e');
      return null;
    }
  }

  /// Assigner une commande à un livreur spécifique
  static Future<bool> assignOrderToSpecificDriver(
    String orderId,
    String driverPhoneNumber,
    double destinationLat,
    double destinationLon,
  ) async {
    try {
      print(
          '🎯 Assignation commande $orderId au livreur spécifique: $driverPhoneNumber');

      // Vérifier que le livreur existe et est en ligne
      final driverDoc =
          await _firestore.collection('users').doc(driverPhoneNumber).get();

      if (!driverDoc.exists) {
        print('❌ Livreur $driverPhoneNumber non trouvé');
        return false;
      }

      final driverData = driverDoc.data()!;
      final driver = DeliveryUser.fromMap(driverData);

      if (!driver.active) {
        print('❌ Livreur $driverPhoneNumber n\'est pas actif');
        return false;
      }

      if (driver.currentLatitude == null || driver.currentLongitude == null) {
        print('❌ Livreur $driverPhoneNumber n\'a pas de position disponible');
        return false;
      }

      print('✅ Livreur sélectionné: ${driver.name} ${driver.lastname}');

      // Assigner la commande avec les VRAIES coordonnées du livreur
      await _firestore.collection('orders').doc(orderId).update({
        'delivery_phone_number': driver.phoneNumber,
        'delivery_name': '${driver.name} ${driver.lastname}',
        'status': 'enRoute',
        'assigned_at': FieldValue.serverTimestamp(),
        'destination_coordinates': {
          'latitude': destinationLat,
          'longitude': destinationLon,
        },
        'driver_coordinates': {
          // Position RÉELLE du livreur au moment de l'assignation
          'latitude': driver.currentLatitude,
          'longitude': driver.currentLongitude,
        },
      });

      // Mettre à jour le livreur avec les informations de la commande
      await _firestore.collection('users').doc(driverPhoneNumber).update({
        'current_order_id': orderId,
        'destination_coordinates': {
          'latitude': destinationLat,
          'longitude': destinationLon,
        },
      });

      // Envoyer une notification au livreur
      try {
        await NotificationService().notifyOrderAssignedToDelivery(
          orderId: orderId,
          deliveryUserPhone: driverPhoneNumber,
          customerAddress:
              'Adresse de livraison', // À récupérer depuis la commande
          total: 0.0, // À récupérer depuis la commande
        );
        print('✅ Notification envoyée au livreur $driverPhoneNumber');
      } catch (e) {
        print('⚠️ Erreur envoi notification: $e');
      }

      print('✅ Commande assignée avec succès au livreur spécifique');
      return true;
    } catch (e) {
      print('❌ Erreur assignation spécifique: $e');
      return false;
    }
  }

  // ===== RÉCUPÉRATION DES COMMANDES =====

  /// Récupérer toutes les commandes en attente d'assignation
  static Future<List<Map<String, dynamic>>> getPendingOrders() async {
    try {
      print('🔍 Récupération des commandes en attente...');

      final querySnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'reception')
          .get();

      final List<Map<String, dynamic>> pendingOrders = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id; // Ajouter l'ID du document
        pendingOrders.add(data);
      }

      print('✅ ${pendingOrders.length} commandes en attente trouvées');
      return pendingOrders;
    } catch (e) {
      print('❌ Erreur récupération commandes: $e');
      return [];
    }
  }

  /// Récupérer les commandes de restaurant en attente
  static Future<List<Map<String, dynamic>>> getPendingRestaurantOrders() async {
    try {
      print('🔍 Récupération des commandes restaurant...');

      // Essayer d'abord avec les filtres stricts
      var querySnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'reception')
          .where('type', isEqualTo: 'restaurant')
          .get();

      print(
          '📊 ${querySnapshot.docs.length} commandes trouvées avec filtres stricts');

      // Si aucune commande trouvée, essayer sans le filtre 'type'
      if (querySnapshot.docs.isEmpty) {
        print('🔄 Aucune commande trouvée, essai sans filtre type...');
        querySnapshot = await _firestore
            .collection('orders')
            .where('status', isEqualTo: 'reception')
            .get();
        print(
            '📊 ${querySnapshot.docs.length} commandes trouvées sans filtre type');
      }

      if (querySnapshot.docs.isEmpty) {
        print(
            '🔄 Aucune commande trouvée, récupération de toutes les commandes...');
        querySnapshot = await _firestore.collection('orders').get();
        print('📊 ${querySnapshot.docs.length} commandes totales trouvées');
      }

      final List<Map<String, dynamic>> orders = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Afficher les détails pour debug
        print(
            '📋 Commande ${doc.id}: status=${data['status']}, type=${data['type'] ?? 'N/A'}');

        orders.add(data);
      }

      print('✅ ${orders.length} commandes restaurant retournées');
      return orders;
    } catch (e) {
      print('❌ Erreur récupération commandes restaurant: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getPendingParcelOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection('parcels')
          .where('status', isEqualTo: 'reception')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['type'] = 'parcel'; // Marquer comme colis
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Test: Récupérer les commandes assignées avec le numéro du livreur connecté
  static Future<List<Map<String, dynamic>>>
      testGetAssignedOrdersForSpecificDriver() async {
    try {
      // Récupérer le numéro du livreur connecté
      final userDetailsJson = singleton<LocalStorageFactory>().getUserDetails();
      final userDetails = userDetailsJson is String
          ? jsonDecode(userDetailsJson)
          : userDetailsJson;
      final phoneNumber = userDetails['phoneNumber'] ?? '';
      print('🧪 Test avec le numéro du livreur connecté: $phoneNumber');

      if (phoneNumber.isEmpty) {
        print('❌ Aucun numéro de téléphone trouvé pour le livreur');
        return [];
      }

      // Récupérer les commandes restaurant avec ce numéro et trier par assigned_at
      final restaurantOrders = await _firestore
          .collection('orders')
          .where('delivery_phone_number', isEqualTo: phoneNumber)
          .orderBy('assigned_at', descending: true)
          .get();

      print(
          '📊 Test - Commandes restaurant trouvées: ${restaurantOrders.docs.length}');

      final List<Map<String, dynamic>> allOrders = [];

      // Ajouter les commandes restaurant
      for (final doc in restaurantOrders.docs) {
        final data = doc.data();
        print(
            '🍽️ Test - Commande restaurant: ${doc.id} - Status: ${data['status']} - Client: ${data['customer_name']} - Assigned: ${data['assigned_at']}');
        allOrders.add({
          ...data,
          'id': doc.id,
          'type': 'restaurant',
        });
      }

      print(
          '✅ Test - ${allOrders.length} commandes trouvées pour $phoneNumber');
      return allOrders;
    } catch (e) {
      print('❌ Erreur test: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAssignedOrdersForDriver(
      String driverPhoneNumber) async {
    try {
      print('🔍 Recherche des commandes assignées pour: $driverPhoneNumber');

      final restaurantOrders = await _firestore
          .collection('orders')
          .where('delivery_phone_number', isEqualTo: driverPhoneNumber)
          .orderBy('assigned_at', descending: true)
          .get();

      print(
          '📊 Commandes restaurant trouvées: ${restaurantOrders.docs.length}');

      final parcelOrders = await _firestore
          .collection('parcels')
          .where('delivery_phone_number', isEqualTo: driverPhoneNumber)
          .orderBy('assigned_at', descending: true)
          .get();

      print('📦 Colis trouvés: ${parcelOrders.docs.length}');

      final List<Map<String, dynamic>> allOrders = [];

      // Ajouter les commandes restaurant
      for (final doc in restaurantOrders.docs) {
        final data = doc.data();
        print(
            '🍽️ Commande restaurant: ${doc.id} - Status: ${data['status']} - Client: ${data['customer_name']} - Delivery: ${data['delivery_phone_number']} - Assigned: ${data['assigned_at']}');
        allOrders.add({
          ...data,
          'id': doc.id,
          'type': 'restaurant',
        });
      }

      // Ajouter les colis
      for (final doc in parcelOrders.docs) {
        final data = doc.data();
        print(
            '📦 Colis: ${doc.id} - Status: ${data['status']} - Client: ${data['customer_name']} - Delivery: ${data['delivery_phone_number']} - Assigned: ${data['assigned_at']}');
        allOrders.add({
          ...data,
          'id': doc.id,
          'type': 'parcel',
        });
      }

      print(
          '✅ ${allOrders.length} commandes assignées trouvées au total pour $driverPhoneNumber');
      return allOrders;
    } catch (e) {
      print('❌ Erreur récupération commandes assignées: $e');
      return [];
    }
  }

  static Future<Map<String, double>?> getOrderDestinationCoordinates(
      String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final coords = data['destination_coordinates'] as Map<String, dynamic>?;

        if (coords != null) {
          return {
            'latitude': coords['latitude'].toDouble(),
            'longitude': coords['longitude'].toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération coordonnées destination: $e');
      return null;
    }
  }

  // ===== MISE À JOUR AUTOMATIQUE DE POSITION =====

  /// Démarrer la mise à jour automatique de position
  static Future<void> startAutomaticLocationUpdate(String phoneNumber) async {
    print('🔄 Démarrage mise à jour position pour: $phoneNumber');

    // Vérifier le statut actuel
    final doc = await _firestore.collection('users').doc(phoneNumber).get();
    if (doc.exists) {
      final data = doc.data()!;
      final isOnline = data['is_online'] ?? false;
      final active = data['active'] ?? false; // Changé de isActive à active

      print('📊 Statut livreur: active=$active, is_online=$isOnline');

      if (active) {
        // Changé de isActive à active
        // Mise à jour immédiate
        await _updateDriverPosition(phoneNumber);

        // Mise à jour périodique selon le statut
        if (isOnline) {
          // En course: mise à jour très fréquente (toutes les 15 secondes)
          _updateTimer = Timer.periodic(Duration(seconds: 15), (timer) async {
            await _updateDriverPosition(phoneNumber);
          });
          print('🚗 Mode course: mise à jour toutes les 15 secondes');
        } else {
          // Disponible: mise à jour fréquente (toutes les 30 secondes)
          _updateTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
            await _updateDriverPosition(phoneNumber);
          });
          print('🔵 Mode disponible: mise à jour toutes les 30 secondes');
        }

        // Écouter les changements de position en temps réel
        _locationSubscription = Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter:
                5, // Mettre à jour si déplacement > 5m (plus sensible)
          ),
        ).listen((position) async {
          print(
              '📍 Nouvelle position détectée: ${position.latitude}, ${position.longitude}');
          await _updateDriverPosition(phoneNumber);
        });

        print('✅ Mise à jour automatique démarrée');
      } else {
        print('❌ Livreur non actif, mise à jour annulée');
      }
    } else {
      print('❌ Livreur non trouvé');
    }
  }

  /// Arrêter la mise à jour automatique de position
  static Future<void> stopAutomaticLocationUpdate(String phoneNumber) async {
    try {
      print('🛑 Arrêt mise à jour automatique pour: $phoneNumber');

      _locationSubscription?.cancel();
      _updateTimer?.cancel();

      print('✅ Mise à jour automatique arrêtée');
    } catch (e) {
      print('❌ Erreur arrêt mise à jour automatique: $e');
    }
  }

  /// Récupérer la position actuelle d'un livreur (mise à jour en temps réel)
  static Future<Map<String, double>?> getDriverCurrentPosition(
      String driverPhone) async {
    try {
      final doc = await _firestore.collection('users').doc(driverPhone).get();
      if (doc.exists) {
        final data = doc.data()!;
        final lat = data['current_latitude'];
        final lon = data['current_longitude'];

        if (lat != null && lon != null) {
          print('📍 Position actuelle de $driverPhone: $lat, $lon');
          return {
            'latitude': lat.toDouble(),
            'longitude': lon.toDouble(),
          };
        }
      }
      print('⚠️ Pas de position disponible pour $driverPhone');
      return null;
    } catch (e) {
      print('❌ Erreur récupération position livreur: $e');
      return null;
    }
  }

  /// Méthode de test pour forcer la mise à jour de position
  static Future<bool> testUpdatePosition(String phoneNumber) async {
    try {
      print('🧪 Test mise à jour position pour: $phoneNumber');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('📍 Position obtenue: ${position.latitude}, ${position.longitude}');

      await _firestore.collection('users').doc(phoneNumber).update({
        'current_latitude': position.latitude,
        'current_longitude': position.longitude,
        'last_location_update': FieldValue.serverTimestamp(),
      });

      print('✅ Position mise à jour avec succès dans Firestore');
      return true;
    } catch (e) {
      print('❌ Erreur test mise à jour: $e');
      return false;
    }
  }

  /// Forcer la mise à jour de position d'un livreur avant assignation
  static Future<Map<String, double>?> forceUpdateDriverPosition(
      String phoneNumber) async {
    try {
      print('🔄 Mise à jour forcée de position pour: $phoneNumber');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _firestore.collection('users').doc(phoneNumber).update({
        'current_latitude': position.latitude,
        'current_longitude': position.longitude,
        'last_location_update': FieldValue.serverTimestamp(),
      });

      print(
          '✅ Position mise à jour: ${position.latitude}, ${position.longitude}');

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('❌ Erreur mise à jour forcée: $e');
      return null;
    }
  }

  /// Récupérer les livreurs en ligne (active: true ET is_online: true)
  static Future<List<DeliveryUser>> getOnlineDeliveryUsers() async {
    try {
      print('🔍 Récupération des livreurs en ligne...');

      // Chercher dans orders pour trouver les livreurs avec des commandes actives
      final ordersQuery = await _firestore
          .collection('orders')
          .where('status', whereIn: ['enRoute', 'reception']).get();

      // Extraire les numéros de téléphone uniques des livreurs actifs
      final Set<String> activeDriverPhones = {};
      for (final doc in ordersQuery.docs) {
        final data = doc.data();
        final deliveryPhone = data['delivery_phone_number'] as String?;
        if (deliveryPhone != null && deliveryPhone.isNotEmpty) {
          activeDriverPhones.add(deliveryPhone);
        }
      }

      print('📱 Livreurs actifs trouvés: ${activeDriverPhones.length}');

      // Créer des objets DeliveryUser pour chaque livreur actif
      final List<DeliveryUser> onlineUsers = [];
      for (final phone in activeDriverPhones) {
        // Chercher les informations du livreur dans les commandes
        final driverOrders = ordersQuery.docs.where((doc) {
          final data = doc.data();
          return data['delivery_phone_number'] == phone;
        }).toList();

        if (driverOrders.isNotEmpty) {
          final latestOrder = driverOrders.first;
          final orderData = latestOrder.data();

          onlineUsers.add(DeliveryUser(
            id: phone, // phoneNumber comme id
            phoneNumber: phone,
            name: orderData['delivery_name'] ?? 'Livreur',
            lastname: '', // Valeur par défaut
            email: '', // Valeur par défaut
            address: '', // Valeur par défaut
            role: 'livreur', // Rôle par défaut
            isOnline: true,
            active: true, // Changé de isActive à active
            currentLatitude:
                orderData['driver_coordinates']?['latitude'] ?? 0.0,
            currentLongitude:
                orderData['driver_coordinates']?['longitude'] ?? 0.0,
            lastLocationUpdate: orderData['assigned_at'] is Timestamp
                ? (orderData['assigned_at'] as Timestamp).toDate()
                : null,
          ));
        }
      }

      print('✅ ${onlineUsers.length} livreurs en ligne récupérés');
      return onlineUsers;
    } catch (e) {
      print('❌ Erreur récupération livreurs en ligne: $e');
      return [];
    }
  }

  /// Récupérer tous les livreurs disponibles (active: true)
  static Future<List<DeliveryUser>> getAvailableDeliveryUsers() async {
    try {
      print('🔍 Récupération des livreurs disponibles...');

      // Chercher dans users pour trouver les livreurs avec active: true
      final usersQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'livreur')
          .where('active', isEqualTo: true)
          .get();

      final List<DeliveryUser> availableUsers = [];

      for (final doc in usersQuery.docs) {
        final userData = doc.data();

        // Vérifier si le livreur a une position
        final hasLocation = userData['current_latitude'] != null &&
            userData['current_longitude'] != null;

        availableUsers.add(DeliveryUser(
          id: userData['phoneNumber'] ?? doc.id,
          phoneNumber: userData['phoneNumber'] ?? '',
          name: userData['name'] ?? 'Livreur',
          lastname: userData['lastname'] ?? '',
          email: userData['email'] ?? '',
          address: userData['address'] ?? '',
          role: userData['role'] ?? 'livreur',
          isOnline: hasLocation,
          active: userData['active'] ?? false,
          currentLatitude: userData['current_latitude']?.toDouble(),
          currentLongitude: userData['current_longitude']?.toDouble(),
          lastLocationUpdate: userData['last_location_update'] is Timestamp
              ? (userData['last_location_update'] as Timestamp).toDate()
              : null,
        ));
      }

      print('✅ ${availableUsers.length} livreurs actifs récupérés');
      return availableUsers;
    } catch (e) {
      print('❌ Erreur récupération livreurs disponibles: $e');
      return [];
    }
  }

  /// Récupérer les informations du client depuis la collection users
  static Future<Map<String, dynamic>?> getClientInfo(String phoneNumber) async {
    try {
      print('🔍 Récupération des informations du client: $phoneNumber');

      final userDoc =
          await _firestore.collection('users').doc(phoneNumber).get();

      if (!userDoc.exists) {
        print('❌ Client $phoneNumber non trouvé');
        return null;
      }

      final userData = userDoc.data()!;
      print(
          '✅ Informations client récupérées: ${userData['name']} ${userData['lastname']}');

      return {
        'name': userData['name'] ?? 'Client inconnu',
        'lastname': userData['lastname'] ?? '',
        'phoneNumber': userData['phoneNumber'] ?? phoneNumber,
        'email': userData['email'] ?? '',
        'address': userData['address'] ?? '',
        'fullName':
            '${userData['name'] ?? ''} ${userData['lastname'] ?? ''}'.trim(),
      };
    } catch (e) {
      print('❌ Erreur récupération informations client: $e');
      return null;
    }
  }

  /// Récupérer les commandes avec les informations complètes du client
  static Future<List<Map<String, dynamic>>>
      getPendingRestaurantOrdersWithClientInfo() async {
    try {
      print('🔍 Récupération des commandes restaurant avec infos client...');

      // Essayer d'abord avec les filtres stricts
      var querySnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'reception')
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Essayer avec un filtre plus large
        querySnapshot = await _firestore
            .collection('orders')
            .where('status', whereIn: ['reception', 'pending']).get();
      }

      final List<Map<String, dynamic>> pendingOrders = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        // Debug: afficher les clés disponibles
        print(
            '🔍 Clés disponibles dans la commande ${doc.id}: ${data.keys.toList()}');

        // Récupérer les informations du client - essayer plusieurs clés possibles
        String? clientPhone = data['phone'] ??
            data['phoneNumber'] ??
            data['customer_phone'] ??
            data['client_phone'];

        print('📱 Numéro de téléphone client trouvé: $clientPhone');

        if (clientPhone != null) {
          final clientInfo = await getClientInfo(clientPhone);
          if (clientInfo != null) {
            data['customer_name'] = clientInfo['fullName'];
            data['customer_phone'] = clientInfo['phoneNumber'];
            data['customer_email'] = clientInfo['email'];
            data['customer_address'] = clientInfo['address'];
            print('✅ Informations client ajoutées: ${clientInfo['fullName']}');
          } else {
            print(
                '❌ Impossible de récupérer les informations du client pour: $clientPhone');
          }
        } else {
          print('❌ Aucun numéro de téléphone client trouvé dans la commande');
        }

        pendingOrders.add(data);
      }

      print(
          '✅ ${pendingOrders.length} commandes restaurant avec infos client récupérées');
      return pendingOrders;
    } catch (e) {
      print('❌ Erreur récupération commandes restaurant: $e');
      return [];
    }
  }
}
