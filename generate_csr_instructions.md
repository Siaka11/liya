# 🔑 Génération du Certificate Signing Request (CSR)

## Étapes sur votre Mac :

### 1. Ouvrir l'application "Trousseau d'accès" (Keychain Access)
- Allez dans Applications > Utilitaires > Trousseau d'accès
- Ou recherchez "Keychain Access" dans Spotlight

### 2. Créer une demande de certificat
- Dans la barre de menu : **Trousseau d'accès** > **Assistant de certificat** > **Demander un certificat à une autorité de certification**

### 3. Remplir les informations :
- **Adresse e-mail de l'utilisateur** : `votre-email@example.com` (utilisez votre email Apple Developer)
- **Nom commun** : `Liya Push Notification Certificate`
- **Adresse e-mail de l'AC** : Laissez VIDE
- **Demande** : Sélectionnez "**Enregistrée sur le disque**"
- **Me permettre de spécifier les informations de paire de clés** : COCHÉ

### 4. Paramètres de la clé :
- **Taille de clé** : `2048 bits`
- **Algorithme** : `RSA`

### 5. Enregistrer le fichier
- Choisissez un emplacement (ex: Bureau)
- Nom du fichier : `LiyaPushCertificate.certSigningRequest`
- Cliquez sur "Enregistrer"

## ⚠️ Points importants :
- Gardez l'application Trousseau d'accès ouverte
- NE FERMEZ PAS le trousseau avant d'avoir installé le certificat final
- Le fichier .certSigningRequest sera nécessaire pour l'étape suivante 