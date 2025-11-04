import 'package:firebase_core/firebase_core.dart';
import '../core/services/dish_popularity_service.dart';
import '../firebase_options.dart';

/// Script pour unifier tous les scores de popularité
///
/// Ce script recalcule tous les popularity_score en utilisant
/// la formule unifiée de DishPopularityService.calculatePopularityScore()
///
/// Usage:
/// 1. Lancer ce script une fois pour uniformiser tous les scores
/// 2. Tous les futurs calculs utiliseront automatiquement la formule unifiée
///
/// Formule unifiée:
/// score = (order_count * 15.0) + (rating * rating_count * 2.0) + (view_count * 0.1) + recency_bonus
///
/// où recency_bonus = 50.0 - (jours_depuis_dernière_commande * 7.0) si ≤ 7 jours, sinon 0
Future<void> main() async {
  print('🚀 Démarrage du script d\'unification des scores de popularité...');

  try {
    // Initialiser Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('✅ Firebase initialisé');

    // Exécuter la recalculation unifiée
    await DishPopularityService.recalculateAllPopularityScoresUnified();

    print('🎉 Script terminé avec succès !');
    print('');
    print('📊 Tous les plats utilisent maintenant la formule unifiée :');
    print(
        '   score = (order_count × 15) + (rating × rating_count × 2) + (view_count × 0.1) + bonus_récence');
    print('');
    print(
        '✅ Les sections "Populaires" et "Les plus commandés" sont maintenant synchronisées !');
  } catch (e) {
    print('❌ Erreur lors de l\'exécution du script: $e');
  }
}
