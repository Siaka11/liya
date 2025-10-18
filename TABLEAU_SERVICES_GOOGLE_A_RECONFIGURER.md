# 📊 Tableau Récapitulatif : Services Google à Reconfigurer

## 🎯 **Bundle ID Change**
`com.liya.ci.v1` → `com.liya.app`

---

## 📋 **Services Google par Priorité**

| # | Service | Plateforme | Action Requise | Criticité | Détails |
|---|---------|-----------|----------------|-----------|---------|
| 1 | **Firebase iOS App** | Firebase Console | ✅ Créer nouvelle app iOS | 🔴 CRITIQUE | Sans ça, rien ne fonctionne |
| 2 | **GoogleService-Info.plist** | Firebase Console | ✅ Télécharger + Remplacer | 🔴 CRITIQUE | Fichier de configuration |
| 3 | **reCAPTCHA Enterprise (iOS)** | Google Cloud Console | ✅ Ajouter Bundle ID | 🔴 CRITIQUE | Auth OTP bloquée sinon |
| 4 | **Google Maps API Key** | Google Cloud Console | ✅ Ajouter Bundle ID | 🟠 IMPORTANT | Cartes ne s'afficheront pas |
| 5 | **Firebase App Check** | Firebase Console | ✅ Configurer App Attest | 🟠 IMPORTANT | Sécurité API |
| 6 | **APNs Certificate** | Apple Developer + Firebase | ✅ Créer + Upload | 🟠 IMPORTANT | Push notifications |
| 7 | **Apple App ID** | Apple Developer Portal | ✅ Créer | 🔴 CRITIQUE | Base de tout |
| 8 | **Provisioning Profiles** | Apple Developer Portal | ✅ Créer Dev + Dist | 🔴 CRITIQUE | Pour signer l'app |

---

## 🔐 **Détails par Service**

### 1. Firebase iOS App
**Console** : [Firebase Console](https://console.firebase.google.com/)  
**Projet** : `liya-a4a9f`

**Actions** :
```
1. Project Settings → General → Your apps
2. Add app → iOS
3. Bundle ID: com.liya.app
4. Nickname: Liya iOS Production
5. Register app
```

**Fichiers Impactés** :
- ✅ `ios/Runner/GoogleService-Info.plist`
- ✅ `ios/GoogleService-Info.plist`

---

### 2. reCAPTCHA Enterprise

**Console** : [Google Cloud Console](https://console.cloud.google.com/)  
**Projet** : `liya-a4a9f`  
**Clé iOS Actuelle** : `6LeyyaArAAAAANN4NE9DyZ6PUjqxehmHRebNsWzN`

**Actions** :
```
Security → reCAPTCHA Enterprise → Keys
Option A: Ajouter com.liya.app à la clé existante
Option B: Créer nouvelle clé pour com.liya.app
```

**Fichiers Impactés** :
- ⚠️ `lib/core/services/recaptcha_service.dart` (si nouvelle clé)
- ⚠️ `lib/main.dart` (ReCaptchaV3Provider - si nouvelle clé)

**Code à Vérifier** :
```dart
// lib/core/services/recaptcha_service.dart
static const String _iosSiteKey = '6LeyyaArAAAAANN4NE9DyZ6PUjqxehmHRebNsWzN';

// lib/main.dart
ReCaptchaV3Provider('6LeyyaArAAAAANN4NE9DyZ6PUjqxehmHRebNsWzN')
```

---

### 3. Google Maps API

**Console** : [Google Cloud Console](https://console.cloud.google.com/)  
**Projet** : `liya-a4a9f`  
**Clé API Actuelle** : `AIzaSyCQsF-eLOazXu1Kwe1eToCej-IgjKmPzgg`

**Actions** :
```
APIs & Services → Credentials → API Keys
Cliquer sur votre clé
Application restrictions → iOS apps
+ Add an item → com.liya.app
Save
```

**APIs Requises** :
- ✅ Maps SDK for iOS
- ✅ Places API
- ✅ Geocoding API
- ✅ Directions API

**Fichiers Impactés** :
- ✅ `ios/Runner/AppDelegate.swift` (ligne 21)

**Code à Vérifier** :
```swift
// ios/Runner/AppDelegate.swift
GMSServices.provideAPIKey("AIzaSyCQsF-eLOazXu1Kwe1eToCej-IgjKmPzgg")
```

---

### 4. Firebase App Check

**Console** : [Firebase Console](https://console.firebase.google.com/)  
**Projet** : `liya-a4a9f`

**Actions** :
```
Build → App Check
Sélectionner nouvelle app iOS (com.liya.app)
App Attest → Activate
DeviceCheck → Activate (fallback)
```

**Fichiers Impactés** :
- ✅ `lib/main.dart` (déjà configuré)

**Code Existant** :
```dart
await FirebaseAppCheck.instance.activate(
  appleProvider: AppleProvider.appAttest,
  webProvider: ReCaptchaV3Provider('6LeyyaArAAAAANN4NE9DyZ6PUjqxehmHRebNsWzN'),
);
```

---

### 5. APNs (Push Notifications)

**Console Apple** : [Apple Developer Portal](https://developer.apple.com/)  
**Console Firebase** : [Firebase Console](https://console.firebase.google.com/)

**Actions Apple Developer** :
```
1. Certificates → + Add
2. Apple Push Notification service SSL (Sandbox & Production)
3. App ID: com.liya.app
4. Upload CSR
5. Download certificat .cer
6. Convertir en .p12 (via Keychain Access)
```

**Actions Firebase** :
```
Project Settings → Cloud Messaging
iOS app configuration (com.liya.app)
Upload APNs certificate (.p12 ou .p8)
```

**Fichiers Impactés** :
- ✅ `ios/Runner/Info.plist` (permissions déjà configurées)
- ✅ `ios/Runner/AppDelegate.swift` (configuration déjà présente)

---

### 6. OAuth Client ID

**Fichier** : `GoogleService-Info.plist`

**Champs Importants** :
```xml
<key>CLIENT_ID</key>
<string>353439898034-s9b3978o6imj6uf2avavoj300stsgc7l.apps.googleusercontent.com</string>

<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.353439898034-s9b3978o6imj6uf2avavoj300stsgc7l</string>
```

**⚠️ ATTENTION** : Ces valeurs changeront avec le nouveau `GoogleService-Info.plist`

**Fichiers à Mettre à Jour** :
- ✅ `ios/Runner/Info.plist` → `CFBundleURLSchemes`

---

## 🧪 **Plan de Test**

| Service | Test | Commande / Action | Résultat Attendu |
|---------|------|-------------------|------------------|
| **Firebase** | Configuration | `flutter run` | ✅ App démarre sans erreur |
| **Auth** | OTP | Envoyer OTP via app | ✅ OTP reçu par SMS |
| **reCAPTCHA** | Vérification | Logs Xcode | ✅ "reCAPTCHA initialisé" |
| **Maps** | Affichage | Ouvrir page avec carte | ✅ Carte s'affiche |
| **Places** | Autocomplete | Taper adresse | ✅ Suggestions apparaissent |
| **App Check** | Token | Firebase Console → App Check | ✅ Token App Attest généré |
| **FCM** | Push | Firebase Console → Cloud Messaging | ✅ Notification reçue |

---

## 📝 **Checklist d'Exécution**

### Phase 1 : Configuration Externe (Cloud)
- [ ] **Firebase** : Créer nouvelle app iOS
- [ ] **Firebase** : Télécharger GoogleService-Info.plist
- [ ] **reCAPTCHA** : Ajouter Bundle ID (ou créer nouvelle clé)
- [ ] **Google Maps** : Ajouter Bundle ID aux restrictions
- [ ] **Apple Developer** : Créer App ID
- [ ] **Apple Developer** : Créer certificat APNs
- [ ] **Firebase** : Uploader certificat APNs
- [ ] **Firebase** : Configurer App Check
- [ ] **Apple Developer** : Créer Provisioning Profiles

### Phase 2 : Configuration Interne (Code)
- [x] **Xcode** : Bundle ID changé dans project.pbxproj ✅
- [ ] **Firebase** : Remplacer GoogleService-Info.plist
- [ ] **Info.plist** : Mettre à jour REVERSED_CLIENT_ID
- [ ] **Code** : Vérifier recaptcha_service.dart (si nouvelle clé)
- [ ] **Code** : Vérifier main.dart (si nouvelle clé)

### Phase 3 : Build et Test
- [ ] **Clean** : `flutter clean`
- [ ] **Pods** : `cd ios && pod install`
- [ ] **Build** : `flutter build ios`
- [ ] **Test Auth** : Envoyer + Vérifier OTP
- [ ] **Test Maps** : Afficher carte + Places
- [ ] **Test FCM** : Envoyer notification
- [ ] **Test App Check** : Vérifier token généré

---

## ⏱️ **Estimation du Temps**

| Phase | Durée Estimée |
|-------|---------------|
| Configuration Firebase | 15 min |
| Configuration reCAPTCHA | 10 min |
| Configuration Google Maps | 5 min |
| Configuration Apple Developer | 30 min |
| Configuration APNs | 20 min |
| Mise à jour fichiers code | 10 min |
| Build et tests | 20 min |
| **TOTAL** | **~2 heures** |

---

## 🆘 **Troubleshooting Rapide**

| Problème | Cause Probable | Solution |
|----------|----------------|----------|
| App ne démarre pas | GoogleService-Info.plist invalide | Re-télécharger depuis Firebase |
| OTP ne part pas | reCAPTCHA mal configuré | Vérifier Bundle ID dans Cloud Console |
| Carte vide | Google Maps API mal configuré | Vérifier clé API + restrictions |
| Push non reçu | Certificat APNs manquant | Créer + uploader certificat |
| Build échoue | Provisioning Profile invalide | Re-créer profil dans Apple Developer |

---

## 📞 **Contacts Support**

- **Firebase** : [Support Firebase](https://firebase.google.com/support)
- **Google Cloud** : [Support Cloud](https://cloud.google.com/support)
- **Apple Developer** : [Support Apple](https://developer.apple.com/support/)

---

Bon courage pour la migration ! 🚀
