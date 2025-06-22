import 'dart:math';

class DistanceService {
  // Coordonnées du restaurant (Yamoussoukro)
  static const double restaurantLatitude = 6.812874913445291;
  static const double restaurantLongitude = -5.2320368359093345;

  /// Calcule la distance entre deux points GPS en utilisant la formule de Haversine
  /// Retourne la distance en kilomètres
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Rayon de la Terre en kilomètres

    // Conversion des degrés en radians
    final double lat1Rad = _degreesToRadians(lat1);
    final double lon1Rad = _degreesToRadians(lon1);
    final double lat2Rad = _degreesToRadians(lat2);
    final double lon2Rad = _degreesToRadians(lon2);

    // Différences des coordonnées
    final double deltaLat = lat2Rad - lat1Rad;
    final double deltaLon = lon2Rad - lon1Rad;

    // Formule de Haversine
    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Distance en kilomètres
    return earthRadius * c;
  }

  /// Calcule la distance entre la position de l'utilisateur et le restaurant
  /// Retourne la distance en kilomètres
  static double calculateDistanceToRestaurant(double userLat, double userLon) {
    return calculateDistance(
        userLat, userLon, restaurantLatitude, restaurantLongitude);
  }

  /// Convertit les degrés en radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Formate la distance pour l'affichage
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      // Si moins d'1 km, afficher en mètres
      final meters = (distanceInKm * 1000).round();
      return '${meters}m';
    } else {
      // Sinon afficher en kilomètres avec une décimale
      return '${distanceInKm.toStringAsFixed(1)}km';
    }
  }

  /// Calcule le temps de livraison estimé basé sur la distance
  /// Retourne le temps en minutes
  static int calculateDeliveryTime(double distanceInKm) {
    // Estimation : 5 minutes de base + 2 minutes par km
    const int baseTime = 5; // minutes
    const double timePerKm = 2.0; // minutes par km

    return (baseTime + (distanceInKm * timePerKm)).round();
  }

  /// Formate le temps de livraison pour l'affichage
  static String formatDeliveryTime(int minutes) {
    if (minutes < 60) {
      return '${minutes} min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  /// Calcule les frais de livraison basés sur la distance
  /// Retourne les frais en FCFA
  static int calculateDeliveryFee(double distanceInKm) {
    // Tarification progressive :
    // - 0-5 km : 500 FCFA
    // - 5-10 km : 750 FCFA
    // - 10-15 km : 1000 FCFA
    // - 15+ km : 1250 FCFA

    if (distanceInKm <= 5) {
      return 500;
    } else if (distanceInKm <= 10) {
      return 750;
    } else if (distanceInKm <= 15) {
      return 1000;
    } else {
      return 1250;
    }
  }

  /// Formate les frais de livraison pour l'affichage
  static String formatDeliveryFee(int fee) {
    return '${fee} FCFA';
  }
}
