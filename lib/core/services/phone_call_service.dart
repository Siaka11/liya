import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneCallService {
  static const MethodChannel _channel = MethodChannel('phone_call_service');

  /// Demande la permission d'appel
  static Future<bool> requestCallPermission() async {
    try {
      final status = await Permission.phone.status;
      if (status.isGranted) {
        return true;
      }

      final result = await Permission.phone.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('Erreur permission: $e');
      return false;
    }
  }

  /// Nettoie le numéro de téléphone
  static String cleanPhoneNumber(String number) {
    return number.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Méthode principale pour passer un appel
  static Future<bool> makeCall(String phoneNumber) async {
    final cleanNumber = cleanPhoneNumber(phoneNumber);
    debugPrint('Tentative d\'appel vers: $cleanNumber');

    // Vérifier les permissions
    if (!await requestCallPermission()) {
      debugPrint('Permission d\'appel refusée');
      return false;
    }

    // Méthode 1: Intent natif Android via MethodChannel
    if (await _tryNativeCall(cleanNumber)) {
      return true;
    }

    // Méthode 2: url_launcher avec ACTION_CALL
    if (await _tryUrlLauncherCall(cleanNumber)) {
      return true;
    }

    // Méthode 3: url_launcher avec ACTION_DIAL (fallback)
    if (await _tryUrlLauncherDial(cleanNumber)) {
      return true;
    }

    debugPrint('Toutes les méthodes d\'appel ont échoué');
    return false;
  }

  /// Méthode 1: Intent natif Android
  static Future<bool> _tryNativeCall(String number) async {
    try {
      debugPrint('Tentative appel natif pour: $number');
      final result =
          await _channel.invokeMethod('makeCall', {'number': number});
      debugPrint('Résultat appel natif: $result');
      return result == true;
    } catch (e) {
      debugPrint('Erreur appel natif: $e');
      return false;
    }
  }

  /// Méthode 2: url_launcher avec ACTION_CALL
  static Future<bool> _tryUrlLauncherCall(String number) async {
    try {
      debugPrint('Tentative url_launcher CALL pour: $number');
      final Uri callUri = Uri.parse('tel:$number');

      if (await canLaunchUrl(callUri)) {
        final result = await launchUrl(
          callUri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('Résultat url_launcher CALL: $result');
        return result;
      }
    } catch (e) {
      debugPrint('Erreur url_launcher CALL: $e');
    }
    return false;
  }

  /// Méthode 3: url_launcher avec ACTION_DIAL (fallback)
  static Future<bool> _tryUrlLauncherDial(String number) async {
    try {
      debugPrint('Tentative url_launcher DIAL pour: $number');
      final Uri dialUri = Uri.parse('tel:$number');

      final result = await launchUrl(dialUri);
      debugPrint('Résultat url_launcher DIAL: $result');
      return result;
    } catch (e) {
      debugPrint('Erreur url_launcher DIAL: $e');
    }
    return false;
  }

  /// Copie le numéro dans le presse-papiers
  static Future<void> copyToClipboard(String number) async {
    await Clipboard.setData(ClipboardData(text: number));
  }
}
