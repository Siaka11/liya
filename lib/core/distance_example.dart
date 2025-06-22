import 'distance_service.dart';

/// Exemple d'utilisation du service de calcul de distance
class DistanceExample {
  static void demonstrateDistanceCalculation() {
    print('=== Exemple de calcul de distance ===\n');

    // Coordonnées du restaurant (Yamoussoukro)
    const restaurantLat = 6.812874913445291;
    const restaurantLng = -5.2320368359093345;

    // Exemples de positions utilisateur
    final userPositions = [
      {'name': 'Centre-ville Yamoussoukro', 'lat': 6.8276, 'lng': -5.2893},
      {'name': 'Zone industrielle', 'lat': 6.8500, 'lng': -5.3000},
      {'name': 'Quartier résidentiel', 'lat': 6.8000, 'lng': -5.2500},
      {'name': 'Zone périphérique', 'lat': 6.9000, 'lng': -5.3500},
    ];

    for (final position in userPositions) {
      final distance = DistanceService.calculateDistanceToRestaurant(
          position['lat'] as double, position['lng'] as double);

      final deliveryTime = DistanceService.calculateDeliveryTime(distance);
      final deliveryFee = DistanceService.calculateDeliveryFee(distance);

      print('📍 ${position['name']}:');
      print('   Distance: ${DistanceService.formatDistance(distance)}');
      print(
          '   Temps de livraison: ${DistanceService.formatDeliveryTime(deliveryTime)}');
      print(
          '   Frais de livraison: ${DistanceService.formatDeliveryFee(deliveryFee)}');
      print('');
    }

    print('=== Tarification des frais de livraison ===');
    print('• 0-5 km: 500 FCFA');
    print('• 5-10 km: 750 FCFA');
    print('• 10-15 km: 1000 FCFA');
    print('• 15+ km: 1250 FCFA');
  }

  /// Méthode pour tester le calcul avec des coordonnées spécifiques
  static void testSpecificLocation(
      double userLat, double userLng, String locationName) {
    print('\n=== Test pour $locationName ===');

    final distance =
        DistanceService.calculateDistanceToRestaurant(userLat, userLng);
    final deliveryTime = DistanceService.calculateDeliveryTime(distance);
    final deliveryFee = DistanceService.calculateDeliveryFee(distance);

    print('Coordonnées utilisateur: $userLat, $userLng');
    print(
        'Coordonnées restaurant: ${DistanceService.restaurantLatitude}, ${DistanceService.restaurantLongitude}');
    print('Distance calculée: ${DistanceService.formatDistance(distance)}');
    print(
        'Temps de livraison: ${DistanceService.formatDeliveryTime(deliveryTime)}');
    print(
        'Frais de livraison: ${DistanceService.formatDeliveryFee(deliveryFee)}');
  }
}
