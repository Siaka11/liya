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

    // Si l'utilisateur est déjà authentifié, on continue
    if (authState.isAuthenticated) {
      return true;
    }

    // Si l'utilisateur est en mode invité, on demande l'inscription
    if (guestMode.isGuestMode) {
      return await _showAuthRequiredDialog(context, actionName);
    }

    // Cas où l'utilisateur n'est ni authentifié ni en mode invité
    return await _showAuthRequiredDialog(context, actionName);
  }

  /// Affiche une popup demandant à l'utilisateur de s'inscrire
  static Future<bool> _showAuthRequiredDialog(
    BuildContext context,
    String? actionName,
  ) async {
    final action = actionName ?? 'cette action';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Inscription requise',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pour $action, vous devez créer un compte.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'C\'est rapide et gratuit !',
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
                // Navigation vers la page d'authentification
                context.router.push(const AuthRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'S\'inscrire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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

