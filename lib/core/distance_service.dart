import 'dart:math';

class DistanceService {
  // Coordonnées du restaurant (Yamoussoukro - centre ville)
  static const double restaurantLatitude = 6.8270;
  static const double restaurantLongitude = -5.2890;

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
    // Estimation pour livraisons locales à Yamoussoukro :
    // - Temps de base : 10 minutes
    // - 3 minutes par km pour les distances locales
    const int baseTime = 10; // minutes
    const double timePerKm = 3.0; // minutes par km

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

    if (distanceInKm <= 4) {
      return 500;
    } else if (distanceInKm <= 10) {
      return 1000;
    } else if (distanceInKm <= 15) {
      return 1500;
    } else if (distanceInKm <= 20) {
      return 2000;
    } else if (distanceInKm <= 30) {
      return 3000;
    } else if (distanceInKm <= 60) {
      return 5000;
    }else {
      return 1000;
    }
  }

  /// Formate les frais de livraison pour l'affichage
  static String formatDeliveryFee(int fee) {
    return '${fee} FCFA';
  }
}
