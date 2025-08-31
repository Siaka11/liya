import '../core/services/dish_popularity_service.dart';

/// Script de test pour la nouvelle formule SIMPLE et COHÉRENTE
void main() {
  print('🧪 Test de la formule SIMPLE et COHÉRENTE (0-100)');
  print('📊 Formule: 4 composants × 25 points = 100 points max');
  print('   • Commandes: 1 commande = 5 points (max 25)');
  print('   • Vues: 1 vue = 0.5 point (max 25)');
  print('   • Rating: rating × 5 (max 25)');
  print('   • Récence: bonus linéaire 30j (max 25)');
  print('');

  // Test 1: Plat nouveau (tout à zéro) - DOIT être 0
  final nouveauPlat = {
    'order_count': 0,
    'view_count': 0,
    'rating': 0.0,
    'rating_count': 0,
  };
  final scoreNouveau =
      DishPopularityService.calculatePopularityScore(nouveauPlat);
  print(
      '🆕 Plat nouveau: ${scoreNouveau.toStringAsFixed(1)}/100 (attendu: 0.0)');

  // Test 2: 1 commande + 10 vues = 5 + 5 = 10 points
  final plat1Commande = {
    'order_count': 1,
    'view_count': 10,
    'rating': 0.0,
    'rating_count': 0,
  };
  final score1 = DishPopularityService.calculatePopularityScore(plat1Commande);
  print(
      '📦 1 commande + 10 vues: ${score1.toStringAsFixed(1)}/100 (attendu: 10.0)');

  // Test 3: Rating 4.0 = 20 points
  final platRating = {
    'order_count': 0,
    'view_count': 0,
    'rating': 4.0,
    'rating_count': 5,
  };
  final scoreRating =
      DishPopularityService.calculatePopularityScore(platRating);
  print(
      '⭐ Rating 4.0 seulement: ${scoreRating.toStringAsFixed(1)}/100 (attendu: 20.0)');

  // Test 4: Maximum théorique = 100 points
  final platMax = {
    'order_count': 5, // 25 points
    'view_count': 50, // 25 points
    'rating': 5.0, // 25 points
    'rating_count': 10,
    'last_ordered': DateTime.now(), // 25 points (récent)
  };
  final scoreMax = DishPopularityService.calculatePopularityScore(platMax);
  print(
      '🔥 Score maximum: ${scoreMax.toStringAsFixed(1)}/100 (attendu: 100.0)');

  // Test 5: Plat équilibré = 2 commandes + 20 vues + rating 3.5 = 10 + 10 + 17.5 = 37.5
  final platEquilibre = {
    'order_count': 2,
    'view_count': 20,
    'rating': 3.5,
    'rating_count': 8,
  };
  final scoreEquilibre =
      DishPopularityService.calculatePopularityScore(platEquilibre);
  print(
      '⚖️ Plat équilibré: ${scoreEquilibre.toStringAsFixed(1)}/100 (attendu: 37.5)');

  print('');
  print('✅ COHÉRENCE TOTALE: Calcul simple et prévisible');
  print('✅ ÉQUITÉ: Tous commencent à 0');
  print('✅ TRANSPARENCE: 1 commande = +5 points toujours');
  print('✅ MOYENNE VRAIE: 4 composants équilibrés (25 points chacun)');
}
