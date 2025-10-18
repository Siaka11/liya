# 📱 Guide Complet : Changement Bundle ID iOS

## 🎯 **Nouveau Bundle ID**
- **Ancien** : `com.liya.ci.v1`
- **Nouveau** : `com.liya.app`

## ✅ **Étapes Déjà Effectuées**

### 1. ✅ Modification Xcode Project
- `ios/Runner.xcodeproj/project.pbxproj` : Bundle ID mis à jour vers `com.liya.app`

### 2. ✅ Vérification Info.plist
- Le fichier utilise `$(PRODUCT_BUNDLE_IDENTIFIER)` → Mise à jour automatique

## 🔧 **Étapes Restantes**

### 3. 🔄 Firebase Console
```bash
# Actions requises :
1. Aller sur https://console.firebase.google.com/
2. Projet : liya-a4a9f
3. Project Settings → General
4. Ajouter nouvelle app iOS avec Bundle ID : com.liya.app
5. Télécharger nouveau GoogleService-Info.plist
6. Remplacer ios/Runner/GoogleService-Info.plist
```

### 4. 🔄 Apple Developer Portal
```bash
# Actions requises :
1. Aller sur https://developer.apple.com/
2. Certificates, Identifiers & Profiles
3. Identifiers → + → App IDs
4. Bundle ID : com.liya.app
5. Capabilities nécessaires :
   - Push Notifications
   - Associated Domains
   - Sign In with Apple (si utilisé)
6. Créer Provisioning Profile pour ce Bundle ID
7. Télécharger et installer le profil
```

### 5. 🔄 Services à Vérifier

#### Google Maps
- Vérifier les restrictions par Bundle ID
- Mettre à jour si nécessaire

#### Push Notifications
- Créer nouveaux certificats APNs pour le nouveau Bundle ID
- Mettre à jour dans Firebase Console

#### Analytics
- Vérifier Google Analytics
- Firebase Analytics se mettra à jour automatiquement

### 6. 🔄 Test et Validation

#### Test Local
```bash
# Nettoyer le projet
flutter clean
cd ios && pod install && cd ..

# Build pour test
flutter build ios --debug

# Vérifier dans Xcode
open ios/Runner.xcworkspace
```

#### Test sur Appareil
```bash
# Build pour appareil physique
flutter build ios --release
```

## ⚠️ **Points d'Attention**

### Migration des Données Utilisateur
- Les utilisateurs devront **réinstaller l'app** (nouveau Bundle ID = nouvelle app)
- Les données locales seront perdues
- Les données Firebase resteront (même projet)

### App Store
- Si déjà publiée : **nouvelle app** à créer
- L'ancienne app `com.liya.ci.v1` restera séparée
- Pas de migration automatique possible

### Notifications Push
- Nouveaux certificats APNs requis
- Re-enregistrement des tokens FCM pour les utilisateurs

## 🚀 **Checklist Finale**

- [ ] Bundle ID changé dans Xcode Project ✅
- [ ] Nouveau GoogleService-Info.plist téléchargé et installé
- [ ] Nouvel App ID créé dans Apple Developer Portal
- [ ] Nouveau Provisioning Profile créé et installé
- [ ] Certificats APNs mis à jour
- [ ] Services tiers vérifiés (Google Maps, etc.)
- [ ] Test de build réussi
- [ ] Test sur appareil physique réussi
- [ ] Push notifications testées

## 📋 **Commandes Utiles**

```bash
# Nettoyer et rebuild
flutter clean
cd ios && pod install && cd ..
flutter build ios

# Ouvrir Xcode pour vérification
open ios/Runner.xcworkspace

# Vérifier le Bundle ID
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/
```

## 🔍 **Vérification Finale**

Après toutes les étapes, vérifiez que :
1. L'app se lance correctement
2. Firebase fonctionne (Auth, Firestore)
3. Google Maps s'affiche
4. Push notifications fonctionnent
5. Tous les services tiers sont opérationnels

## 📞 **Support**

En cas de problème :
1. Vérifier les logs Xcode
2. Vérifier Firebase Console
3. Vérifier Apple Developer Portal
4. Consulter la documentation Flutter iOS

