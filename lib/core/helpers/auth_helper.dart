import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:liya/modules/auth/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liya/config/app_information.dart';
import 'package:liya/core/singletons.dart';

/// Helper pour gérer les vérifications d'authentification
/// S'inspire de l'approche Glovo: accès libre en lecture, inscription pour actions
class AuthHelper {
  /// Vérifie si l'utilisateur est authentifié avant une action critique
  /// Utilise EXACTEMENT les mêmes conditions que _buildGuestModeBanner
  /// Le dialog n'apparaît QUE si le banner serait visible
  /// Retourne true si l'utilisateur peut continuer, false sinon
  static Future<bool> requireAuth(
    BuildContext context,
    WidgetRef ref, {
    String? actionName,
  }) async {
    // PRIORITÉ ABSOLUE: Vérifier d'abord le mode invité AVANT toute autre vérification
    // Utiliser EXACTEMENT les mêmes conditions que _buildGuestModeBanner
    // Le banner vérifie : guestMode.isGuestMode && defaultTargetPlatform == TargetPlatform.iOS
    // guestMode.isGuestMode vérifie : is_guest_mode == true ET isAuth == false
    try {
      final prefs = singleton<SharedPreferences>();
      final isAuth = prefs.getBool(Config.ISAUTH) ?? false;
      final isGuestModePref = prefs.getBool('is_guest_mode') ?? false;
      final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

      // EXACTEMENT les mêmes conditions que _buildGuestModeBanner :
      // - is_guest_mode == true dans SharedPreferences
      // - isAuth == false (l'utilisateur n'est pas authentifié)
      // - defaultTargetPlatform == TargetPlatform.iOS
      if (isGuestModePref && !isAuth && isIOS) {
        // Mêmes conditions que le banner → afficher le dialog
        // MÊME si l'utilisateur a des données utilisateur, on affiche le dialog en mode invité
        return await _showAuthRequiredDialog(context, ref, actionName);
      }
    } catch (e) {
      // Si erreur, continuer avec les autres vérifications
    }

    // PRIORITÉ 2: Si l'utilisateur est authentifié (après vérification du mode invité), on continue
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      return true;
    }

    // PRIORITÉ 3: Si l'utilisateur a des données utilisateur (nom, localisation, etc.), il est considéré comme authentifié
    // Cela résout le cas où l'utilisateur a ses infos visibles mais isAuthenticated est false
    // MAIS seulement si on n'est PAS en mode invité (déjà vérifié ci-dessus)
    if (authState.currentUser != null) {
      final userInfo = authState.currentUser!;
      // Vérifier que les données utilisateur sont valides (au moins un nom ou un numéro de téléphone)
      if ((userInfo['name'] != null &&
              userInfo['name'].toString().isNotEmpty) ||
          (userInfo['phoneNumber'] != null &&
              userInfo['phoneNumber'].toString().isNotEmpty)) {
        // L'utilisateur a des données utilisateur valides, il est authentifié
        return true;
      }
    }

    // Si les conditions du banner ne sont pas remplies, bloquer l'action sans afficher de dialog
    // (comme le banner n'est pas visible, le dialog ne devrait pas l'être non plus)
    return false;
  }

  /// Affiche un bottom sheet demandant à l'utilisateur de s'inscrire
  static Future<bool> _showAuthRequiredDialog(
    BuildContext context,
    WidgetRef ref,
    String? actionName,
  ) async {
    final action = actionName ?? 'cette action';

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône et titre
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_add,
                        color: Colors.orange.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inscription requise',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pour $action',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Message informatif
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vous serez redirigé vers la page d\'authentification..',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(bottomSheetContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(bottomSheetContext).pop(false);
                          // Remplacer la navigation actuelle par la page d'authentification
                          // L'utilisateur restera sur AuthRoute même s'il est en mode invité
                          Future.microtask(() {
                            AutoRouter.of(context)
                                .replaceAll([const AuthRoute()]);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Espace pour le safe area
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  /// Affiche un SnackBar simple pour informer l'utilisateur
  static void showAuthRequiredSnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Inscription requise pour $action',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'S\'inscrire',
          textColor: Colors.white,
          onPressed: () {
            context.router.push(const AuthRoute());
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
