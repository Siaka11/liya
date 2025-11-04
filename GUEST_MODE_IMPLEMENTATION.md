# Implémentation du Mode Invité (Guest Mode) - iOS Guideline 5.1.1

## 📋 Vue d'ensemble

Cette implémentation respecte la **Guideline 5.1.1 de l'App Store** qui stipule :

> "Apps must not require users to log in or provide personal information to access features that are not account-based."

## ✨ Fonctionnalités

### Pour iOS 📱
- **Mode invité activé** : Les utilisateurs peuvent passer l'authentification et explorer l'application
- **Bouton "Passer"** visible sur la page d'authentification
- **Bannière d'invitation** sur la page d'accueil pour encourager l'inscription
- **Authentification requise** uniquement pour les actions nécessitant un compte :
  - Passer une commande
  - Ajouter un plat aux favoris
  - Créer un colis
  - Accéder au profil
  - etc.

### Pour Android 🤖
- **Inscription obligatoire** : Comportement standard maintenu
- **Pas de bouton "Passer"** sur la page d'authentification

## 🏗️ Architecture

### 1. Provider de Mode Invité
**Fichier** : `lib/core/providers/guest_mode_provider.dart`

```dart
// Gérer l'état du mode invité
final guestModeProvider = ChangeNotifierProvider<GuestModeNotifier>((ref) {
  return GuestModeNotifier();
});
```

**Méthodes principales** :
- `enableGuestMode()` : Active le mode invité (iOS uniquement)
- `disableGuestMode()` : Désactive le mode invité
- `checkGuestMode()` : Vérifie si le mode invité est actif
- `isGuestModeAvailable()` : Vérifie si la plateforme supporte le mode invité

### 2. Helper d'Authentification
**Fichier** : `lib/core/helpers/auth_helper.dart`

```dart
// Vérifier l'authentification avant une action critique
final isAuthenticated = await AuthHelper.requireAuth(
  context,
  ref,
  actionName: 'passer commande',
);
```

**Fonctionnement** :
- Vérifie si l'utilisateur est authentifié
- Si non, affiche une popup élégante demandant l'inscription
- Redirige vers la page d'authentification si l'utilisateur accepte
- Retourne `true` si l'utilisateur peut continuer, `false` sinon

### 3. Page d'Authentification
**Fichier** : `lib/modules/auth/auth_page.dart`

**Modifications** :
- Ajout d'un bouton "Passer" visible uniquement sur iOS
- Détection de la plateforme avec `defaultTargetPlatform`
- Activation du mode invité lors du clic sur "Passer"
- Navigation vers la page d'accueil en mode invité

### 4. Routeur d'Application
**Fichier** : `lib/routes/app_router.dart`

**Modifications** :
- Routes publiques accessibles sans authentification : `HomeRoute`
- Vérification du mode invité avant la navigation
- Logique de redirection adaptée à la plateforme (iOS/Android)

### 5. Page d'Accueil
**Fichier** : `lib/modules/home/presentation/pages/home_page.dart`

**Modifications** :
- Affichage de "Invité" au lieu du nom de l'utilisateur
- Bannière d'invitation à s'inscrire (visible uniquement en mode invité sur iOS)
- Design élégant et non intrusif

## 🔐 Points de Vérification

L'authentification est vérifiée dans les modules suivants :

### 1. Module Restaurant - Checkout
**Fichier** : `lib/modules/restaurant/features/checkout/presentation/pages/checkout_page.dart`

```dart
// Vérification avant de passer commande
final isAuthenticated = await AuthHelper.requireAuth(
  context,
  ref,
  actionName: 'passer commande',
);

if (!isAuthenticated) return;
```

### 2. Module Restaurant - Favoris
**Fichier** : `lib/modules/restaurant/features/like/presentation/widget/like_button.dart`

```dart
// Vérification avant d'ajouter aux favoris
final isAuthenticated = await AuthHelper.requireAuth(
  context,
  ref,
  actionName: 'ajouter aux favoris',
);

if (!isAuthenticated) return;
```

## 📖 Guide d'Utilisation

### Pour ajouter une vérification d'authentification :

1. **Importer le helper** :
```dart
import 'package:liya/core/helpers/auth_helper.dart';
```

2. **Ajouter la vérification avant l'action** :
```dart
Future<void> _performAction() async {
  // Vérifier l'authentification
  final isAuthenticated = await AuthHelper.requireAuth(
    context,
    ref,
    actionName: 'effectuer cette action', // Personnalisable
  );

  if (!isAuthenticated) {
    return; // Arrêter si non authentifié
  }

  // Continuer avec l'action...
}
```

## 🎯 Approche Glovo

Cette implémentation s'inspire de l'approche Glovo :
- ✅ **Accès libre en consultation** : Explorer restaurants, plats, prix
- ✅ **Inscription pour interaction** : Commande, favoris, profil
- ✅ **UX non intrusive** : Pas de popup à chaque action
- ✅ **Encouragement subtil** : Bannière élégante sur la page d'accueil

## 🧪 Tests

### Scénarios à tester sur iOS :

1. **Mode invité activé** :
   - ✅ Clic sur "Passer" → Navigation vers home
   - ✅ Affichage de "Invité" sur la page d'accueil
   - ✅ Bannière d'invitation visible

2. **Actions nécessitant authentification** :
   - ✅ Passer commande → Popup d'inscription
   - ✅ Ajouter aux favoris → Popup d'inscription
   - ✅ Annuler la popup → Retour à l'écran précédent
   - ✅ Accepter l'inscription → Navigation vers auth

3. **Inscription depuis le mode invité** :
   - ✅ Clic sur "S'inscrire" dans la bannière
   - ✅ Clic sur "S'inscrire" dans la popup
   - ✅ Désactivation du mode invité après inscription

### Scénarios à tester sur Android :

1. **Pas de mode invité** :
   - ✅ Pas de bouton "Passer" sur la page auth
   - ✅ Inscription obligatoire pour accéder à l'app

## 📝 Notes Importantes

1. **Stockage du mode invité** :
   - Utilise `SharedPreferences` avec la clé `is_guest_mode`
   - Persiste entre les sessions

2. **Détection de plateforme** :
   - Utilise `defaultTargetPlatform` de Flutter
   - Comparaison avec `TargetPlatform.iOS` et `TargetPlatform.android`

3. **Navigation** :
   - Utilise AutoRoute pour la navigation
   - Routes publiques définies dans `app_router.dart`

4. **Design** :
   - Respecte le thème de l'application
   - Couleurs : Orange (#FF4B2B) et blanc
   - Icônes Material Design

## 🚀 Déploiement

### Avant la soumission à l'App Store :

1. ✅ Tester le mode invité sur un appareil iOS réel
2. ✅ Vérifier que toutes les actions critiques demandent l'authentification
3. ✅ S'assurer que le mode invité n'est disponible que sur iOS
4. ✅ Vérifier que la bannière d'invitation s'affiche correctement
5. ✅ Tester le flux complet : mode invité → action → inscription → utilisation normale

### Notes de soumission pour Apple :

> Cette application respecte la Guideline 5.1.1 en permettant aux utilisateurs iOS d'explorer l'interface et le contenu sans créer de compte. L'inscription n'est requise que pour les actions nécessitant un compte utilisateur (commandes, favoris, profil).

## 🔄 Évolutions Futures

- [ ] Ajouter plus de points de vérification (panier, profil, etc.)
- [ ] Implémenter un système de compteur d'actions en mode invité
- [ ] Ajouter des analytics pour suivre le taux de conversion invité → inscrit
- [ ] Personnaliser les messages d'invitation selon le contexte

## 📞 Support

Pour toute question ou problème concernant cette implémentation, contactez l'équipe de développement.

---

**Version** : 1.0.0  
**Date** : 30 Octobre 2025  
**Conformité** : iOS Guideline 5.1.1 - Privacy – Data Collection and Storage


