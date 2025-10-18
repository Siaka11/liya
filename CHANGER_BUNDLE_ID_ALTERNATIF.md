# 🔄 Changer le Bundle ID vers une Alternative

## 🎯 **Nouveau Bundle ID**
- **Nouveau** : `com.liya.app.ci`
- **Motif** : Bundle ID final pour l'environnement CI

## 🔧 **Étapes de Changement**

### 1. **Choisir un Bundle ID Unique**

Options suggérées :
- `com.liya.app.ci` ✅ (déjà appliqué)
- `com.liya.app`
- `com.app.liya`
- `com.ouattarasiaka.liya`

### 2. **Si vous voulez changer vers une autre option :**

```bash
# Remplacez NOUVEAU_BUNDLE_ID par votre choix
sed -i '' 's/com\.ouattarasiaka\.liya/NOUVEAU_BUNDLE_ID/g' ios/Runner.xcodeproj/project.pbxproj
```

### 3. **Vérifier le changement :**

```bash
grep -r "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj
```

## 📋 **Prochaines Étapes**

Avec le nouveau Bundle ID `com.liya.app.ci` :

1. **Apple Developer Portal** :
   - Créer App ID avec `com.liya.app.ci`
   - Créer Provisioning Profiles

2. **Firebase Console** :
   - Créer nouvelle app iOS avec `com.liya.app.ci`
   - Télécharger nouveau GoogleService-Info.plist

3. **Google Services** :
   - reCAPTCHA Enterprise : Ajouter `com.liya.app.ci`
   - Google Maps API : Ajouter `com.liya.app.ci`

## ✅ **Test dans Xcode**

1. Ouvrir `ios/Runner.xcworkspace`
2. Sélectionner le projet Runner
3. Aller dans Signing & Capabilities
4. Vérifier que le Bundle ID est `com.liya.app.ci`
5. Cliquer sur "Try Again"

Le Bundle ID devrait maintenant être accepté !
