/// Messages d'erreur professionnels et conviviaux pour l'application LIYA
class ErrorMessages {
  // Messages d'authentification
  static const String tooManyRequests =
      ' Trop de tentatives de connexion détectées. Veuillez patienter 5 minutes avant de réessayer pour votre sécurité.';

  static const String invalidPhoneNumber =
      ' Format de numéro incorrect. Veuillez saisir un numéro valide (ex: 0701234567).';

  static const String appNotAuthorized =
      ' Service temporairement indisponible. Veuillez réessayer dans quelques instants.';

  static const String quotaExceeded =
      ' Service de SMS temporairement saturé. Réessayez dans quelques minutes.';

  static const String networkRequestFailed =
      ' Problème de connexion internet. Vérifiez votre réseau et réessayez.';

  static const String unexpectedError =
      ' Une erreur inattendue s\'est produite. Veuillez réessayer ou contacter le support si le problème persiste.';

  // Messages de vérification OTP
  static const String invalidOtpCode =
      ' Code de vérification incorrect. Veuillez vérifier les 6 chiffres reçus par SMS et réessayer.';

  static const String expiredOtpCode =
      'Votre code de vérification a expiré. Veuillez demander un nouveau code.';

  static const String missingVerificationId =
      ' Session de vérification introuvable. Veuillez redemander un code de vérification.';

  static const String otpVerificationFailed =
      ' Échec de la vérification. Veuillez vérifier votre code et réessayer.';

  static const String otpResendFailed =
      ' Impossible de renvoyer le code. Veuillez réessayer dans quelques instants.';

  static const String otpTooManyAttempts =
      ' Trop de tentatives de vérification. Attendez 5 minutes avant de réessayer.';

  // Messages de gestion de compte
  static const String logoutFailed =
      ' Impossible de se déconnecter. Veuillez réessayer.';

  static const String sessionExpired =
      ' Session expirée. Veuillez vous reconnecter.';

  static const String phoneNumberNotFound =
      ' Impossible de récupérer votre numéro. Veuillez vous reconnecter.';

  static const String reauthenticationRequired =
      ' Sécurité renforcée : Veuillez vous reconnecter pour confirmer la suppression.';

  static const String accountDeletionFailed =
      ' Échec de la suppression. Veuillez réessayer ou contacter le support.';

  static const String accountDeletionSuccess = ' Compte supprimé avec succès';

  // Messages de connexion
  static const String connectionLost =
      ' Connexion internet perdue. Vérifiez votre réseau.';

  static const String connectionRestored = ' Connexion internet restaurée.';

  static const String offlineMode =
      '📱 Mode hors ligne activé. Vos actions seront synchronisées dès la reconnexion.';

  // Messages de validation
  static const String invalidEmail =
      ' Adresse email invalide. Veuillez vérifier le format.';

  static const String passwordTooShort =
      ' Mot de passe trop court. Minimum 8 caractères requis.';

  static const String requiredField = ' Ce champ est obligatoire.';

  // Messages de données
  static const String dataLoadFailed =
      'Impossible de charger les données. Vérifiez votre connexion.';

  static const String dataSaveFailed =
      ' Échec de la sauvegarde. Veuillez réessayer.';

  static const String dataNotFound = '🔍 Aucune donnée trouvée.';

  // Messages de support
  static const String contactSupport =
      ' Pour toute assistance, contactez-nous au +225 07 00 84 65 46';

  static const String supportEmail = ' support@liya-app.com';

  static const String reportIssue = ' Signaler un problème';

  // Messages de succès
  static const String operationSuccess = ' Opération réussie';

  static const String dataSaved = ' Données sauvegardées avec succès';

  static const String profileUpdated = ' Profil mis à jour avec succès';

  // Messages d'information
  static const String loading = ' Chargement en cours...';

  static const String pleaseWait = ' Veuillez patienter...';

  static const String processing = '⚙ Traitement en cours...';

  // Messages de confirmation
  static const String confirmAction =
      ' Êtes-vous sûr de vouloir effectuer cette action ?';

  static const String confirmDeletion =
      ' Cette action est irréversible. Confirmer la suppression ?';

  static const String unsavedChanges =
      ' Vous avez des modifications non sauvegardées. Voulez-vous continuer ?';
}
