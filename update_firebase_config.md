# Mise à jour de la configuration Firebase

## Problème identifié
Firebase Console affiche encore l'ancien bucket `liya-a4a9f.firebasestorage.app` au lieu du nouveau `liya-a4a9f-storage`.

## Solution : Mettre à jour la configuration

### Étape 1 : Aller dans Firebase Console Project Settings

1. **Aller sur** : [Firebase Console](https://console.firebase.google.com/project/liya-a4a9f)
2. **Cliquer sur l'icône ⚙️** (Project Settings)
3. **Aller dans l'onglet "General"**

### Étape 2 : Mettre à jour la configuration Storage

1. **Dans la section "Your apps"**
2. **Cliquer sur votre app Android** (com.liya.ci)
3. **Cliquer sur "Download google-services.json"**
4. **Remplacer** le fichier existant

### Étape 3 : Mettre à jour iOS aussi

1. **Cliquer sur votre app iOS** (com.liya.ci)
2. **Cliquer sur "Download GoogleService-Info.plist"**
3. **Remplacer** le fichier existant

### Étape 4 : Vérifier la configuration

Après téléchargement, vérifier que :
- `storage_bucket` = `liya-a4a9f-storage` (pas firebasestorage.app)
- Les fichiers sont bien remplacés dans le projet

## Alternative : Configuration manuelle

Si les fichiers ne se mettent pas à jour automatiquement :

### Étape 1 : Aller dans Google Cloud Console
1. **Aller sur** : [Google Cloud Console](https://console.cloud.google.com/storage/browser?project=liya-a4a9f)
2. **Vérifier** que le bucket `liya-a4a9f-storage` existe

### Étape 2 : Configurer Firebase Storage
1. **Aller dans Firebase Console** > **Storage**
2. **Cliquer sur le sélecteur de bucket** (en haut à droite)
3. **Choisir** `liya-a4a9f-storage`

### Étape 3 : Configurer les règles
1. **Aller dans l'onglet "Rules"**
2. **Remplacer les règles** par celles du fichier `firebase_storage_rules.txt`
3. **Cliquer sur "Publier"**

## Vérification

Après mise à jour :
- Firebase Console doit afficher `liya-a4a9f-storage`
- L'upload d'images doit fonctionner
- Pas d'erreurs "object-not-found" 