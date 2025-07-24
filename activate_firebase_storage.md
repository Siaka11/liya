# Guide d'activation de Firebase Storage

## Problème
Quand vous cliquez sur "Commencer" dans Firebase Storage, vous êtes redirigé vers la page des forfaits du Google Developer Program.

## Solutions

### Solution 1 : Via Google Cloud Console (Recommandée)

1. **Aller sur Google Cloud Console** :
   ```
   https://console.cloud.google.com/storage/browser?project=liya-a4a9f
   ```

2. **Créer le bucket** :
   - Nom : `liya-a4a9f.firebasestorage.app`
   - Emplacement : `us-central1`
   - Classe : `Standard`
   - Contrôle d'accès : `Uniform`

3. **Configurer les permissions** :
   - Aller dans IAM & Admin > IAM
   - Ajouter le rôle "Storage Object Admin" pour votre compte

### Solution 2 : Via Firebase CLI

```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter
firebase login

# Initialiser Firebase dans votre projet
firebase init storage

# Activer Storage
firebase projects:addfirebase liya-a4a9f
```

### Solution 3 : Via l'API REST

```bash
# Créer le bucket via l'API
curl -X POST \
  "https://storage.googleapis.com/storage/v1/b" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "liya-a4a9f.firebasestorage.app",
    "location": "US-CENTRAL1",
    "storageClass": "STANDARD"
  }'
```

### Solution 4 : Contact Support Firebase

Si aucune solution ne fonctionne :
1. Aller sur [Firebase Support](https://firebase.google.com/support)
2. Créer un ticket de support
3. Expliquer le problème de redirection

## Vérification

Après activation, vérifiez que :
- Le bucket `liya-a4a9f.firebasestorage.app` existe
- Les règles de sécurité sont configurées
- L'upload d'images fonctionne dans votre app

## Configuration des règles

Une fois le bucket créé, configurez les règles dans Firebase Console > Storage > Rules :

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