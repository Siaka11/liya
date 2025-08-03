# Noms de bucket Firebase Storage alternatifs

## Problème
Le nom `liya-a4a9f.firebasestorage.app` nécessite une vérification de domaine.

## Solutions

### Option 1 : Nom de bucket simple (Recommandé)
```
liya-a4a9f-storage
```

### Option 2 : Nom avec préfixe
```
liya-app-storage
```

### Option 3 : Nom avec timestamp
```
liya-storage-2024
```

### Option 4 : Nom avec région
```
liya-storage-us-central1
```

## Configuration requise

### Étape 1 : Créer le bucket avec un nom simple
1. **Nom du bucket** : `liya-a4a9f-storage`
2. **Emplacement** : `us-central1`
3. **Classe de stockage** : `Standard`
4. **Contrôle d'accès** : `Uniform`

### Étape 2 : Mettre à jour la configuration Firebase
Une fois le bucket créé, mettez à jour :
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)

### Étape 3 : Télécharger les nouveaux fichiers de configuration
1. Aller dans Firebase Console > Project Settings
2. Télécharger les nouveaux fichiers de configuration
3. Remplacer les anciens fichiers dans votre projet

## Vérification

Après création, vérifiez que :
- Le bucket est accessible
- Les règles de sécurité sont configurées
- L'upload d'images fonctionne 