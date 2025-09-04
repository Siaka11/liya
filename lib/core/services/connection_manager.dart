import 'package:flutter/material.dart';
import 'connectivity_service.dart';
import 'offline_storage_service.dart';
import 'firebase_retry_service.dart';
import '../ui/widgets/connection_lost_dialog.dart';
import '../ui/widgets/connection_restored_snackbar.dart';

/// Gestionnaire global de la connexion
class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  factory ConnectionManager() => _instance;
  ConnectionManager._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final FirebaseRetryService _firebaseRetry = FirebaseRetryService();

  BuildContext? _currentContext;
  bool _isDialogShowing = false;

  /// Initialiser le gestionnaire de connexion
  Future<void> initialize() async {
    print('🌐 Initialisation du gestionnaire de connexion...');

    await _connectivityService.initialize();
    _setupConnectionCallbacks();

    // Forcer une vérification initiale pour les émulateurs
    await _connectivityService.forceConnectivityCheck();

    print('✅ Gestionnaire de connexion initialisé');
  }

  /// Configurer les callbacks de connexion
  void _setupConnectionCallbacks() {
    _connectivityService.setOnConnectionLost(() {
      print('⚠️ Connexion perdue - Gestionnaire notifié');
      _onConnectionLost();
    });

    _connectivityService.setOnConnectionRestored(() {
      print('✅ Connexion rétablie - Gestionnaire notifié');
      _onConnectionRestored();
    });
  }

  /// Gérer la perte de connexion
  void _onConnectionLost() {
    if (_currentContext != null && !_isDialogShowing) {
      _showConnectionLostDialog();
    }
  }

  /// Gérer la restauration de connexion
  void _onConnectionRestored() {
    if (_currentContext != null) {
      _showConnectionRestoredSnackBar();
      _processPendingOperations();
    }
  }

  /// Afficher le dialog de perte de connexion
  void _showConnectionLostDialog() {
    if (_currentContext == null || _isDialogShowing) return;

    _isDialogShowing = true;

    showConnectionLostDialog(
      _currentContext!,
      title: 'Connexion Internet Perdue',
      message:
          'Votre connexion internet a été interrompue.\nVos données sont sauvegardées localement.',
      onRetry: () {
        _isDialogShowing = false;
        _retryConnection();
      },
      onSaveOffline: () {
        _isDialogShowing = false;
        _saveCurrentDataOffline();
      },
    ).then((result) {
      _isDialogShowing = false;
      if (result == true) {
        // Connexion rétablie
        _processPendingOperations();
      }
    });
  }

  /// Afficher le SnackBar de reconnexion
  void _showConnectionRestoredSnackBar() {
    if (_currentContext == null) return;

    showConnectionRestoredSnackBar(
      _currentContext!,
      message: 'Internet disponible',
      onAction: () {
        _processPendingOperations();
      },
      actionLabel: 'Synchroniser',
    );
  }

  /// Réessayer la connexion
  void _retryConnection() async {
    print('🔄 Tentative de reconnexion...');

    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      // Attendre la reconnexion
      final restored = await _connectivityService.waitForConnection();
      if (restored) {
        _processPendingOperations();
      }
    }
  }

  /// Sauvegarder les données actuelles hors ligne
  void _saveCurrentDataOffline() {
    print('💾 Sauvegarde des données actuelles...');
    // Cette méthode sera appelée par les pages spécifiques
  }

  /// Traiter les opérations en attente
  void _processPendingOperations() async {
    print('📋 Traitement des opérations en attente...');
    await _firebaseRetry.processPendingOperations();
  }

  /// Définir le contexte actuel
  void setCurrentContext(BuildContext context) {
    _currentContext = context;
  }

  /// Nettoyer le contexte
  void clearCurrentContext() {
    _currentContext = null;
  }

  /// Vérifier la connexion
  Future<bool> checkConnection() async {
    return await _connectivityService.checkConnectivity();
  }

  /// Attendre la connexion
  Future<bool> waitForConnection(
      {Duration timeout = const Duration(seconds: 30)}) async {
    return await _connectivityService.waitForConnection(timeout: timeout);
  }

  /// Exécuter une opération avec gestion de connexion
  Future<T> executeWithConnectionHandling<T>(
    Future<T> Function() operation, {
    String? operationType,
    Map<String, dynamic>? fallbackData,
    bool showDialog = true,
  }) async {
    try {
      // Vérifier la connexion avant l'opération
      final isConnected = await checkConnection();
      if (!isConnected && showDialog) {
        _onConnectionLost();
        throw Exception('Pas de connexion internet');
      }

      // Exécuter l'opération avec retry
      return await _firebaseRetry.executeWithRetry(
        operation,
        operationType: operationType,
        fallbackData: fallbackData,
      );
    } catch (e) {
      print('❌ Erreur lors de l\'exécution: $e');
      rethrow;
    }
  }

  /// Sauvegarder des données d'inscription
  Future<void> saveRegistrationData(Map<String, dynamic> data) async {
    await _offlineStorage.saveUserRegistrationData(data);
  }

  /// Sauvegarder des données de colis
  Future<void> saveParcelData(Map<String, dynamic> data) async {
    await _offlineStorage.saveParcelData(data);
  }

  /// Sauvegarder des données de commande
  Future<void> saveOrderData(Map<String, dynamic> data) async {
    await _offlineStorage.saveOrderData(data);
  }

  /// Récupérer les données d'inscription
  Future<Map<String, dynamic>?> getRegistrationData() async {
    return await _offlineStorage.getUserRegistrationData();
  }

  /// Récupérer les données de colis
  Future<Map<String, dynamic>?> getParcelData() async {
    return await _offlineStorage.getParcelData();
  }

  /// Récupérer les données de commande
  Future<Map<String, dynamic>?> getOrderData() async {
    return await _offlineStorage.getOrderData();
  }

  /// Vérifier s'il y a des données hors ligne
  Future<bool> hasOfflineData() async {
    return await _offlineStorage.hasOfflineData();
  }

  /// Nettoyer toutes les données hors ligne
  Future<void> clearOfflineData() async {
    await _offlineStorage.clearAllOfflineData();
  }

  /// Forcer la vérification de connectivité (utile pour les émulateurs)
  Future<void> forceConnectivityCheck() async {
    await _connectivityService.forceConnectivityCheck();
  }

  /// Obtenir le statut actuel de connectivité
  bool get isConnected => _connectivityService.currentConnectionStatus;

  /// Libérer les ressources
  void dispose() {
    _connectivityService.dispose();
    _currentContext = null;
    _isDialogShowing = false;
  }
}
