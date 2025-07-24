# Guide d'activation Firebase Storage

## Problème identifié
- Modal de configuration utilise l'ancien nom de bucket
- Redirection vers la facturation lors du clic sur "Commencer"
- Firebase Storage n'est pas activé dans Firebase Console

## Solutions

### Solution 1 : Activer via Firebase Console (Recommandée)

1. **Aller directement sur Firebase Console** :
   ```
   https://console.firebase.google.com/project/liya-a4a9f/storage
   ```

2. **Si Storage n'apparaît pas dans le menu** :
   - Aller dans **Project Settings** (⚙️)
   - Onglet **"Intégrations"**
   - Chercher **"Cloud Storage"**
   - Cliquer sur **"Configurer"**

3. **Si toujours pas d'option Storage** :
   - Aller dans **"Build"** dans le menu
   - Chercher **"Storage"**
   - Cliquer sur **"Commencer"**

### Solution 2 : Activer via Google Cloud Console

1. **Aller sur Google Cloud Console** :
   ```
   https://console.cloud.google.com/storage/browser?project=liya-a4a9f
   ```

2. **Vérifier que le bucket existe** :
   - Le bucket `liya-a4a9f-storage` doit être visible
   - Si oui, passer à la configuration des règles

3. **Configurer les permissions** :
   - Aller dans **IAM & Admin** > **IAM**
   - Ajouter le rôle **"Storage Object Admin"** pour votre compte

### Solution 3 : Configuration manuelle

1. **Ignorer la modal** de configuration du bucket par défaut
2. **Aller directement dans Firebase Console** > **Storage**
3. **Configurer les règles de sécurité** manuellement

## Configuration des règles

Une fois Storage activé, configurer les règles :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;  // Pour les tests
    }
  }
}
```

## Vérification

Après activation, vérifier que :
- Storage apparaît dans le menu Firebase Console
- Le bucket `liya-a4a9f-storage` est accessible
- Les règles de sécurité sont configurées
- L'upload d'images fonctionne dans l'app 