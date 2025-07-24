# Créer le bucket avec Firebase CLI

## Problème
L'URL de vérification de domaine n'est pas accessible, mais nous voulons utiliser l'ancien nom `liya-a4a9f.firebasestorage.app`.

## Solution : Firebase CLI

### Étape 1 : Installer Firebase CLI

```bash
# Installer Firebase CLI globalement
npm install -g firebase-tools

# Ou avec yarn
yarn global add firebase-tools
```

### Étape 2 : Se connecter à Firebase

```bash
# Se connecter avec votre compte Google
firebase login

# Vérifier que vous êtes connecté
firebase projects:list
```

### Étape 3 : Initialiser Firebase dans votre projet

```bash
# Aller dans le dossier de votre projet
cd /Users/macbookpro/Documents/liya28062

# Initialiser Firebase
firebase init

# Sélectionner :
# - Storage
# - Project: liya-a4a9f
# - Bucket: liya-a4a9f.firebasestorage.app
```

### Étape 4 : Créer le bucket

```bash
# Créer le bucket avec l'ancien nom
firebase projects:addfirebase liya-a4a9f

# Ou directement via gcloud
gcloud storage buckets create gs://liya-a4a9f.firebasestorage.app \
  --project=liya-a4a9f \
  --location=us-central1 \
  --uniform-bucket-level-access
```

### Étape 5 : Configurer les règles

```bash
# Aller dans Firebase Console > Storage > Rules
# Remplacer les règles par :

rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;  // Pour les tests
    }
  }
}
```

## Alternative : Création manuelle

Si Firebase CLI ne fonctionne pas :

1. **Aller dans Google Cloud Console**
2. **Storage > Browser**
3. **Créer un bucket**
4. **Nom** : `liya-a4a9f.firebasestorage.app`
5. **Emplacement** : `us-central1`
6. **Classe** : `Standard`
7. **Contrôle d'accès** : `Uniform`

## Vérification

Après création :
- Le bucket doit apparaître dans Firebase Console
- L'upload d'images doit fonctionner
- Pas d'erreurs "object-not-found" 