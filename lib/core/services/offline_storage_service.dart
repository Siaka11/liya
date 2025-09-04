import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de stockage local pour les données hors ligne
class OfflineStorageService {
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  static const String _keyPrefix = 'offline_data_';
  static const String _keyUserRegistration = '${_keyPrefix}user_registration';
  static const String _keyParcelData = '${_keyPrefix}parcel_data';
  static const String _keyOrderData = '${_keyPrefix}order_data';
  static const String _keyPendingOperations = '${_keyPrefix}pending_operations';

  /// Sauvegarder les données d'inscription utilisateur
  Future<void> saveUserRegistrationData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(userData);
      await prefs.setString(_keyUserRegistration, jsonData);
      print('💾 Données d\'inscription sauvegardées localement');
    } catch (e) {
      print('❌ Erreur sauvegarde inscription: $e');
    }
  }

  /// Récupérer les données d'inscription utilisateur
  Future<Map<String, dynamic>?> getUserRegistrationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_keyUserRegistration);
      if (jsonData != null) {
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Erreur récupération inscription: $e');
    }
    return null;
  }

  /// Sauvegarder les données de colis
  Future<void> saveParcelData(Map<String, dynamic> parcelData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(parcelData);
      await prefs.setString(_keyParcelData, jsonData);
      print('💾 Données de colis sauvegardées localement');
    } catch (e) {
      print('❌ Erreur sauvegarde colis: $e');
    }
  }

  /// Récupérer les données de colis
  Future<Map<String, dynamic>?> getParcelData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_keyParcelData);
      if (jsonData != null) {
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Erreur récupération colis: $e');
    }
    return null;
  }

  /// Sauvegarder les données de commande
  Future<void> saveOrderData(Map<String, dynamic> orderData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(orderData);
      await prefs.setString(_keyOrderData, jsonData);
      print('💾 Données de commande sauvegardées localement');
    } catch (e) {
      print('❌ Erreur sauvegarde commande: $e');
    }
  }

  /// Récupérer les données de commande
  Future<Map<String, dynamic>?> getOrderData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_keyOrderData);
      if (jsonData != null) {
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Erreur récupération commande: $e');
    }
    return null;
  }

  /// Ajouter une opération en attente
  Future<void> addPendingOperation(
      String operationType, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_keyPendingOperations);
      List<Map<String, dynamic>> operations = [];

      if (existingData != null) {
        final List<dynamic> decoded = jsonDecode(existingData);
        operations = decoded.cast<Map<String, dynamic>>();
      }

      operations.add({
        'type': operationType,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_keyPendingOperations, jsonEncode(operations));
      print('📝 Opération en attente ajoutée: $operationType');
    } catch (e) {
      print('❌ Erreur ajout opération en attente: $e');
    }
  }

  /// Récupérer les opérations en attente
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_keyPendingOperations);
      if (jsonData != null) {
        final List<dynamic> decoded = jsonDecode(jsonData);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('❌ Erreur récupération opérations en attente: $e');
    }
    return [];
  }

  /// Supprimer une opération en attente
  Future<void> removePendingOperation(int index) async {
    try {
      final operations = await getPendingOperations();
      if (index >= 0 && index < operations.length) {
        operations.removeAt(index);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyPendingOperations, jsonEncode(operations));
        print('🗑️ Opération en attente supprimée');
      }
    } catch (e) {
      print('❌ Erreur suppression opération en attente: $e');
    }
  }

  /// Vider toutes les opérations en attente
  Future<void> clearPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPendingOperations);
      print('🧹 Toutes les opérations en attente supprimées');
    } catch (e) {
      print('❌ Erreur suppression opérations en attente: $e');
    }
  }

  /// Nettoyer toutes les données sauvegardées
  Future<void> clearAllOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserRegistration);
      await prefs.remove(_keyParcelData);
      await prefs.remove(_keyOrderData);
      await prefs.remove(_keyPendingOperations);
      print('🧹 Toutes les données hors ligne supprimées');
    } catch (e) {
      print('❌ Erreur suppression données hors ligne: $e');
    }
  }

  /// Vérifier s'il y a des données sauvegardées
  Future<bool> hasOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserRegistration) != null ||
          prefs.getString(_keyParcelData) != null ||
          prefs.getString(_keyOrderData) != null ||
          prefs.getString(_keyPendingOperations) != null;
    } catch (e) {
      print('❌ Erreur vérification données hors ligne: $e');
      return false;
    }
  }
}
