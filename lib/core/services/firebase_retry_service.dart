import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'offline_storage_service.dart';

/// Service de retry intelligent pour Firebase
class FirebaseRetryService {
  static final FirebaseRetryService _instance =
      FirebaseRetryService._internal();
  factory FirebaseRetryService() => _instance;
  FirebaseRetryService._internal();

  final OfflineStorageService _offlineStorage = OfflineStorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Configuration du retry
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(seconds: 30);

  /// Exécuter une opération Firebase avec retry automatique
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    String? operationType,
    Map<String, dynamic>? fallbackData,
    bool saveOffline = true,
  }) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < _maxRetries) {
      try {
        print('🔄 Tentative ${attempt + 1}/$_maxRetries pour $operationType');

        final result = await operation();

        if (attempt > 0) {
          print('✅ Opération réussie après ${attempt + 1} tentatives');
        }

        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;

        print('❌ Tentative ${attempt} échouée: $e');

        // Vérifier si c'est une erreur de réseau
        if (_isNetworkError(e)) {
          if (saveOffline && fallbackData != null && operationType != null) {
            await _offlineStorage.addPendingOperation(
                operationType, fallbackData);
            print('💾 Opération sauvegardée pour retry ultérieur');
          }

          if (attempt < _maxRetries) {
            final delay = _calculateDelay(attempt);
            print(
                '⏳ Attente de ${delay.inSeconds}s avant nouvelle tentative...');
            await Future.delayed(delay);
          }
        } else {
          // Erreur non-réseau, pas de retry
          print('❌ Erreur non-réseau, pas de retry: $e');
          break;
        }
      }
    }

    print('❌ Toutes les tentatives échouées pour $operationType');
    throw lastException ??
        Exception('Opération échouée après $_maxRetries tentatives');
  }

  /// Créer un utilisateur avec retry
  Future<UserCredential> createUserWithRetry({
    required String email,
    required String password,
    Map<String, dynamic>? additionalData,
  }) async {
    return await executeWithRetry(
      () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
      operationType: 'user_registration',
      fallbackData: {
        'email': email,
        'password': password,
        'additionalData': additionalData,
      },
    );
  }

  /// Se connecter avec retry
  Future<UserCredential> signInWithRetry({
    required String email,
    required String password,
  }) async {
    return await executeWithRetry(
      () => _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
      operationType: 'user_signin',
      fallbackData: {
        'email': email,
        'password': password,
      },
    );
  }

  /// Sauvegarder des données Firestore avec retry
  Future<void> saveToFirestoreWithRetry({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    return await executeWithRetry(
      () => _firestore.collection(collection).doc(documentId).set(data),
      operationType: 'firestore_save',
      fallbackData: {
        'collection': collection,
        'documentId': documentId,
        'data': data,
      },
    );
  }

  /// Lire des données Firestore avec retry
  Future<DocumentSnapshot> readFromFirestoreWithRetry({
    required String collection,
    required String documentId,
  }) async {
    return await executeWithRetry(
      () => _firestore.collection(collection).doc(documentId).get(),
      operationType: 'firestore_read',
      fallbackData: {
        'collection': collection,
        'documentId': documentId,
      },
    );
  }

  /// Traiter les opérations en attente
  Future<void> processPendingOperations() async {
    try {
      final pendingOps = await _offlineStorage.getPendingOperations();
      print('📋 Traitement de ${pendingOps.length} opérations en attente...');

      for (int i = 0; i < pendingOps.length; i++) {
        final operation = pendingOps[i];
        try {
          await _processOperation(operation);
          await _offlineStorage.removePendingOperation(i);
          print('✅ Opération ${operation['type']} traitée avec succès');
        } catch (e) {
          print('❌ Erreur traitement opération ${operation['type']}: $e');
          // Garder l'opération pour un retry ultérieur
        }
      }
    } catch (e) {
      print('❌ Erreur traitement opérations en attente: $e');
    }
  }

  /// Traiter une opération spécifique
  Future<void> _processOperation(Map<String, dynamic> operation) async {
    final type = operation['type'] as String;
    final data = operation['data'] as Map<String, dynamic>;

    switch (type) {
      case 'user_registration':
        await _processUserRegistration(data);
        break;
      case 'user_signin':
        await _processUserSignIn(data);
        break;
      case 'firestore_save':
        await _processFirestoreSave(data);
        break;
      case 'firestore_read':
        await _processFirestoreRead(data);
        break;
      default:
        print('⚠️ Type d\'opération non reconnu: $type');
    }
  }

  /// Traiter l'inscription utilisateur
  Future<void> _processUserRegistration(Map<String, dynamic> data) async {
    final email = data['email'] as String;
    final password = data['password'] as String;
    final additionalData = data['additionalData'] as Map<String, dynamic>?;

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (additionalData != null && userCredential.user != null) {
      await userCredential.user!
          .updateDisplayName(additionalData['displayName']);
    }
  }

  /// Traiter la connexion utilisateur
  Future<void> _processUserSignIn(Map<String, dynamic> data) async {
    final email = data['email'] as String;
    final password = data['password'] as String;

    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Traiter la sauvegarde Firestore
  Future<void> _processFirestoreSave(Map<String, dynamic> data) async {
    final collection = data['collection'] as String;
    final documentId = data['documentId'] as String;
    final docData = data['data'] as Map<String, dynamic>;

    await _firestore.collection(collection).doc(documentId).set(docData);
  }

  /// Traiter la lecture Firestore
  Future<void> _processFirestoreRead(Map<String, dynamic> data) async {
    final collection = data['collection'] as String;
    final documentId = data['documentId'] as String;

    await _firestore.collection(collection).doc(documentId).get();
  }

  /// Vérifier si c'est une erreur de réseau
  bool _isNetworkError(dynamic error) {
    if (error is FirebaseAuthException) {
      return error.code == 'network-request-failed' ||
          error.code == 'too-many-requests';
    }

    if (error is FirebaseException) {
      return error.code == 'unavailable' || error.code == 'deadline-exceeded';
    }

    // Vérifier les messages d'erreur courants
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout') ||
        errorMessage.contains('unreachable');
  }

  /// Calculer le délai de retry avec backoff exponentiel
  Duration _calculateDelay(int attempt) {
    final delay = _baseDelay * pow(2, attempt);
    return delay > _maxDelay ? _maxDelay : delay;
  }
}
