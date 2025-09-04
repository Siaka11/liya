import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service de gestion de la connectivité réseau
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // État de la connexion
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // Stream pour écouter les changements de connexion
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  // Callbacks pour les événements de connexion
  VoidCallback? _onConnectionLost;
  VoidCallback? _onConnectionRestored;

  /// Initialiser le service de connectivité
  Future<void> initialize() async {
    print('🌐 Initialisation du service de connectivité...');

    // Vérifier l'état initial
    await _checkInitialConnectivity();

    // Écouter les changements de connectivité
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        print('❌ Erreur de connectivité: $error');
      },
    );

    print('✅ Service de connectivité initialisé');
  }

  /// Vérifier l'état initial de la connectivité
  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      print('🔍 Vérification initiale: $result');

      // Toujours vérifier la connectivité réelle sur émulateur
      await _checkRealConnectivity();
    } catch (e) {
      print('❌ Erreur lors de la vérification initiale: $e');
      _isConnected = false;
      _notifyConnectionChange(false);
    }
  }

  /// Gérer les changements de connectivité
  void _onConnectivityChanged(ConnectivityResult result) {
    print('🔄 Changement de connectivité détecté: $result');
    _updateConnectionStatus(result);
  }

  /// Mettre à jour le statut de connexion
  void _updateConnectionStatus(ConnectivityResult result) {
    print('🔄 Résultat de connectivité: $result');

    // Sur émulateur, vérifier aussi la connectivité réelle
    if (result == ConnectivityResult.none) {
      _checkRealConnectivity();
    } else {
      _isConnected = true;
      _notifyConnectionChange(true);
    }
  }

  /// Vérifier la connectivité réelle avec une requête HTTP
  Future<void> _checkRealConnectivity() async {
    try {
      print('🔍 Vérification de la connectivité réelle...');

      // Essayer de se connecter à un serveur fiable
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      final hasConnection =
          result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      print(
          '🌐 Connectivité réelle: ${hasConnection ? "CONNECTÉ" : "DÉCONNECTÉ"}');

      _isConnected = hasConnection;
      _notifyConnectionChange(hasConnection);
    } catch (e) {
      print('❌ Erreur vérification connectivité: $e');

      // Fallback: essayer avec un autre serveur
      try {
        print('🔄 Tentative avec un autre serveur...');
        final result2 = await InternetAddress.lookup('8.8.8.8')
            .timeout(const Duration(seconds: 3));

        final hasConnection2 =
            result2.isNotEmpty && result2[0].rawAddress.isNotEmpty;
        print(
            '🌐 Connectivité fallback: ${hasConnection2 ? "CONNECTÉ" : "DÉCONNECTÉ"}');

        _isConnected = hasConnection2;
        _notifyConnectionChange(hasConnection2);
      } catch (e2) {
        print('❌ Erreur vérification fallback: $e2');
        _isConnected = false;
        _notifyConnectionChange(false);
      }
    }
  }

  /// Notifier les changements de connexion
  void _notifyConnectionChange(bool isConnected) {
    final wasConnected = _isConnected;

    print('📡 Statut de connexion: ${isConnected ? "CONNECTÉ" : "DÉCONNECTÉ"}');

    // Notifier les changements
    _connectionController.add(isConnected);

    // Déclencher les callbacks
    if (wasConnected && !isConnected) {
      print('⚠️ Connexion perdue !');
      _onConnectionLost?.call();
    } else if (!wasConnected && isConnected) {
      print('✅ Connexion rétablie !');
      _onConnectionRestored?.call();
    }
  }

  /// Définir le callback pour la perte de connexion
  void setOnConnectionLost(VoidCallback callback) {
    _onConnectionLost = callback;
  }

  /// Définir le callback pour la restauration de connexion
  void setOnConnectionRestored(VoidCallback callback) {
    _onConnectionRestored = callback;
  }

  /// Vérifier manuellement la connectivité
  Future<bool> checkConnectivity() async {
    try {
      await _checkRealConnectivity();
      return _isConnected;
    } catch (e) {
      print('❌ Erreur lors de la vérification manuelle: $e');
      return false;
    }
  }

  /// Attendre que la connexion soit rétablie
  Future<bool> waitForConnection(
      {Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return true;

    print('⏳ Attente de la reconnexion...');

    final completer = Completer<bool>();
    late StreamSubscription subscription;

    subscription = connectionStream.listen((isConnected) {
      if (isConnected) {
        print('✅ Connexion rétablie !');
        subscription.cancel();
        completer.complete(true);
      }
    });

    // Timeout
    Timer(timeout, () {
      if (!completer.isCompleted) {
        print('⏰ Timeout de reconnexion atteint');
        subscription.cancel();
        completer.complete(false);
      }
    });

    return completer.future;
  }

  /// Forcer la vérification de connectivité (utile pour les émulateurs)
  Future<void> forceConnectivityCheck() async {
    print('🔄 Vérification forcée de la connectivité...');
    await _checkRealConnectivity();
  }

  /// Obtenir le statut actuel de connectivité
  bool get currentConnectionStatus => _isConnected;

  /// Libérer les ressources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionController.close();
    print('🗑️ Service de connectivité libéré');
  }
}
