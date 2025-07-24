# 🔧 Guide de résolution des problèmes Xcode pour les notifications iOS

## Problème 1 : Équipe de développement manquante

### Solution :
1. **Ouvrir Xcode** → Votre projet `Runner.xcworkspace`
2. **Sélectionner le projet "Runner"** dans la barre latérale
3. **Aller dans l'onglet "Signing & Capabilities"**
4. **Dans la section "Signing"** :
   - Cliquer sur le menu déroulant à côté de "Team"
   - Sélectionner votre équipe de développement Apple
   - Si aucune équipe n'apparaît, cliquer sur "Add Account..."
   - Ajouter votre Apple ID

### Si vous n'avez pas d'équipe de développement :
1. **Créer un compte Apple Developer gratuit** :
   - Aller sur https://developer.apple.com
   - Créer un compte avec votre Apple ID
   - Accepter l'accord de licence

2. **Dans Xcode** :
   - Xcode → Settings (ou Preferences)
   - Onglet "Accounts"
   - Cliquer sur "+" → "Apple ID"
   - Ajouter votre Apple ID

## Problème 2 : Capacités manquantes

### Activer "Push Notifications" :
1. **Dans "Signing & Capabilities"**
2. **Cliquer sur "+ Capability"** (bouton en haut à gauche)
3. **Rechercher et ajouter "Push Notifications"**

### Activer "Remote notifications" :
1. **Dans "Background Modes"**
2. **Cocher la case "Remote notifications"**

## Problème 3 : Bundle Identifier

### Vérifier le Bundle ID :
- S'assurer que le "Bundle Identifier" est `com.liya.ci`
- Ce doit correspondre à celui configuré dans Firebase Console

## Après les modifications :

1. **Nettoyer le projet** :
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Reconstruire** :
   ```bash
   flutter run
   ```

## Vérification :

Après ces modifications, vous devriez voir :
- ✅ Pas d'avertissement de signature
- ✅ "Remote notifications" coché
- ✅ "Push Notifications" activé
- ✅ Équipe de développement sélectionnée 