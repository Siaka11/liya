import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:geolocator/geolocator.dart';

class LocationPermissionService {
  /// Vérifie et demande les permissions de localisation
  static Future<bool> requestLocationPermission() async {
    try {
      // Vérifier si la localisation est activée
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Services de localisation désactivés');
        return false;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Demander la permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Permission de localisation refusée');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Permission de localisation refusée définitivement');
        return false;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        debugPrint('✅ Permission de localisation accordée');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erreur lors de la demande de permission: $e');
      return false;
    }
  }

  /// Vérifie si l'application a les permissions de localisation
  static Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification des permissions: $e');
      return false;
    }
  }

  /// Ouvre les paramètres de l'application pour les permissions
  static Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }

  /// Ouvre les paramètres de localisation du système
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Vérifie si les services de localisation sont activés
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtient la position actuelle avec gestion des erreurs
  static Future<Position?> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 15),
  }) async {
    try {
      // Vérifier les permissions d'abord
      if (!await hasLocationPermission()) {
        debugPrint('❌ Pas de permission de localisation');
        return null;
      }

      // Vérifier si la localisation est activée
      if (!await isLocationServiceEnabled()) {
        debugPrint('❌ Services de localisation désactivés');
        return null;
      }

      // Obtenir la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: desiredAccuracy,
        timeLimit: timeLimit,
      );

      debugPrint(
          '✅ Position obtenue: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  /// Écoute les changements de position
  static Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: locationSettings ??
          const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // 10 mètres
          ),
    );
  }

  /// Calcule la distance entre deux points
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Affiche un dialogue pour demander à l'utilisateur d'activer la localisation
  static Future<bool> showLocationPermissionDialog() async {
    // Cette méthode sera implémentée dans l'UI
    // Pour l'instant, on retourne true pour ouvrir les paramètres
    return true;
  }
}
