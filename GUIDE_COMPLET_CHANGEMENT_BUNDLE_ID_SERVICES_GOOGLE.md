# 🔐 Guide Complet : Changement Bundle ID iOS avec Services Google

## 🎯 **Changement de Bundle ID**
- **Ancien** : `com.liya.ci.v1`
- **Nouveau** : `com.liya.app`

## 📋 **Services Google Utilisés**

Votre application utilise les services suivants qui **DOIVENT** être reconfigurés :

1. **Firebase Authentication** (Phone Auth + reCAPTCHA Enterprise)
2. **Firebase Firestore**
3. **Firebase Cloud Messaging** (Push Notifications)
4. **Firebase App Check** (App Attest + reCAPTCHA)
5. **Google Maps SDK** (iOS)
6. **reCAPTCHA Enterprise**

---

## 🔧 **ÉTAPE 1 : Firebase Console**

### A. Ajouter Nouvelle App iOS

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Projet : `liya-a4a9f`
3. **Project Settings** → **General**
4. Dans "Your apps", cliquer sur **"Add app"** → **iOS**
5. **Bundle ID** : `com.liya.app`
6. **App nickname** : `Liya iOS (Production)`
7. **App Store ID** : (Laisser vide pour l'instant)
8. Cliquer sur **"Register app"**

### B. Télécharger GoogleService-Info.plist

1. Télécharger le nouveau `GoogleService-Info.plist`
2. **IMPORTANT** : Vérifier que le `BUNDLE_ID` est bien `com.liya.app`
3. Remplacer les fichiers existants :
   - `ios/Runner/GoogleService-Info.plist`
   - `ios/GoogleService-Info.plist`

### C. Configurer App Check pour iOS

1. Dans Firebase Console → **App Check**
2. Sélectionner votre nouvelle app iOS `com.liya.app`
3. **App Attest** : Activer (pour iOS 14+)
4. **DeviceCheck** : Activer (fallback pour iOS < 14)

### D. Configurer Firebase Authentication

1. Firebase Console → **Authentication** → **Sign-in method**
2. **Phone** : S'assurer qu'il est activé
3. **Domaines autorisés** : Vérifier que votre domaine est listé
4. **App verification** :
   - reCAPTCHA Enterprise doit être activé
   - App Check doit être configuré

---

## 🔐 **ÉTAPE 2 : reCAPTCHA Enterprise**

### A. Google Cloud Console

1. Aller sur [Google Cloud Console](https://console.cloud.google.com/)
2. Projet : `liya-a4a9f` (même projet que Firebase)
3. **Security** → **reCAPTCHA Enterprise**

### B. Créer Nouvelle Clé iOS (ou Mettre à Jour)

#### Option 1 : Mettre à jour la clé existante
1. Sélectionner votre clé iOS existante : `6LeyyaArAAAAANN4NE9DyZ6PUjqxehmHRebNsWzN`
2. **Settings** → **iOS platform settings**
3. **Ajouter** `com.liya.app` à la liste des Bundle IDs autorisés
4. **Garder** aussi `com.liya.ci.v1` pendant la transition

#### Option 2 : Créer une nouvelle clé (recommandé)
1. **Create key** → **iOS**
2. **Display name** : `Liya iOS Production`
3. **Bundle IDs** : `com.liya.app`
4. **Copier la nouvelle clé** générée
5. **Mettre à jour** dans votre code :
   ```dart
   // lib/core/services/recaptcha_service.dart
   static const String _iosSiteKey = 'NOUVELLE_CLE_ICI';
   ```

### C. Mettre à Jour le Code

```dart
// lib/core/services/recaptcha_service.dart
static const String _iosSiteKey = 'VOTRE_NOUVELLE_CLE_IOS';
```

---

## 🗺️ **ÉTAPE 3 : Google Maps API**

### A. Google Cloud Console - APIs & Services

1. [Google Cloud Console](https://console.cloud.google.com/)
2. **APIs & Services** → **Credentials**
3. Trouver votre clé API : `AIzaSyCQsF-eLOazXu1Kwe1eToCej-IgjKmPzgg`

### B. Mettre à Jour les Restrictions

1. Cliquer sur votre clé API
2. **Application restrictions** → **iOS apps**
3. **Ajouter** `com.liya.app` à la liste des Bundle IDs
4. **Garder** aussi `com.liya.ci.v1` pendant la transition
5. **Save**

### C. APIs Activées (Vérifier)

S'assurer que ces APIs sont activées :
- ✅ **Maps SDK for iOS**
- ✅ **Places API**
- ✅ **Geocoding API**
- ✅ **Directions API** (si utilisé)

---

## 🍎 **ÉTAPE 4 : Apple Developer Portal**

### A. Créer Nouvel App ID

1. [Apple Developer Portal](https://developer.apple.com/)
2. **Certificates, Identifiers & Profiles**
3. **Identifiers** → **+** (Add)
4. **App IDs** → Continue
5. **Bundle ID** : `com.liya.app`
6. **Description** : `Liya App`

### B. Capabilities à Activer

- ✅ **Push Notifications**
- ✅ **Associated Domains** (pour Firebase Dynamic Links)
- ✅ **Background Modes** (Remote notifications, Fetch)
- ✅ **Sign In with Apple** (si utilisé)
- ✅ **App Groups** (si utilisé)

### C. Créer Provisioning Profiles

#### Development Profile
1. **Profiles** → **+** (Add)
2. **iOS App Development**
3. **App ID** : `com.liya.app`
4. Sélectionner votre **certificat de développement**
5. Sélectionner vos **appareils de test**
6. **Name** : `Liya Development`
7. **Generate** et **Download**

#### Distribution Profile (App Store)
1. **Profiles** → **+** (Add)
2. **App Store Distribution**
3. **App ID** : `com.liya.app`
4. Sélectionner votre **certificat de distribution**
5. **Name** : `Liya App Store`
6. **Generate** et **Download**

### D. Configurer Push Notifications (APNs)

#### Créer Certificat APNs
1. **Certificates** → **+** (Add)
2. **Apple Push Notification service SSL (Sandbox & Production)**
3. **App ID** : `com.liya.app`
4. **Upload CSR** (Certificate Signing Request)
5. **Download** le certificat `.cer`

#### Convertir en .p12 pour Firebase
```bash
# Ouvrir le certificat téléchargé dans Keychain Access
# Exporter comme .p12 avec mot de passe

# Ou via Terminal :
openssl pkcs12 -in ApplePushNotifications.p12 -out ApplePushNotifications.pem -nodes
```

#### Upload dans Firebase Console
1. Firebase Console → **Project Settings** → **Cloud Messaging**
2. **iOS app configuration**
3. **Upload** le certificat `.p12` ou `.p8` (clé)
4. Entrer le **mot de passe** si `.p12`

---

## 📝 **ÉTAPE 5 : Fichiers de Configuration**

### A. Mettre à Jour GoogleService-Info.plist

Vérifier que le nouveau fichier contient :
```xml
<key>BUNDLE_ID</key>
<string>com.liya.app</string>

<key>CLIENT_ID</key>
<string>NOUVELLE_CLIENT_ID.apps.googleusercontent.com</string>

<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.NOUVELLE_CLIENT_ID</string>
```

### B. Mettre à Jour Info.plist (CFBundleURLSchemes)

Le `REVERSED_CLIENT_ID` doit correspondre au nouveau dans `GoogleService-Info.plist` :

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.NOUVELLE_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

---

## 🧪 **ÉTAPE 6 : Tests et Validation**

### A. Nettoyer et Rebuild

```bash
# Nettoyer le projet
flutter clean

# Supprimer les pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Rebuild
flutter build ios
```

### B. Tests à Effectuer

#### 1. Firebase Authentication
```bash
# Test OTP
- Envoyer OTP
- Vérifier que reCAPTCHA fonctionne
- Vérifier que l'OTP arrive
- Valider l'OTP
```

#### 2. Google Maps
```bash
# Test Maps
- Afficher une carte
- Rechercher un lieu
- Afficher la navigation
```

#### 3. Push Notifications
```bash
# Test FCM
- Enregistrer le token FCM
- Envoyer une notification de test depuis Firebase Console
- Vérifier réception foreground
- Vérifier réception background
```

#### 4. App Check
```bash
# Vérifier dans Firebase Console → App Check
- Le token App Attest est généré
- Les requêtes sont validées
```

### C. Vérification des Logs

```bash
# Xcode logs
open ios/Runner.xcworkspace

# Chercher dans les logs :
✅ reCAPTCHA Enterprise initialisé
✅ App Check activé
✅ Google Maps configuré
✅ APNs device token enregistré
```

---

## ⚠️ **POINTS CRITIQUES**

### 1. **Période de Transition**

Pendant la migration, **gardez les deux Bundle IDs** configurés :
- `com.liya.ci.v1` (ancien - pour utilisateurs existants)
- `com.liya.app` (nouveau - pour nouveaux utilisateurs)

Dans :
- ✅ reCAPTCHA Enterprise (Bundle IDs autorisés)
- ✅ Google Maps API (Restrictions iOS)
- ✅ Firebase (deux apps iOS dans le même projet)

### 2. **Impact Utilisateurs**

⚠️ **Les utilisateurs DOIVENT réinstaller l'app** :
- Nouveau Bundle ID = Nouvelle app
- Données locales perdues (mais données Firebase conservées)
- Nouveaux tokens FCM à enregistrer

### 3. **App Store**

Si déjà publié :
- **Nouvelle app** à créer dans App Store Connect
- Impossible de migrer l'ancienne app
- Considérer :
  - Garder l'ancienne app en maintenance
  - Ajouter un message de migration dans l'ancienne app

---

## 📋 **CHECKLIST COMPLÈTE**

### Firebase
- [ ] Nouvelle app iOS créée avec Bundle ID `com.liya.app`
- [ ] Nouveau GoogleService-Info.plist téléchargé et installé
- [ ] App Check configuré (App Attest + DeviceCheck)
- [ ] Certificat APNs uploadé pour nouveau Bundle ID

### reCAPTCHA Enterprise
- [ ] Nouvelle clé iOS créée (ou Bundle ID ajouté à clé existante)
- [ ] Code mis à jour avec nouvelle clé (si nouvelle)
- [ ] Tests effectués

### Google Maps
- [ ] Bundle ID ajouté aux restrictions de la clé API
- [ ] Maps SDK for iOS activé
- [ ] Places API activée
- [ ] Tests de carte effectués

### Apple Developer
- [ ] Nouvel App ID créé
- [ ] Capabilities configurées
- [ ] Provisioning Profiles créés (Dev + Dist)
- [ ] Certificat APNs créé

### Code et Configuration
- [ ] project.pbxproj mis à jour ✅
- [ ] GoogleService-Info.plist remplacé
- [ ] Info.plist REVERSED_CLIENT_ID mis à jour
- [ ] recaptcha_service.dart mis à jour (si nouvelle clé)

### Tests
- [ ] Build iOS réussie
- [ ] Authentification OTP fonctionne
- [ ] Google Maps s'affiche
- [ ] Push notifications reçues
- [ ] App Check validé

---

## 🚀 **COMMANDES UTILES**

```bash
# Vérifier Bundle ID actuel
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/

# Nettoyer et rebuild
flutter clean && cd ios && pod install && cd .. && flutter build ios

# Ouvrir Xcode
open ios/Runner.xcworkspace

# Tester sur simulateur
flutter run -d "iPhone 15 Pro"

# Build pour appareil
flutter build ios --release

# Vérifier les certificats
security find-identity -v -p codesigning
```

---

## 📞 **SUPPORT ET DOCUMENTATION**

### Documentation Officielle
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [reCAPTCHA Enterprise](https://cloud.google.com/recaptcha-enterprise/docs/ios)
- [Google Maps iOS](https://developers.google.com/maps/documentation/ios-sdk/start)
- [Apple Developer](https://developer.apple.com/documentation/)

### En Cas de Problème

1. **Firebase Auth ne fonctionne pas**
   - Vérifier GoogleService-Info.plist
   - Vérifier App Check
   - Vérifier reCAPTCHA Enterprise

2. **Google Maps ne s'affiche pas**
   - Vérifier clé API dans AppDelegate.swift
   - Vérifier restrictions Bundle ID
   - Vérifier que Maps SDK est activé

3. **Push Notifications ne marchent pas**
   - Vérifier certificat APNs dans Firebase
   - Vérifier Capabilities dans Xcode
   - Vérifier token FCM s'enregistre

---

## ✅ **RÉSUMÉ DES ACTIONS PRIORITAIRES**

1. **Firebase Console** : Créer nouvelle app iOS
2. **Télécharger** nouveau GoogleService-Info.plist
3. **reCAPTCHA** : Ajouter Bundle ID aux restrictions
4. **Google Maps** : Ajouter Bundle ID aux restrictions
5. **Apple Developer** : Créer App ID et Provisioning Profiles
6. **APNs** : Créer et uploader certificat
7. **Tester** tout le workflow

Bonne chance ! 🚀
