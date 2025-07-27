import 'package:flutter/material.dart'; // Pour ChangeNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Pour ChangeNotifierProvider
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Alias pour éviter conflit de nom User
import 'package:liya/core/singletons.dart';
// import 'package:liya/config/app_information.dart'; // Si Config.ISAUTH est toujours référencé, sinon retirez
import 'package:liya/modules/auth/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/local_storage_factory.dart';
import '../../core/services/fcm_token_service.dart'; // Importez votre service Firebase
import 'package:liya/config/app_information.dart'; // Si Config.ISAUTH est toujours référencé, sinon retirez
import 'dart:convert'; // Import pour jsonDecode
import 'package:liya/core/services/fcm_service.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuthService? _authService; // Peut être null initialement
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser; // Informations de l'utilisateur connecté

  bool _otpNeeded = false; // Indique si l'OTP a été envoyé et est attendu
  String? _currentVerificationId; // L'ID de vérification pour l'OTP

  AuthProvider() {
    _authService =
        FirebaseAuthService(); // Initialise l'instance du service Firebase
    _listenToAuthChanges(); // Démarre l'écoute des changements d'état d'auth Firebase
    _loadAuthState(); // Charge l'état initial au démarrage
  }

  // Getter pour l'instance du service Firebase
  FirebaseAuthService get _authServiceInstance {
    _authService ??=
        FirebaseAuthService(); // S'assure que le service est initialisé
    return _authService!;
  }

  // Getters pour l'état public du provider
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get otpNeeded => _otpNeeded; // Si l'OTP est nécessaire
  String? get currentVerificationId =>
      _currentVerificationId; // L'ID pour la page OTP

  /// Écoute les changements d'état d'authentification de Firebase
  void _listenToAuthChanges() {
    _authServiceInstance.authStateChanges.listen((firebase_auth.User? user) {
      // Ne pas réinitialiser l'authentification si l'utilisateur est déjà authentifié localement
      if (!_isAuthenticated) {
        _isAuthenticated = user != null;
      }

      if (user != null && user.phoneNumber != null) {
        _loadUserInfo(user
            .phoneNumber!); // Charge les infos si l'utilisateur est connecté
      } else if (!_isAuthenticated) {
        // Ne nettoyer les infos que si l'utilisateur n'est pas authentifié localement
        _currentUser = null; // Nettoie les infos si déconnecté
      }
      notifyListeners(); // Informe les auditeurs du changement d'état
    });
  }

  /// Charge l'état initial de l'authentification (utile au démarrage de l'app)
  Future<void> _loadAuthState() async {
    _isAuthenticated = _authServiceInstance.currentUser != null;
    if (_isAuthenticated &&
        _authServiceInstance.currentUser != null &&
        _authServiceInstance.currentUser!.phoneNumber != null) {
      await _loadUserInfo(_authServiceInstance.currentUser!.phoneNumber!);
    }
    notifyListeners();
  }

  /// Charge les informations détaillées de l'utilisateur depuis Firestore
  Future<void> _loadUserInfo(String phoneNumber) async {
    try {
      final userInfo = await _authServiceInstance.getUserInfo(phoneNumber);
      if (userInfo != null) {
        _currentUser = userInfo;
        await _saveUserInfoLocally(userInfo); // Sauvegarde localement
      }
    } catch (e) {
      print('❌ Erreur chargement infos utilisateur dans AuthProvider: $e');
    }
  }

  /// Sauvegarde les informations de l'utilisateur dans LocalStorage
  Future<void> _saveUserInfoLocally(Map<String, dynamic> userInfo) async {
    try {
      final localStorage = LocalStorageFactory();
      await localStorage.setUserDetails(userInfo);
      // Supprimez toute référence à SharedPreferences pour Config.ISAUTH si elle n'est plus pertinente
      // await singleton<SharedPreferences>().setBool(Config.ISAUTH, true);
    } catch (e) {
      print('❌ Erreur sauvegarde locale dans AuthProvider: $e');
    }
  }

  /// Simulation de connexion pour un utilisateur existant avec infos complètes
  void simulateExistingUserConnection(Map<String, dynamic> userInfo) {
    print(
        '🔗 Simulation connexion utilisateur existant (authentification locale)');
    print('🔍 État avant: _isAuthenticated = $_isAuthenticated');

    _isAuthenticated = true;
    _currentUser = userInfo;

    print('🔍 État après: _isAuthenticated = $_isAuthenticated');
    print('🔍 _currentUser = $_currentUser');

    // Marquer comme authentifié dans SharedPreferences
    singleton<SharedPreferences>().setBool(Config.ISAUTH, true);

    print('✅ Simulation connexion locale réussie');

    // Notifier les auditeurs pour déclencher les mises à jour
    notifyListeners();

    // Forcer le rafraîchissement du HomeProvider après un délai
    Future.delayed(const Duration(milliseconds: 200), () {
      print('🔄 Rafraîchissement différé du HomeProvider');
      // Note: On ne peut pas accéder directement au HomeProvider depuis ici
      // Le rafraîchissement sera fait dans auth_page.dart
    });
  }

  /// Envoie le code OTP via Firebase
  /// Met à jour `_otpNeeded` et `_currentVerificationId`.
  /// Retourne `true` si un OTP a été envoyé, `false` si auto-vérifié.
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _otpNeeded = false;
      _currentVerificationId = null;
      notifyListeners();

      // Appelle la méthode sendOTP de FirebaseAuthService qui gère le formatage
      final result = await _authServiceInstance.sendOTP(phoneNumber);

      if (result is Map<String, dynamic>) {
        // Cas: Utilisateur existant avec infos complètes
        print('✅ Utilisateur existant avec infos complètes détecté');
        simulateExistingUserConnection(result);
        return false; // Pas besoin d'OTP
      } else if (result == true) {
        // Cas: OTP envoyé
        _otpNeeded = true;
        _currentVerificationId = await _authServiceInstance.getVerificationId();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Cas: Auto-vérification réussie
        _otpNeeded = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  /// Vérifie le code OTP saisi par l'utilisateur
  Future<bool> verifyOTP(String smsCode) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _authServiceInstance.verifyOTP(smsCode);

      if (userCredential.user != null) {
        // L'utilisateur est connecté via Firebase
        // _isAuthenticated sera mis à jour par _listenToAuthChanges
        await _loadUserInfo(userCredential.user!.phoneNumber!);
        await FCMTokenService.registerTokenForUser(
            userCredential.user!.phoneNumber!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion de l'utilisateur
  Future<void> logout() async {
    try {
      print('🚪 Déconnexion utilisateur...');

      // Supprimer le token FCM
      await FCMService().removeCurrentToken();

      // Déconnexion Firebase Auth
      await _authServiceInstance.signOut();

      // Nettoyer les données locales
      await _authServiceInstance.clearVerificationId();
      await _authServiceInstance.forceClearVerificationId();

      // Réinitialiser l'état
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      _errorMessage = null;

      // Nettoyer SharedPreferences
      await singleton<SharedPreferences>().setBool(Config.ISAUTH, false);

      // Nettoyer LocalStorage
      final localStorage = LocalStorageFactory();
      await localStorage.clearUserDetails();

      notifyListeners();
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
    }
  }

  /// Met à jour les informations de l'utilisateur dans Firestore
  Future<bool> updateUserInfo(Map<String, dynamic> userData) async {
    try {
      if (_authServiceInstance.currentUser?.phoneNumber == null) {
        throw Exception(
            'Utilisateur non connecté. Impossible de mettre à jour les informations.');
      }

      await _authServiceInstance.updateUserInfo(
        _authServiceInstance.currentUser!.phoneNumber!,
        userData,
      );

      await _loadUserInfo(_authServiceInstance
          .currentUser!.phoneNumber!); // Recharge les infos locales
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Efface le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Vérifie l'état d'authentification et synchronise les données
  Future<bool> checkAuthStateAndSync() async {
    try {
      print('🔍 Vérification de l\'état d\'authentification...');

      // Vérifier d'abord l'authentification locale (SharedPreferences)
      final isAuthLocally =
          singleton<SharedPreferences>().getBool(Config.ISAUTH) ?? false;
      print('🔍 Authentification locale: $isAuthLocally');

      if (isAuthLocally) {
        // Vérifier si on a des données utilisateur en local
        final localStorage = LocalStorageFactory();
        final userDetailsString = localStorage.getUserDetails();

        if (userDetailsString != null && userDetailsString != '{}') {
          try {
            final userInfo = jsonDecode(userDetailsString);
            print('✅ Données utilisateur trouvées en local');
            _isAuthenticated = true;
            _currentUser = userInfo;
            notifyListeners();
            return true;
          } catch (e) {
            print('❌ Erreur parsing données locales: $e');
          }
        }
      }

      // Vérifier Firebase Auth comme fallback
      final currentUser = _authServiceInstance.currentUser;
      if (currentUser != null) {
        print(
            '✅ Utilisateur connecté à Firebase Auth: ${currentUser.phoneNumber}');
        await _authServiceInstance.fixCorruptedUserData(currentUser);
        final userInfo =
            await _authServiceInstance.getUserInfo(currentUser.phoneNumber!);
        if (userInfo != null) {
          print('✅ Informations Firestore trouvées');
          await _syncUserInfoWithLocalStorage(userInfo);

          _isAuthenticated = true;
          _currentUser = userInfo;
          notifyListeners();
          return true;
        } else {
          print('❌ Utilisateur Firebase Auth mais pas dans Firestore');
          await logout();
          return false;
        }
      } else {
        print('❌ Aucun utilisateur connecté (ni local ni Firebase Auth)');
        return false;
      }
    } catch (e) {
      print('❌ Erreur vérification état auth: $e');
      return false;
    }
  }

  /// Synchroniser les informations utilisateur avec LocalStorage
  Future<void> _syncUserInfoWithLocalStorage(
      Map<String, dynamic> userInfo) async {
    try {
      final localStorage = LocalStorageFactory();

      // Mapping des données Firestore vers LocalStorage
      final localData = {
        'name': userInfo['name'] ?? '',
        'lastName': userInfo['lastname'] ??
            '', // Firestore: 'lastname' → LocalStorage: 'lastName'
        'email': userInfo['email'] ?? '',
        'address': userInfo['address'] ?? '',
        'phoneNumber': userInfo['phoneNumber'] ?? '',
        'role': userInfo['role'] ?? 'client',
      };

      await localStorage.setUserDetails(localData);
      await singleton<SharedPreferences>().setBool(Config.ISAUTH, true);

      // Initialiser FCM après la synchronisation
      await FCMService().initializeAfterAuth();

      print('✅ Synchronisation LocalStorage réussie');
    } catch (e) {
      print('❌ Erreur synchronisation LocalStorage: $e');
    }
  }

  /// Récupérer l'ID de vérification
  Future<String?> getVerificationId() async {
    try {
      return await _authServiceInstance.getVerificationId();
    } catch (e) {
      print('❌ Erreur récupération verificationId: $e');
      return null;
    }
  }
}

// Déclaration du Provider
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});
