import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour gérer le mode invité (guest mode)
/// Permet aux utilisateurs iOS d'accéder à l'app sans inscription
class GuestModeNotifier extends ChangeNotifier {
  bool _isGuestMode = false;

  bool get isGuestMode => _isGuestMode;

  /// Vérifie si l'utilisateur est en mode invité
  Future<bool> checkGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isGuestMode = prefs.getBool('is_guest_mode') ?? false;
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

