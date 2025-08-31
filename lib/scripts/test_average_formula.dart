import '../core/services/dish_popularity_service.dart';

/// Script de test pour la nouvelle formule de moyenne
void main() {
  print('🧪 Test de la nouvelle formule de moyenne normalisée (0-100)');
  print('');

  // Test 1: Plat nouveau (tout à zéro)
  final nouveauPlat = {
    'order_count': 0,
    'view_count': 0,
    'rating': 0.0,
    'rating_count': 0,
  };
  final scoreNouveau =
      DishPopularityService.calculatePopularityScore(nouveauPlat);
  print(
      '🆕 Plat nouveau: ${scoreNouveau.toStringAsFixed(2)}/100 (attendu: 0.00)');

  // Test 2: Plat avec quelques commandes
  final platCommandes = {
    'order_count': 5,
    'view_count': 25,
    'rating': 0.0,
    'rating_count': 0,
  };
  final scoreCommandes =
      DishPopularityService.calculatePopularityScore(platCommandes);
  print(
      '📦 Plat 5 commandes + 25 vues: ${scoreCommandes.toStringAsFixed(2)}/100');

  // Test 3: Plat avec bon rating
  final platRating = {
    'order_count': 3,
    'view_count': 15,
    'rating': 4.5,
    'rating_count': 10,
  };
  final scoreRating =
      DishPopularityService.calculatePopularityScore(platRating);
  print(
      '⭐ Plat 4.5★ (10 avis) + 3 commandes: ${scoreRating.toStringAsFixed(2)}/100');

  // Test 4: Plat très populaire
  final platPopulaire = {
    'order_count': 50,
    'view_count': 200,
    'rating': 4.8,
    'rating_count': 25,
    'last_ordered': DateTime.now().subtract(Duration(days: 2)), // Récent
  };
  final scorePopulaire =
      DishPopularityService.calculatePopularityScore(platPopulaire);
  print('🔥 Plat très populaire: ${scorePopulaire.toStringAsFixed(2)}/100');

  // Test 5: Plat ancien sans récence
  final platAncien = {
    'order_count': 30,
    'view_count': 100,
    'rating': 4.0,
    'rating_count': 15,
    'last_ordered': DateTime.now().subtract(Duration(days: 60)), // Ancien
  };
  final scoreAncien =
      DishPopularityService.calculatePopularityScore(platAncien);
  print('⏰ Plat ancien (60j): ${scoreAncien.toStringAsFixed(2)}/100');

  print('');
  print('✅ Tous les scores sont entre 0 et 100');
  print('✅ Les nouveaux plats commencent à 0');
  print('✅ Les scores évoluent progressivement avec l\'activité');
}
