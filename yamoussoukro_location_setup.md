# 🗺️ Configuration de Yamoussoukro dans l'émulateur iOS

## 📍 Coordonnées de Yamoussoukro
- **Latitude :** `6.8270`
- **Longitude :** `-5.2890`
- **Pays :** Côte d'Ivoire
- **Région :** Lacs

## 🔧 Méthodes de configuration

### Méthode 1 : Via Simulator iOS (Recommandée)

1. **Lancer l'émulateur :**
   ```bash
   flutter run -d "iPhone 16 Pro Max"
   ```

2. **Dans le Simulator iOS :**
   - Allez dans **Features** → **Location**
   - Sélectionnez **Custom Location**
   - Entrez les coordonnées :
     - Latitude : `6.8270`
     - Longitude : `-5.2890`

3. **Vérifier la configuration :**
   - La carte devrait maintenant centrer sur Yamoussoukro
   - Les calculs de distance se feront depuis Yamoussoukro

### Méthode 2 : Via ligne de commande

1. **Lister les émulateurs :**
   ```bash
   xcrun simctl list devices
   ```

2. **Configurer la localisation :**
   ```bash
   xcrun simctl location "iPhone 16 Pro Max" set 6.8270 -5.2890
   ```

3. **Vérifier la configuration :**
   ```bash
   xcrun simctl location "iPhone 16 Pro Max"
   ```

### Méthode 3 : Dans le code Flutter

Le code a été modifié pour utiliser Yamoussoukro par défaut :

```dart
// Position simulée du livreur (pour la démo) - Yamoussoukro
LatLng _driverPosition = const LatLng(6.8270, -5.2890); // Yamoussoukro

// Position par défaut de Yamoussoukro
static const LatLng yamoussoukroPosition = LatLng(6.8270, -5.2890);
```

## 🎯 Avantages de Yamoussoukro

- **Capitale politique** de la Côte d'Ivoire
- **Position centrale** dans le pays
- **Infrastructure développée** pour les tests
- **Coordonnées précises** pour les calculs de distance

## 🚀 Test de la configuration

1. **Lancer l'application :**
   ```bash
   flutter run -d "iPhone 16 Pro Max"
   ```

2. **Tester la localisation :**
   - Aller dans la page de suivi de livraison
   - Vérifier que la carte centre sur Yamoussoukro
   - Tester les calculs de distance

3. **Vérifier les fonctionnalités :**
   - Suivi du livreur depuis Yamoussoukro
   - Calculs de distance et temps
   - Animations de mouvement

## 📱 Configuration permanente

Pour que cette configuration persiste entre les sessions :

1. **Dans le Simulator :**
   - Features → Location → Custom Location
   - Sauvegarder les coordonnées

2. **Dans le code :**
   - Les coordonnées sont maintenant hardcodées
   - Yamoussoukro sera utilisé par défaut

## 🔍 Vérification

Après configuration, vous devriez voir :
- ✅ Carte centrée sur Yamoussoukro
- ✅ Marqueur du livreur à Yamoussoukro
- ✅ Calculs de distance depuis Yamoussoukro
- ✅ Route tracée depuis Yamoussoukro vers la destination 