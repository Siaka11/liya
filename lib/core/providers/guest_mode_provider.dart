import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liya/config/app_information.dart';
import '../singletons.dart';

/// Provider pour gérer le mode invité (guest mode)
/// Permet aux utilisateurs iOS d'accéder à l'app sans inscription
class GuestModeNotifier extends ChangeNotifier {
  bool _isGuestMode = false;
  bool _initialized = false;

  /// Retourne true seulement si le mode invité est activé ET que l'utilisateur n'est pas authentifié
  /// Si l'utilisateur est authentifié, le mode invité est automatiquement désactivé
  bool get isGuestMode {
    // Initialiser de manière lazy au premier accès
    if (!_initialized) {
      _initializeGuestModeLazy();
    }

    // Vérifier l'authentification
    try {
      final prefs = singleton<SharedPreferences>();
      final isAuth = prefs.getBool(Config.ISAUTH) ?? false;

      // Si l'utilisateur est authentifié, retourner false (le mode invité est désactivé)
      if (isAuth) {
        return false;
      }
    } catch (e) {
      // Si le singleton n'est pas encore disponible, retourner la valeur actuelle
      // Ne pas logger pour éviter le spam
    }

    return _isGuestMode;
  }

  /// Initialise le mode invité de manière lazy (seulement au premier accès)
  void _initializeGuestModeLazy() {
    try {
      final prefs = singleton<SharedPreferences>();
      final isAuth = prefs.getBool(Config.ISAUTH) ?? false;
      _isGuestMode = prefs.getBool('is_guest_mode') ?? false;

      // Si l'utilisateur est authentifié, désactiver automatiquement le mode invité
      if (isAuth && _isGuestMode) {
        _isGuestMode = false;
        prefs.setBool('is_guest_mode', false);
        print('🔄 Mode invité désactivé (utilisateur authentifié)');
      }

      _initialized = true;
    } catch (e) {
      // Si le singleton n'est pas encore disponible, initialiser plus tard
      _isGuestMode = false;
      _initialized = false; // Réessayer au prochain accès
    }
  }

  /// Vérifie si l'utilisateur est en mode invité
  /// Désactive automatiquement le mode invité si l'utilisateur est authentifié
  Future<bool> checkGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool(Config.ISAUTH) ?? false;
      _isGuestMode = prefs.getBool('is_guest_mode') ?? false;

      // Si l'utilisateur est authentifié, désactiver automatiquement le mode invité
      if (isAuth && _isGuestMode) {
        _isGuestMode = false;
        await prefs.setBool('is_guest_mode', false);
        notifyListeners();
        print(
            '🔄 Mode invité désactivé automatiquement (utilisateur authentifié)');
        return false;
      }

      notifyListeners();
      return _isGuestMode;
    } catch (e) {
      print('❌ Erreur vérification mode invité: $e');
      return false;
    }
  }

  /// Active le mode invité (uniquement sur iOS)
  Future<void> enableGuestMode() async {
    try {
      // Vérifier qu'on est sur iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_guest_mode', true);
        _isGuestMode = true;
        notifyListeners();
        print('✅ Mode invité activé (iOS)');
      } else {
        print('⚠️ Mode invité non disponible sur Android');
      }
    } catch (e) {
      print('❌ Erreur activation mode invité: $e');
    }
  }

  /// Désactive le mode invité et force l'inscription
  Future<void> disableGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest_mode', false);
      _isGuestMode = false;
      notifyListeners();
      print('✅ Mode invité désactivé');
    } catch (e) {
      print('❌ Erreur désactivation mode invité: $e');
    }
  }

  /// Vérifie si le mode invité est disponible sur cette plateforme
  bool isGuestModeAvailable() {
    return defaultTargetPlatform == TargetPlatform.iOS;
  }
}

/// Provider Riverpod pour le mode invité
final guestModeProvider = ChangeNotifierProvider<GuestModeNotifier>((ref) {
  return GuestModeNotifier();
});
