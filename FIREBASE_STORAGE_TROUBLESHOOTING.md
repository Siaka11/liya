# Firebase Storage Troubleshooting Guide

## Erreur: "No object exists at the desired reference"

Cette erreur indique un problème avec la configuration ou les permissions de Firebase Storage.

## 🔍 Diagnostic Automatique

L'application inclut maintenant un diagnostic automatique qui s'exécute au démarrage. Vérifiez les logs de la console pour voir les résultats.

## 🛠️ Solutions

### 1. Vérifier la Configuration Firebase

Assurez-vous que votre projet Firebase est correctement configuré :

1. **Vérifiez le fichier `google-services.json`** (Android) :
   - Le `storage_bucket` doit être : `liya-a4a9f.firebasestorage.app`
   - Le `project_id` doit être : `liya-a4a9f`

2. **Vérifiez le fichier `GoogleService-Info.plist`** (iOS) :
   - Le `STORAGE_BUCKET` doit être : `liya-a4a9f.firebasestorage.app`
   - Le `PROJECT_ID` doit être : `liya-a4a9f`

### 2. Configurer les Règles de Sécurité Firebase Storage

Dans la console Firebase, allez dans **Storage > Rules** et utilisez ces règles temporaires pour les tests :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;  // ⚠️ ATTENTION: Pour les tests seulement
    }
  }
}
```

**⚠️ IMPORTANT** : Ces règles permettent l'accès complet. Pour la production, utilisez des règles plus restrictives :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Vérifier l'Activation de Firebase Storage

1. Allez dans la **Console Firebase**
2. Sélectionnez votre projet `liya-a4a9f`
3. Dans le menu de gauche, cliquez sur **Storage**
4. Si Storage n'est pas activé, cliquez sur **Commencer**
5. Choisissez un emplacement (ex: `us-central1`)
6. Choisissez les règles de sécurité (commencez par les règles de test)

### 4. Tester la Configuration

Utilisez la page de test intégrée dans l'application :

```dart
// Naviguez vers cette page pour tester
FirebaseStorageTestPage()
```

### 5. Vérifier les Permissions

#### Android
Vérifiez que votre `AndroidManifest.xml` contient :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### iOS
Vérifiez que votre `Info.plist` contient les permissions nécessaires.

### 6. Diagnostic Manuel

Si le diagnostic automatique ne fonctionne pas, vous pouvez exécuter ce code manuellement :

```dart
import 'package:liya/core/services/firebase_storage_helper.dart';

// Dans votre code
await FirebaseStorageHelper.printDiagnostics();
```

## 🐛 Codes d'Erreur Courants

| Code d'Erreur | Cause | Solution |
|---------------|-------|----------|
| `storage/unauthorized` | Permissions insuffisantes | Vérifiez les règles de sécurité |
| `storage/bucket-not-found` | Bucket inexistant | Activez Firebase Storage |
| `storage/object-not-found` | Référence invalide | Vérifiez la configuration |
| `storage/quota-exceeded` | Quota dépassé | Vérifiez l'utilisation du stockage |
| `storage/unauthenticated` | Non authentifié | Implémentez l'authentification |

## 🔧 Améliorations Apportées

### 1. Service d'Upload Amélioré

Le service `ImageUploadService` a été amélioré avec :
- Validation des fichiers
- Gestion d'erreurs détaillée
- Surveillance du progrès
- Métadonnées personnalisées

### 2. Helper de Diagnostic

Le `FirebaseStorageHelper` fournit :
- Diagnostic automatique
- Test de connectivité
- Vérification des permissions
- Nettoyage des fichiers temporaires

### 3. Page de Test

Une page de test dédiée pour :
- Tester les uploads
- Voir les diagnostics en temps réel
- Nettoyer les fichiers de test

## 📱 Utilisation

### Test Rapide

1. Lancez l'application
2. Vérifiez les logs de la console
3. Si des erreurs apparaissent, suivez les recommandations

### Test Complet

1. Naviguez vers la page de test Firebase Storage
2. Exécutez le diagnostic
3. Testez un upload d'image
4. Vérifiez les résultats

## 🚨 En Cas de Problème Persistant

1. **Vérifiez la console Firebase** pour les erreurs côté serveur
2. **Vérifiez les logs de l'application** pour les détails d'erreur
3. **Testez avec une image plus petite** (moins de 1MB)
4. **Vérifiez votre connexion internet**
5. **Redémarrez l'application**

## 📞 Support

Si le problème persiste après avoir suivi ces étapes :

1. Collectez les logs de diagnostic
2. Notez les étapes qui reproduisent l'erreur
3. Vérifiez la configuration Firebase dans la console
4. Contactez le support avec ces informations

## 🔄 Mise à Jour

Pour mettre à jour la configuration :

1. Téléchargez les nouveaux fichiers de configuration depuis la console Firebase
2. Remplacez `google-services.json` et `GoogleService-Info.plist`
3. Redémarrez l'application
4. Exécutez le diagnostic

---

**Note** : Ce guide est spécifique au projet LIYA. Adaptez les configurations selon votre projet Firebase. 