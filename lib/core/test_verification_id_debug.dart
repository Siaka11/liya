import 'package:shared_preferences/shared_preferences.dart';

/// Script de debug pour tester le problème de verificationId
class VerificationIdDebug {
  /// Vérifier l'état actuel du verificationId
  static Future<void> checkVerificationIdStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('🔍 === DEBUG VERIFICATION ID ===');

      // Vérifier si le verificationId existe
      final verificationId = prefs.getString('verification_id');
      print('📝 VerificationId: ${verificationId ?? "NULL"}');

      if (verificationId != null) {
        print('📝 Longueur: ${verificationId.length}');
        print('📝 Début: ${verificationId.substring(0, 10)}...');
      }

      // Vérifier le timestamp
      final timestamp = prefs.getInt('verification_id_timestamp');
      print('⏰ Timestamp: $timestamp');

      if (timestamp != null) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        final difference = now.difference(dateTime);
        print('⏰ Date de création: $dateTime');
        print('⏰ Maintenant: $now');
        print('⏰ Différence: ${difference.inMinutes} minutes');

        // Vérifier si expiré (plus de 10 minutes)
        if (difference.inMinutes > 10) {
          print('⚠️ VERIFICATION ID EXPIRÉ !');
        } else {
          print('✅ Verification ID valide');
        }
      } else {
        print('❌ Pas de timestamp');
      }

      // Lister toutes les clés pour debug
      print('🔑 Toutes les clés SharedPreferences:');
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.contains('verification') || key.contains('auth')) {
          print('  - $key: ${prefs.get(key)}');
        }
      }

      print('🔍 === FIN DEBUG ===');
    } catch (e) {
      print('❌ Erreur debug verificationId: $e');
    }
  }

  /// Nettoyer le verificationId pour forcer un nouveau
  static Future<void> clearVerificationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('verification_id');
      await prefs.remove('verification_id_timestamp');
      print('🗑️ VerificationId nettoyé');
    } catch (e) {
      print('❌ Erreur nettoyage verificationId: $e');
    }
  }

  /// Simuler un verificationId pour test
  static Future<void> simulateVerificationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fakeId =
          'test_verification_id_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('verification_id', fakeId);
      await prefs.setInt(
          'verification_id_timestamp', DateTime.now().millisecondsSinceEpoch);
      print('🧪 VerificationId simulé: $fakeId');
    } catch (e) {
      print('❌ Erreur simulation verificationId: $e');
    }
  }
}
