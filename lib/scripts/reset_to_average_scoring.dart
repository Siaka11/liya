import 'package:firebase_core/firebase_core.dart';
import '../core/services/dish_popularity_service.dart';
import '../firebase_options.dart';

/// Script pour réinitialiser à la moyenne normalisée (0-100)
///
/// Ce script:
/// 1. Remet toutes les données de popularité à zéro
/// 2. Supprime les valeurs par défaut artificielles
/// 3. Recalcule avec la nouvelle formule de moyenne normalisée (0-100)
///
/// Nouvelle formule SIMPLE et COHÉRENTE:
/// - Commandes: 25 points max (1 commande = 5 points)
/// - Vues: 25 points max (1 vue = 0.5 point)
/// - Ratings: 25 points max (rating × 5)
/// - Récence: 25 points max (bonus linéaire 30 jours)
/// = Total: 4 × 25 = 100 points maximum
Future<void> main() async {
  print('🚀 Démarrage de la réinitialisation à la moyenne normalisée...');

  try {
    // Initialiser Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('✅ Firebase initialisé');

    print('');
    print('📊 ÉTAPE 1: Remise à zéro de toutes les données artificielles...');
    await DishPopularityService.resetAllPopularityToZero();

    print('');
    print('📊 ÉTAPE 2: Recalcul avec la formule de moyenne normalisée...');
    await DishPopularityService.recalculateAllPopularityScoresUnified();

    print('');
    print('🎉 SCRIPT TERMINÉ AVEC SUCCÈS !');
    print('');
    print('📊 NOUVELLE FORMULE SIMPLE ET COHÉRENTE (0-100):');
    print('   • Commandes: 25 points max (1 commande = 5 points)');
    print('   • Vues: 25 points max (1 vue = 0.5 point)');
    print('   • Ratings: 25 points max (rating × 5)');
    print('   • Récence: 25 points max (bonus linéaire 30 jours)');
    print('');
    print(
        '✅ Tous les plats commencent maintenant par 0 et évoluent naturellement !');
    print(
        '✅ Les sections "Populaires" et "Les plus commandés" sont équitables !');
  } catch (e) {
    print('❌ Erreur lors de l\'exécution du script: $e');
  }
}
