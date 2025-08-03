# 🗺️ Guide de configuration Google Maps pour iOS

## Étape 1 : Créer une clé API Google Maps

### 1. Aller sur Google Cloud Console
- Ouvrir : https://console.cloud.google.com/
- Créer un nouveau projet ou sélectionner le projet existant

### 2. Activer les APIs nécessaires
- **Maps SDK for iOS**
- **Places API** (pour la recherche d'adresses)
- **Directions API** (pour les itinéraires)

### 3. Créer une clé API
- Aller dans "Credentials" (Identifiants)
- Cliquer sur "+ CREATE CREDENTIALS" → "API key"
- Copier la clé générée

## Étape 2 : Configurer la clé dans iOS

### 1. Modifier AppDelegate.swift
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("VOTRE_CLE_API_ICI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 2. Modifier Info.plist
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette application nécessite l'accès à votre localisation pour le suivi de livraison</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Cette application nécessite l'accès à votre localisation pour le suivi de livraison</string>
```

## Étape 3 : Tester la configuration

### 1. Vérifier que la carte s'affiche
- Lancer l'application
- Aller sur la page de suivi
- La carte Google Maps doit s'afficher

### 2. Tester la localisation
- Autoriser l'accès à la localisation
- Vérifier que votre position apparaît sur la carte

## Problèmes courants

### ❌ Carte grise
- Vérifier que la clé API est correcte
- Vérifier que les APIs sont activées
- Vérifier la facturation Google Cloud

### ❌ Erreur de localisation
- Vérifier les permissions dans Info.plist
- Vérifier les paramètres iOS (Réglages > Confidentialité > Localisation)

## Coûts Google Maps

### Gratuit (par mois)
- 28,500 chargements de carte
- 2,500 requêtes Places
- 2,500 requêtes Directions

### Payant (après la limite gratuite)
- $7 par 1,000 chargements de carte
- $17 par 1,000 requêtes Places
- $5 par 1,000 requêtes Directions

## Alternative : Apple Maps

Si vous préférez utiliser Apple Maps (gratuit) :
- Remplacer `google_maps_flutter` par `apple_maps_flutter`
- Pas besoin de clé API
- Intégration native iOS 