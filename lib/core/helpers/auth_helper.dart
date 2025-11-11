import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:liya/routes/app_router.gr.dart';
import 'package:liya/modules/auth/auth_provider.dart';
import 'package:liya/core/providers/guest_mode_provider.dart';

/// Helper pour gérer les vérifications d'authentification
/// S'inspire de l'approche Glovo: accès libre en lecture, inscription pour actions
class AuthHelper {
  /// Vérifie si l'utilisateur est authentifié avant une action critique
  /// Si non authentifié, affiche une popup pour demander l'inscription
  /// Retourne true si l'utilisateur peut continuer, false sinon
  static Future<bool> requireAuth(
    BuildContext context,
    WidgetRef ref, {
    String? actionName,
  }) async {
    final authState = ref.read(authProvider);
    final guestMode = ref.read(guestModeProvider);

    // Si l'utilisateur est en mode invité, on demande l'inscription
    if (guestMode.isGuestMode) {
      return await _showAuthRequiredDialog(context, ref, actionName);
    }

    // Si l'utilisateur est déjà authentifié, on continue
    if (authState.isAuthenticated) {
      return true;
    }

    // Cas où l'utilisateur n'est ni authentifié ni en mode invité
    return await _showAuthRequiredDialog(context, ref, actionName);
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
                          'Vous serez redirigé vers la page d\'authentification pour créer un compte.',
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
                        onPressed: () => Navigator.of(bottomSheetContext).pop(false),
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
                          'S\'inscrire',
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

