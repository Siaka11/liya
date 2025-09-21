/// Script de test pour vérifier les messages d'erreur OTP professionnels
import '../constants/error_messages.dart';

void main() {
  print('🧪 === TEST DES MESSAGES D\'ERREUR OTP PROFESSIONNELS ===\n');

  // Test des messages de vérification OTP
  print('📱 Messages de vérification OTP :');
  print('1. Code incorrect :');
  print('   ${ErrorMessages.invalidOtpCode}\n');

  print('2. Code expiré :');
  print('   ${ErrorMessages.expiredOtpCode}\n');

  print('3. Session manquante :');
  print('   ${ErrorMessages.missingVerificationId}\n');

  print('4. Échec de vérification :');
  print('   ${ErrorMessages.otpVerificationFailed}\n');

  print('5. Trop de tentatives :');
  print('   ${ErrorMessages.otpTooManyAttempts}\n');

  // Test des messages de renvoi OTP
  print('🔄 Messages de renvoi OTP :');
  print('6. Renvoi échoué :');
  print('   ${ErrorMessages.otpResendFailed}\n');

  // Test des messages de contexte réseau/service
  print('🌐 Messages de contexte :');
  print('7. Trop de demandes :');
  print('   ${ErrorMessages.tooManyRequests}\n');

  print('8. Numéro invalide :');
  print('   ${ErrorMessages.invalidPhoneNumber}\n');

  print('9. Quota dépassé :');
  print('   ${ErrorMessages.quotaExceeded}\n');

  print('10. Problème réseau :');
  print('    ${ErrorMessages.networkRequestFailed}\n');

  print('11. Service indisponible :');
  print('    ${ErrorMessages.appNotAuthorized}\n');

  print('12. Erreur inattendue :');
  print('    ${ErrorMessages.unexpectedError}\n');

  // Test de simulation d'erreur
  print('🎭 === SIMULATION D\'ERREURS ===\n');

  // Simuler différents types d'erreurs
  final errorTypes = [
    'invalid-verification-code',
    'session-expired',
    'too-many-requests',
    'quota-exceeded',
    'network-request-failed',
    'app-not-authorized',
    'invalid-phone-number',
  ];

  for (String errorType in errorTypes) {
    String message = _getErrorMessage(errorType);
    print('❌ $errorType :');
    print('   $message\n');
  }

  print('✅ === TEST TERMINÉ ===');
  print('📊 Total des messages testés : ${_countMessages()}');
}

/// Simule la logique de sélection des messages d'erreur
String _getErrorMessage(String errorType) {
  switch (errorType) {
    case 'invalid-verification-code':
      return ErrorMessages.invalidOtpCode;
    case 'session-expired':
      return ErrorMessages.expiredOtpCode;
    case 'too-many-requests':
      return ErrorMessages.otpTooManyAttempts;
    case 'quota-exceeded':
      return ErrorMessages.quotaExceeded;
    case 'network-request-failed':
      return ErrorMessages.networkRequestFailed;
    case 'app-not-authorized':
      return ErrorMessages.appNotAuthorized;
    case 'invalid-phone-number':
      return ErrorMessages.invalidPhoneNumber;
    default:
      return ErrorMessages.otpVerificationFailed;
  }
}

/// Compte le nombre total de messages d'erreur OTP
int _countMessages() {
  return 12; // Nombre de messages testés
}

/// Affiche un résumé des améliorations
void printImprovements() {
  print('\n🎯 === RÉSUMÉ DES AMÉLIORATIONS ===');
  print('✅ Messages d\'erreur professionnels');
  print('✅ Émojis informatifs pour chaque type');
  print('✅ Instructions claires et concrètes');
  print('✅ Ton convivial et rassurant');
  print('✅ Messages centralisés et réutilisables');
  print('✅ Gestion intelligente des erreurs Firebase');
  print('✅ Fallback vers messages génériques');
  print('✅ Consistance dans toute l\'application');
}
