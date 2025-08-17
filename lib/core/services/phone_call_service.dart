import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneCallService {
  static const MethodChannel _channel = MethodChannel('phone_call_service');

  /// Demande la permission d'appel avec gestion iOS/Android
  static Future<bool> requestCallPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Sur iOS, on utilise directement url_launcher sans permission spéciale
        return true;
      }

      // Sur Android, on vérifie la permission
      final status = await Permission.phone.status;
      if (status.isGranted) {
        return true;
      }

      // Si la permission est refusée définitivement, on peut essayer de l'ouvrir dans les paramètres
      if (status.isPermanentlyDenied) {
        final shouldOpenSettings = await _showPermissionDialog();
        if (shouldOpenSettings) {
          await openAppSettings();
          // Attendre un peu puis revérifier
          await Future.delayed(const Duration(seconds: 2));
          final newStatus = await Permission.phone.status;
          return newStatus.isGranted;
        }
        return false;
      }

      // Demander la permission normalement
      final result = await Permission.phone.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('Erreur permission: $e');
      return false;
    }
  }

  /// Affiche un dialogue pour demander à l'utilisateur d'ouvrir les paramètres
  static Future<bool> _showPermissionDialog() async {
    // Cette méthode sera implémentée dans l'UI
    // Pour l'instant, on retourne true pour ouvrir les paramètres
    return true;
  }

  /// Nettoie le numéro de téléphone
  static String cleanPhoneNumber(String number) {
    return number.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Méthode principale pour passer un appel
  static Future<bool> makeCall(String phoneNumber) async {
    final cleanNumber = cleanPhoneNumber(phoneNumber);
    debugPrint('Tentative d\'appel vers: $cleanNumber');

    // Sur iOS, on essaie plusieurs méthodes
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Méthode 1: url_launcher avec tel:
      if (await _tryUrlLauncherCall(cleanNumber)) {
        return true;
      }

      // Méthode 2: url_launcher avec tel: et mode external
      if (await _tryUrlLauncherCallExternal(cleanNumber)) {
        return true;
      }

      // Méthode 3: url_launcher avec ACTION_DIAL (fallback)
      if (await _tryUrlLauncherDial(cleanNumber)) {
        return true;
      }

      debugPrint('❌ Toutes les méthodes iOS ont échoué');
      return false;
    }

    // Sur Android, vérifier les permissions
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

  /// Méthode 2b: url_launcher avec ACTION_CALL et mode external forcé
  static Future<bool> _tryUrlLauncherCallExternal(String number) async {
    try {
      debugPrint('Tentative url_launcher CALL EXTERNAL pour: $number');
      final Uri callUri = Uri.parse('tel:$number');

      if (await canLaunchUrl(callUri)) {
        final result = await launchUrl(
          callUri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: false,
            enableDomStorage: false,
          ),
        );
        debugPrint('Résultat url_launcher CALL EXTERNAL: $result');
        return result;
      }
    } catch (e) {
      debugPrint('Erreur url_launcher CALL EXTERNAL: $e');
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

  /// Vérifie si l'application peut faire des appels
  static Future<bool> canMakeCalls() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Sur iOS, on peut toujours essayer
      return true;
    }

    // Sur Android, vérifier la permission
    final status = await Permission.phone.status;
    return status.isGranted;
  }

  /// Ouvre les paramètres de l'application pour les permissions
  static Future<void> openAppPermissionSettings() async {
    await openAppSettings();
  }

  /// Méthode spécifique pour iOS - ouvre l'app Téléphone
  static Future<bool> openPhoneApp(String number) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }

    try {
      final Uri phoneUri = Uri.parse('tel:$number');
      final result = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );
      debugPrint('Résultat ouverture app Téléphone: $result');
      return result;
    } catch (e) {
      debugPrint('Erreur ouverture app Téléphone: $e');
      return false;
    }
  }
}
