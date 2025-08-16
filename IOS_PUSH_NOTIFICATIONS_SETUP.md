# 📱 Configuration des Notifications Push iOS

## 🎯 **Étapes dans Xcode**

### 1. **Ouvrir le projet iOS**
```bash
cd ios
open Runner.xcworkspace
```

### 2. **Configurer les Capabilities**

#### A. Sélectionner la Target
- Dans Xcode, sélectionnez **"Runner"** dans le navigateur de projet
- Cliquez sur la target **"Runner"** (pas le projet)
- Allez dans l'onglet **"Signing & Capabilities"**

#### B. Ajouter Push Notifications
1. Cliquez sur **"+ Capability"** en haut à gauche
2. Recherchez et sélectionnez **"Push Notifications"**
3. Cette capability sera automatiquement ajoutée

#### C. Ajouter Background Modes (si pas déjà présent)
1. Cliquez à nouveau sur **"+ Capability"**
2. Recherchez et sélectionnez **"Background Modes"**
3. Cochez **"Remote notifications"**

### 3. **Vérifier les Entitlements**

Dans le fichier `Runner/Runner.entitlements`, vérifiez la présence de :
```xml
<key>aps-environment</key>
<string>development</string>
```

### 4. **Configuration Apple Developer Portal**

#### A. Créer un certificat Push
1. Allez sur [Apple Developer Portal](https://developer.apple.com/account/)
2. **Certificates, Identifiers & Profiles** → **Certificates**
3. Cliquez **"+"** pour créer un nouveau certificat
4. Sélectionnez **"Apple Push Notification service SSL (Sandbox & Production)"**
5. Choisissez votre App ID (`com.liya.ci.v1`)
6. Suivez les instructions pour générer le certificat

#### B. Télécharger et installer le certificat
1. Téléchargez le fichier `.cer`
2. Double-cliquez pour l'installer dans le Keychain
3. Exportez-le en `.p12` pour Firebase

### 5. **Configuration Firebase**

#### A. Uploader le certificat APNs
1. Allez dans la [Console Firebase](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. **Project Settings** → **Cloud Messaging** → **iOS app configuration**
4. Uploadez votre certificat `.p12`

#### B. Mettre à jour GoogleService-Info.plist
- Téléchargez le fichier `GoogleService-Info.plist` mis à jour
- Remplacez le fichier existant dans `ios/Runner/`

## 🔧 **Configuration déjà faite dans le code**

### ✅ AppDelegate.swift
- Configuration Firebase
- Enregistrement pour les notifications
- Delegates pour gérer les notifications

### ✅ Info.plist
- `UIBackgroundModes` avec `remote-notification`
- `NSUserNotificationUsageDescription`

### ✅ Runner.entitlements
- `aps-environment` configuré

## 🧪 **Test des notifications**

### 1. **Tester en développement**
```bash
# Lancer l'app sur un device iOS physique
flutter run --release
```

### 2. **Vérifier les logs**
- Dans Xcode Console : `📱 APNS Token registered`
- Dans Flutter Console : `🔑 Token FCM obtenu`

### 3. **Envoyer une notification test**
```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
-H "Authorization: key=YOUR_SERVER_KEY" \
-H "Content-Type: application/json" \
-d '{
  "to": "FCM_TOKEN_IOS",
  "notification": {
    "title": "Test iOS",
    "body": "Notification test pour iOS"
  },
  "priority": "high"
}'
```

## ❗ **Points importants**

1. **Device physique requis** : Les notifications ne fonctionnent PAS sur le simulateur iOS
2. **Certificat de production** : Pour l'App Store, utilisez un certificat de production
3. **Bundle ID** : Doit correspondre exactement à celui d'Apple Developer Portal
4. **Permissions** : L'utilisateur doit accepter les notifications au premier lancement

## 🐛 **Troubleshooting**

### Problème : Token APNS non généré
```bash
# Vérifier le Bundle ID
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/
# Doit être : com.liya.ci.v1
```

### Problème : Notifications non reçues
1. Vérifier que l'app est en background
2. Vérifier le certificat APNs dans Firebase
3. Vérifier les logs Xcode pour les erreurs APNS

### Problème : Erreur de signature
1. Vérifier l'équipe de développement dans Xcode
2. Régénérer les profils de provisioning
3. Clean et rebuild le projet 