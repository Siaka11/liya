import 'dart:async'; // Nécessaire pour Completer
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Nécessaire pour jsonDecode

import '../../core/local_storage_factory.dart'; // Pour stocker verificationId
import '../../core/singletons.dart'; // Pour singleton
import '../../config/app_information.dart'; // Pour Config
// Pour singleton
import 'package:liya/core/services/fcm_service.dart';

class FirebaseAuthService {
  static FirebaseAuthService? _instance;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;

  // Protection contre les appels multiples à sendOTP
  bool _isSendingOTP = false;

  // Pattern Singleton
  factory FirebaseAuthService() {
    _instance ??= FirebaseAuthService._internal();
    return _instance!;
  }

  FirebaseAuthService._internal() {
    // Initialiser les services Firebase une seule fois lors de la première instance
    _initialize();
  }

  // Initialisation des instances Firebase Auth et Firestore
  void _initialize() {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      print('✅ Firebase Auth et Firestore initialisés');
    } catch (e) {
      print('❌ Erreur initialisation Firebase Auth: $e');
      // Gérer l'erreur d'initialisation (ex: logger, montrer une erreur à l'utilisateur)
    }
  }

  // Getters pour les instances Firebase (assurent l'initialisation si non faite)
  FirebaseAuth get _authInstance {
    if (_auth == null) _initialize();
    return _auth!;
  }

  FirebaseFirestore get _firestoreInstance {
    if (_firestore == null) _initialize();
    return _firestore!;
  }

  // Getters pour l'état d'authentification
  User? get currentUser => _authInstance.currentUser;
  bool get isAuthenticated => _authInstance.currentUser != null;

  // Stream pour écouter les changements d'état d'authentification
  Stream<User?> get authStateChanges => _authInstance.authStateChanges();

  /// Formater le numéro de téléphone en format E.164 (+225xxxxxxxxxx)
  String formatPhoneNumber(String phoneNumber) {
    // Rendre PUBLIC
    print('🔍 === DÉBUT FORMATAGE TÉLÉPHONE (FirebaseAuthService) ===');
    print('🔍 Numéro original: "$phoneNumber"');

    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    print('🔍 Numéro nettoyé: "$cleaned"');

    if (cleaned.startsWith('+225')) {
      // Correctement formaté E.164
    } else if (cleaned.startsWith('00225')) {
      cleaned = '+225${cleaned.substring(5)}';
    } else if (cleaned.startsWith('225') && cleaned.length == 13) {
      // Si c'est 225XXXXXXXXXX, on ajoute le '+'
      cleaned = '+${cleaned}';
    } else if (cleaned.length == 10 && cleaned.startsWith('0')) {
      // Format local 0701234567
      cleaned = '+225$cleaned';
    } else {
      throw Exception(
          'Numéro de téléphone invalide. Veuillez utiliser un format local (0701234567) ou international (+2250701234567).');
    }

    // Vérification finale de la longueur et du préfixe
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    if (!cleaned.startsWith('+225') || digitsOnly.length != 13) {
      throw Exception(
          'Le numéro formaté est incorrect. Assurez-vous d\'avoir 10 chiffres après l\'indicatif +225. Ex: +2250701234567');
    }

    print('🔍 ✅ Numéro formaté E.164: "$cleaned"');
    print('🔍 === FIN FORMATAGE TÉLÉPHONE (FirebaseAuthService) ===');
    return cleaned;
  }

  /// Normalise le numéro de téléphone pour correspondre au format des IDs de documents Firestore
  /// Format attendu: +2250140095584 (avec le 0 après +225)
  String normalizePhoneForFirestore(String phoneNumber) {
    print('🔍 === NORMALISATION POUR FIRESTORE ===');
    print('🔍 Numéro original: "$phoneNumber"');

    // Utiliser d'abord le formatage E.164 standard
    final formattedPhone = formatPhoneNumber(phoneNumber);

    // S'assurer que le format correspond exactement aux IDs de documents
    // Format attendu: +2250140095584 (avec le 0 après +225)
    if (formattedPhone.startsWith('+225')) {
      final digitsAfter225 = formattedPhone.substring(4); // Après +225

      // Si le premier chiffre après +225 n'est pas 0, ajouter 0
      if (!digitsAfter225.startsWith('0')) {
        final normalized = '+2250$digitsAfter225';
        print('🔍 ✅ Numéro normalisé pour Firestore: "$normalized"');
        print('🔍 === FIN NORMALISATION POUR FIRESTORE ===');
        return normalized;
      } else {
        print(
            '🔍 ✅ Numéro déjà au bon format pour Firestore: "$formattedPhone"');
        print('🔍 === FIN NORMALISATION POUR FIRESTORE ===');
        return formattedPhone;
      }
    }

    print('🔍 ✅ Numéro normalisé pour Firestore: "$formattedPhone"');
    print('🔍 === FIN NORMALISATION POUR FIRESTORE ===');
    return formattedPhone;
  }

  /// Envoyer le code OTP ou tenter l'auto-vérification
  /// Retourne `true` si un OTP a été envoyé (nécessite une saisie),
  /// `Map<String, dynamic>` si utilisateur existant avec infos complètes,
  /// `false` si auto-vérifié (pas de saisie nécessaire).
  Future<dynamic> sendOTP(String phoneNumber) async {
    if (_isSendingOTP) {
      print('🛡️ Appel multiple à sendOTP bloqué.');
      return false;
    }

    try {
      _isSendingOTP = true;
      print('📱 Début envoi OTP pour: $phoneNumber');

      // Nettoyer tout ancien verification_id avant de commencer
      await forceClearVerificationId();

      final formattedPhone =
          formatPhoneNumber(phoneNumber); // Pour Firebase Auth
      final firestorePhone =
          normalizePhoneForFirestore(phoneNumber); // Pour Firestore

      // VÉRIFICATION 1: Vérifier d'abord si l'utilisateur existe dans Firestore
      print('🔍 Vérification Firestore pour: $firestorePhone');
      print('🔍 ID du document à rechercher: $firestorePhone');
      final existingUser = await getUserInfo(firestorePhone);

      if (existingUser != null) {
        print('✅ Utilisateur trouvé dans Firestore');

        // Vérifier si l'utilisateur a des informations complètes
        final hasCompleteInfo = await _hasCompleteUserInfo(existingUser);
        print('🔍 Utilisateur a des informations complètes: $hasCompleteInfo');

        if (hasCompleteInfo) {
          print(
              '✅ Utilisateur existant avec infos complètes - connexion directe');
          // Appeler _connectExistingUser pour synchroniser avec LocalStorage
          return await _connectExistingUser(firestorePhone, existingUser);
        } else {
          print(
              '⚠️ Utilisateur existant mais infos incomplètes - OTP nécessaire');
          // L'utilisateur existe mais n'a pas d'infos complètes, on envoie l'OTP
        }
      } else {
        print('❌ Utilisateur non trouvé dans Firestore - OTP nécessaire');
        // L'utilisateur n'existe pas, on envoie l'OTP
      }

      // VÉRIFICATION 2: Envoyer OTP via Firebase Auth (seulement si pas d'utilisateur existant avec infos complètes)
      print('📱 Envoi OTP via Firebase Auth...');
      return await _sendOTPViaFirebase(formattedPhone);
    } catch (e) {
      print('❌ Erreur générale dans sendOTP: $e');
      rethrow;
    } finally {
      _isSendingOTP = false;
      print('📱 Fin sendOTP.');
    }
  }

  /// Envoie l'OTP via Firebase Auth
  Future<bool> _sendOTPViaFirebase(String formattedPhone) async {
    final completer = Completer<bool>();

    await _authInstance.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-vérification (Android) - Firebase reconnaît le numéro
        print(
            '✅ Auto-vérification réussie par Firebase (verificationCompleted).');
        await _signInWithCredential(credential);
        await clearVerificationId(); // Utiliser la méthode publique
        if (!completer.isCompleted) {
          completer.complete(false); // Pas besoin d'OTP manuellement
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        print('❌ Échec vérification Firebase: ${e.code} - ${e.message}');
        String userFriendlyMessage;

        // Cas 1: Blocage Firebase
        if (e.code == 'too-many-requests' ||
            e.message?.contains('blocked all requests') == true) {
          userFriendlyMessage =
              'Firebase a temporairement bloqué cet appareil. Veuillez attendre quelques minutes ou utiliser un autre appareil.';
        }
        // Cas 2: Numéro invalide
        else if (e.code == 'invalid-phone-number') {
          userFriendlyMessage =
              'Le numéro de téléphone est invalide. Vérifiez le format (0701234567).';
        }
        // Cas 3: Application non autorisée
        else if (e.code == 'app-not-authorized') {
          userFriendlyMessage =
              'L\'application n\'est pas autorisée. Vérifiez App Check et les empreintes SHA.';
        }
        // Cas 4: Quota dépassé
        else if (e.code == 'quota-exceeded') {
          userFriendlyMessage = 'Limite de SMS dépassée. Réessayez plus tard.';
        }
        // Cas 5: Erreur réseau
        else if (e.code == 'network-request-failed') {
          userFriendlyMessage =
              'Erreur réseau. Vérifiez votre connexion internet.';
        }
        // Cas 6: Erreur inconnue
        else {
          userFriendlyMessage =
              'Erreur lors de l\'envoi du code de vérification: ${e.message}';
        }

        if (!completer.isCompleted) {
          completer.completeError(Exception(userFriendlyMessage));
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        print('📨 Code OTP envoyé par SMS (codeSent). ID: $verificationId');
        await _storeVerificationId(verificationId);
        if (!completer.isCompleted) {
          completer.complete(true); // Indique que l'OTP est nécessaire
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('⏰ Timeout auto-récupération du code. ID: $verificationId');
        // Nettoyer l'ancien verification_id avant d'en stocker un nouveau
        forceClearVerificationId().then((_) {
          _storeVerificationId(verificationId);
        });
        if (!completer.isCompleted) {
          completer.complete(true); // Toujours besoin d'OTP
        }
      },
      timeout: const Duration(seconds: 60),
    );

    return await completer.future;
  }

  /// Vérifier le code OTP reçu
  Future<UserCredential> verifyOTP(String smsCode) async {
    try {
      print('🔐 Début vérification code OTP.');

      final verificationId =
          await getVerificationId(); // Récupère l'ID stocké (maintenant public)
      if (verificationId == null) {
        throw Exception(
            'Aucun ID de vérification trouvé. Veuillez renvoyer l\'OTP.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _signInWithCredential(credential);

      // Si la connexion réussit, vérifier/créer l'utilisateur dans Firestore
      if (userCredential.user != null) {
        await _checkAndCreateUserInFirestore(userCredential.user!);
      }

      await clearVerificationId(); // Nettoyer l'ID après vérification réussie
      print('✅ Vérification OTP réussie.');
      return userCredential;
    } catch (e) {
      print('❌ Erreur vérification OTP: $e');
      rethrow;
    }
  }

  /// Tente de se connecter avec une PhoneAuthCredential
  Future<UserCredential> _signInWithCredential(
      PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await _authInstance.signInWithCredential(credential);
      print(
          '✅ Connexion Firebase réussie pour: ${userCredential.user?.phoneNumber}');
      return userCredential;
    } catch (e) {
      print('❌ Erreur lors de la connexion Firebase avec credential: $e');
      rethrow;
    }
  }

  /// Vérifie si l'utilisateur existe dans Firestore, sinon le crée
  Future<void> _checkAndCreateUserInFirestore(User user) async {
    try {
      final phoneNumber = user.phoneNumber;
      if (phoneNumber == null) {
        throw Exception(
            'Numéro de téléphone de l\'utilisateur Firebase introuvable.');
      }

      // Normaliser le numéro pour correspondre au format des IDs de documents Firestore
      final firestorePhone = normalizePhoneForFirestore(phoneNumber);
      print(
          '🔍 Utilisation du format Firestore pour la création/mise à jour: $firestorePhone');

      final userDoc = await _firestoreInstance
          .collection('users')
          .doc(firestorePhone)
          .get();

      if (!userDoc.exists) {
        print(
            '👤 Création d\'un nouvel utilisateur dans Firestore pour: $firestorePhone');
        // Tente de récupérer les infos de LocalStorage si elles ont été pré-saisies
        final localStorage = LocalStorageFactory();
        final localUserDetailsString = localStorage.getUserDetails();

        Map<String, dynamic>? localUserDetails;
        if (localUserDetailsString != null && localUserDetailsString != '{}') {
          try {
            localUserDetails = jsonDecode(localUserDetailsString);
          } catch (e) {
            print('⚠️ Erreur parsing LocalStorage: $e');
            localUserDetails = null;
          }
        }

        await _firestoreInstance.collection('users').doc(firestorePhone).set({
          'phoneNumber': firestorePhone,
          'name': localUserDetails?['name'] ??
              'Nouveau', // Nom par défaut ou celui de LocalStorage
          'lastname': localUserDetails?['lastName'] ??
              'Utilisateur', // Prénom par défaut ou celui de LocalStorage
          'email': '',
          'address': '',
          'role': 'client', // Rôle par défaut
          'active': true,
          'is_online': false,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        print('✅ Nouvel utilisateur Firestore créé.');

        // Initialiser FCM après la création de l'utilisateur
        await FCMService().initializeAfterAuth();

        // Forcer la sauvegarde du token FCM après un délai
        print(
            '🔄 Forçage de la sauvegarde du token FCM (nouvel utilisateur)...');
        await Future.delayed(Duration(seconds: 2));
        await FCMService().forceSaveFCMToken();
      } else {
        print(
            '✅ Utilisateur existant trouvé dans Firestore pour: $firestorePhone');
        await _firestoreInstance
            .collection('users')
            .doc(firestorePhone)
            .update({
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('❌ Erreur vérification/création utilisateur Firestore: $e');
      rethrow;
    }
  }

  /// Récupère les informations de l'utilisateur depuis Firestore
  Future<Map<String, dynamic>?> getUserInfo(String phoneNumber) async {
    try {
      print(
          '🔍 Recherche dans Firestore - Collection: users, Document ID: $phoneNumber');
      final userDoc =
          await _firestoreInstance.collection('users').doc(phoneNumber).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        print(
            '✅ Informations utilisateur récupérées de Firestore pour: $phoneNumber');
        return userData;
      } else {
        print(
            '❌ Informations utilisateur non trouvées dans Firestore pour: $phoneNumber');
        return null;
      }
    } catch (e) {
      print('❌ Erreur récupération infos utilisateur depuis Firestore: $e');
      return null;
    }
  }

  /// Met à jour les informations de l'utilisateur dans Firestore
  Future<void> updateUserInfo(
      String phoneNumber, Map<String, dynamic> userData) async {
    try {
      // Utiliser set avec merge: true pour créer le document s'il n'existe pas
      await _firestoreInstance.collection('users').doc(phoneNumber).set({
        'phoneNumber': phoneNumber,
        ...userData,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print(
          '✅ Informations utilisateur mises à jour/créées dans Firestore pour: $phoneNumber');
    } catch (e) {
      print('❌ Erreur mise à jour utilisateur dans Firestore: $e');
      rethrow;
    }
  }

  /// Déconnexion de Firebase Auth
  Future<void> signOut() async {
    try {
      // Supprimer le token FCM avant la déconnexion
      await FCMService().removeCurrentToken();

      await _authInstance.signOut();
      print('✅ Déconnexion Firebase réussie.');
    } catch (e) {
      print('❌ Erreur déconnexion Firebase: $e');
      rethrow;
    }
  }

  // --- Gestion du verificationId dans SharedPreferences ---

  /// Récupère l'ID de vérification stocké localement
  Future<String?> getVerificationId() async {
    // Rendre PUBLIC
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('verification_id');
      print('📝 Récupération verification_id de SharedPreferences: $id');

      // Vérifier si l'ID n'est pas trop ancien (plus de 10 minutes)
      if (id != null) {
        final timestamp = prefs.getInt('verification_id_timestamp') ?? 0;
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final timeDiff = currentTime - timestamp;

        // Si l'ID a plus de 10 minutes, le considérer comme expiré
        if (timeDiff > 10 * 60 * 1000) {
          // 10 minutes en millisecondes
          print(
              '⏰ Verification_id expiré (${timeDiff ~/ 1000}s), nettoyage...');
          await clearVerificationId();
          return null;
        }
      }

      return id;
    } catch (e) {
      print('❌ Erreur récupération verificationId de SharedPreferences: $e');
      return null;
    }
  }

  /// Stocke l'ID de vérification localement
  Future<void> _storeVerificationId(String verificationId) async {
    // LAISSER PRIVÉE
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('verification_id', verificationId);
      await prefs.setInt(
          'verification_id_timestamp', DateTime.now().millisecondsSinceEpoch);
      print('💾 VerificationId stocké dans SharedPreferences: $verificationId');
    } catch (e) {
      print('❌ Erreur stockage verificationId dans SharedPreferences: $e');
    }
  }

  /// Supprime l'ID de vérification localement
  Future<void> clearVerificationId() async {
    // Rendre PUBLIC
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('verification_id');
      await prefs.remove('verification_id_timestamp');
      print('🗑️ VerificationId supprimé de SharedPreferences.');
    } catch (e) {
      print('❌ Erreur suppression verificationId de SharedPreferences: $e');
    }
  }

  /// Force le nettoyage du verification_id au démarrage
  Future<void> forceClearVerificationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('verification_id');
      await prefs.remove('verification_id_timestamp');
      print('🗑️ Force nettoyage verificationId de SharedPreferences.');
    } catch (e) {
      print('❌ Erreur force nettoyage verificationId: $e');
    }
  }

  /// Vérifier et corriger les données utilisateur corrompues
  Future<void> fixCorruptedUserData(User user) async {
    // Rendre PUBLIC
    try {
      final phoneNumber = user.phoneNumber;
      if (phoneNumber == null) {
        throw Exception('Numéro de téléphone non disponible');
      }

      // Vérifier si l'utilisateur existe dans Firestore
      final userDoc =
          await _firestoreInstance.collection('users').doc(phoneNumber).get();

      if (!userDoc.exists) {
        print(
            '🔧 Correction: Utilisateur Firebase Auth mais pas dans Firestore');
        // Créer l'utilisateur manquant dans Firestore
        await _checkAndCreateUserInFirestore(user);
      } else {
        print('✅ Données utilisateur cohérentes');
      }
    } catch (e) {
      print('❌ Erreur correction données utilisateur: $e');
      rethrow;
    }
  }

  /// Synchroniser les données utilisateur entre Firebase Auth et Firestore
  Future<void> syncUserData(String phoneNumber) async {
    try {
      print('🔄 Synchronisation des données utilisateur: $phoneNumber');

      // Récupérer les données Firestore
      final firestoreData = await getUserInfo(phoneNumber);

      if (firestoreData != null) {
        // Synchroniser avec LocalStorage
        final localStorage = LocalStorageFactory();
        await localStorage.setUserDetails(firestoreData);
        print('✅ Synchronisation LocalStorage réussie');
      } else {
        print('❌ Données Firestore non trouvées pour: $phoneNumber');
      }
    } catch (e) {
      print('❌ Erreur synchronisation: $e');
    }
  }

  /// Vérifie si l'utilisateur a des informations complètes
  Future<bool> _hasCompleteUserInfo(Map<String, dynamic> userInfo) async {
    try {
      print('🔍 DEBUG: userInfo reçu: $userInfo');
      print('🔍 DEBUG: Type de userInfo: ${userInfo.runtimeType}');

      final name = userInfo['name']?.toString() ?? '';
      final lastname = userInfo['lastname']?.toString() ?? '';
      final address = userInfo['address']?.toString() ?? '';
      final deliveryAddress = userInfo['delivery_address']?.toString() ?? '';

      print('🔍 DEBUG: name = "$name" (type: ${name.runtimeType})');
      print('🔍 DEBUG: lastname = "$lastname" (type: ${lastname.runtimeType})');
      print('🔍 DEBUG: address = "$address" (type: ${address.runtimeType})');
      print(
          '🔍 DEBUG: delivery_address = "$deliveryAddress" (type: ${deliveryAddress.runtimeType})');

      // Vérifier si l'utilisateur a un nom et prénom non vides
      final hasNameInfo = name.isNotEmpty &&
          lastname.isNotEmpty &&
          name != 'Nouveau' &&
          lastname != 'Utilisateur';

      // Vérifier si l'utilisateur a une adresse (address OU delivery_address)
      final hasAddress = address.isNotEmpty || deliveryAddress.isNotEmpty;

      print('🔍 Vérification infos utilisateur:');
      print('  - Nom: "$name"');
      print('  - Prénom: "$lastname"');
      print('  - Adresse: "$address"');
      print('  - Adresse de livraison: "$deliveryAddress"');
      print('  - A nom/prénom: $hasNameInfo');
      print('  - A adresse: $hasAddress');

      return hasNameInfo && hasAddress;
    } catch (e) {
      print('❌ Erreur vérification infos utilisateur: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Retourne les informations d'un utilisateur existant avec des informations complètes
  Future<Map<String, dynamic>?> _connectExistingUser(
      String phoneNumber, Map<String, dynamic> userInfo) async {
    try {
      print('🔗 Connexion directe utilisateur existant: $phoneNumber');

      // Nettoyer les données pour LocalStorage (supprimer les Timestamp)
      final cleanUserInfo = Map<String, dynamic>.from(userInfo);
      cleanUserInfo.remove('created_at');
      cleanUserInfo.remove('updated_at');
      cleanUserInfo.remove('last_location_update');
      print('🔍 Données nettoyées pour LocalStorage: $cleanUserInfo');

      // Mapping correct pour LocalStorage (Firestore → LocalStorage)
      final localData = {
        'name': cleanUserInfo['name'] ?? '',
        'lastName': cleanUserInfo['lastname'] ??
            '', // Firestore: 'lastname' → LocalStorage: 'lastName'
        'email': cleanUserInfo['email'] ?? '',
        'address': cleanUserInfo['address'] ?? '',
        'phoneNumber': cleanUserInfo['phoneNumber'] ?? '',
        'role': cleanUserInfo['role'] ?? 'client',
      };
      print('🔍 Données mappées pour LocalStorage: $localData');

      // Synchroniser les données avec LocalStorage
      final localStorage = LocalStorageFactory();
      await localStorage.setUserDetails(localData);
      print('💾 Données sauvegardées dans LocalStorage');

      // Vérifier que les données sont bien sauvegardées
      final savedData = localStorage.getUserDetails();
      print('🔍 Vérification LocalStorage après sauvegarde: $savedData');

      // Marquer comme authentifié dans SharedPreferences
      await singleton<SharedPreferences>().setBool(Config.ISAUTH, true);

      // Attendre plus longtemps et vérifier que les données sont bien sauvegardées
      print('⏳ Attente de la persistance des données...');
      await Future.delayed(Duration(seconds: 1));

      // Vérifier à nouveau que les données sont bien sauvegardées
      final finalCheck = localStorage.getUserDetails();
      print('🔍 Vérification finale LocalStorage: $finalCheck');

      if (finalCheck == null || finalCheck.isEmpty) {
        print(
            '⚠️ Les données ne sont pas encore persistées, nouvelle tentative...');
        await Future.delayed(Duration(seconds: 2));
        final finalCheck2 = localStorage.getUserDetails();
        print(
            '🔍 Vérification finale après délai supplémentaire: $finalCheck2');
      }

      // Initialiser FCM APRÈS la sauvegarde des données utilisateur
      print(
          '🚀 Initialisation FCM après sauvegarde des données utilisateur...');
      await FCMService().initializeAfterAuth();

      // Forcer la sauvegarde du token FCM avec le numéro de téléphone directement
      print('🔄 Forçage de la sauvegarde du token FCM...');
      await Future.delayed(Duration(seconds: 2));
      await FCMService()
          .forceSaveFCMTokenWithPhone(cleanUserInfo['phoneNumber']);

      print(
          '✅ Utilisateur existant connecté directement (authentification locale)');
      return cleanUserInfo;
    } catch (e) {
      print('❌ Erreur connexion directe utilisateur: $e');
      return null;
    }
  }

  /// Récupère les informations complètes d'un utilisateur depuis Firestore
  /// Cette méthode peut être utilisée par d'autres services pour récupérer les infos utilisateur
  Future<Map<String, dynamic>?> getUserInfoFromFirestore(
      String phoneNumber) async {
    try {
      final firestorePhone = normalizePhoneForFirestore(phoneNumber);
      print(
          '🔍 Récupération infos utilisateur depuis Firestore: $firestorePhone');

      final userInfo = await getUserInfo(firestorePhone);
      if (userInfo != null) {
        print('✅ Informations utilisateur récupérées depuis Firestore');
        return userInfo;
      } else {
        print('❌ Utilisateur non trouvé dans Firestore');
        return null;
      }
    } catch (e) {
      print('❌ Erreur récupération infos utilisateur depuis Firestore: $e');
      return null;
    }
  }
}
