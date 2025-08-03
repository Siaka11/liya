# Guide d'Installation du Système de Notifications LIYA

## 📋 Vue d'ensemble

Ce guide explique comment configurer et utiliser le système de notifications complet pour l'application LIYA, incluant :
- Notifications Firebase Cloud Messaging (FCM)
- Notifications locales
- Boutons de notifications dans l'interface
- Cloud Functions pour les notifications automatiques

## 🚀 Installation

### 1. Dépendances Flutter

Les dépendances suivantes sont déjà incluses dans `pubspec.yaml` :
```yaml
firebase_messaging: ^15.1.3
flutter_local_notifications: ^17.0.0
permission_handler: ^11.3.0
```

### 2. Configuration Firebase

#### A. Configuration Android

1. **google-services.json** : Assurez-vous que le fichier est présent dans `android/app/`
2. **AndroidManifest.xml** : Ajoutez les permissions dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

3. **build.gradle** : Vérifiez que les dépendances Firebase sont présentes dans `android/app/build.gradle` :

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'com.google.firebase:firebase-analytics'
}
```

#### B. Configuration iOS

1. **GoogleService-Info.plist** : Assurez-vous que le fichier est présent dans `ios/Runner/`
2. **Info.plist** : Ajoutez les permissions dans `ios/Runner/Info.plist` :

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
<key>NSUserNotificationUsageDescription</key>
<string>Cette application utilise les notifications pour vous informer des mises à jour de vos commandes et livraisons.</string>
```

### 3. Configuration Cloud Functions

#### A. Installation Firebase CLI

```bash
npm install -g firebase-tools
```

#### B. Initialisation du projet

```bash
firebase login
firebase init functions
```

#### C. Déploiement des fonctions

```bash
cd functions
npm install
firebase deploy --only functions
```

## 🔧 Configuration

### 1. Initialisation du Service de Notifications

Le service est automatiquement initialisé dans `main.dart` :

```dart
// Dans main.dart
await notificationService.initialize();
```

### 2. Enregistrement des Utilisateurs

Pour enregistrer un utilisateur pour les notifications :

```dart
await notificationService.registerUserForNotifications(
  userId, 
  userType // 'client', 'delivery', 'admin'
);
```

### 3. Gestion des Permissions

Les permissions sont automatiquement demandées lors de l'initialisation. Pour vérifier le statut :

```dart
bool enabled = await notificationService.areNotificationsEnabled();
```

## 🎯 Utilisation

### 1. Boutons de Notifications

Le système inclut plusieurs widgets de boutons de notifications :

#### A. NotificationButton
```dart
NotificationButton(
  onPressed: () {
    // Action personnalisée
  },
  backgroundColor: Colors.white,
  iconColor: Colors.black,
  size: 48.0,
  showBadge: true,
)
```

#### B. NotificationAppBarButton
```dart
NotificationAppBarButton(
  backgroundColor: Colors.transparent,
  iconColor: Colors.white,
)
```

#### C. NotificationFloatingButton
```dart
NotificationFloatingButton(
  backgroundColor: Colors.white,
  iconColor: Colors.black,
)
```

### 2. Intégration dans les Pages

#### A. Pages Restaurant
- ✅ `restaurant_detail_page.dart`
- ✅ `dish_detail_page.dart`

#### B. Pages Livraison
- ✅ `delivery_dashboard_page.dart`
- ✅ `home_delivery_page.dart`

### 3. Gestion des Notifications

#### A. Notifications Automatiques

Les Cloud Functions déclenchent automatiquement des notifications pour :

1. **Commande assignée** : Client et livreur notifiés
2. **Livraison en cours** : Client notifié
3. **Livraison terminée** : Client et livreur notifiés
4. **Nouvelle commande restaurant** : Tous les livreurs notifiés
5. **Nouveau colis** : Tous les livreurs notifiés

#### B. Navigation depuis les Notifications

Le système gère la navigation automatique selon le type de notification :

```dart
void _handleNotificationNavigation(RemoteMessage message) {
  switch (message.data['type']) {
    case 'order_assigned':
      // Naviguer vers la page de détail de commande
      break;
    case 'new_delivery':
      // Naviguer vers le dashboard livreur
      break;
    // ... autres cas
  }
}
```

## 🧪 Tests

### 1. Test des Notifications Locales

```dart
// Test d'envoi de notification locale
await notificationService._showLocalNotification(
  RemoteMessage(
    notification: RemoteNotification(
      title: 'Test',
      body: 'Notification de test',
    ),
    data: {'type': 'test'},
  ),
);
```

### 2. Test des Cloud Functions

```bash
# Test local
firebase emulators:start --only functions

# Test en production
firebase functions:shell
```

### 3. Test des Permissions

```dart
// Vérifier les permissions
bool hasPermission = await Permission.notification.isGranted;

// Demander les permissions
await Permission.notification.request();
```

## 🔍 Débogage

### 1. Logs Flutter

```dart
// Activer les logs détaillés
print('🔑 FCM Token: ${notificationService.fcmToken}');
print('📱 Notification reçue: ${message.notification?.title}');
```

### 2. Logs Cloud Functions

```bash
# Voir les logs des fonctions
firebase functions:log

# Logs en temps réel
firebase functions:log --tail
```

### 3. Vérification des Tokens

```dart
// Vérifier si le token est valide
String? token = await notificationService.fcmToken;
if (token != null) {
  print('Token FCM valide: $token');
} else {
  print('Token FCM non disponible');
}
```

## 🚨 Problèmes Courants

### 1. Notifications non reçues

**Cause possible** : Permissions non accordées
**Solution** :
```dart
await Permission.notification.request();
```

### 2. Token FCM non généré

**Cause possible** : Firebase non initialisé
**Solution** :
```dart
await Firebase.initializeApp();
await notificationService.initialize();
```

### 3. Cloud Functions non déclenchées

**Cause possible** : Règles Firestore trop restrictives
**Solution** : Vérifier les règles Firestore pour permettre l'écriture des fonctions

### 4. Notifications en arrière-plan non reçues

**Cause possible** : Configuration iOS manquante
**Solution** : Vérifier `Info.plist` et les capacités de l'app

## 📱 Fonctionnalités Avancées

### 1. Badges de Notifications

Le système inclut un système de badges automatique :

```dart
// Incrémenter le compteur
await SharedPreferences.getInstance().then((prefs) {
  int count = prefs.getInt('notification_count') ?? 0;
  prefs.setInt('notification_count', count + 1);
});
```

### 2. Notifications Personnalisées

```dart
// Envoyer une notification personnalisée
await notificationService.sendCustomNotification(
  userId: 'user_id',
  title: 'Titre personnalisé',
  body: 'Message personnalisé',
  data: {'type': 'custom'},
);
```

### 3. Gestion des Types d'Utilisateurs

Le système distingue les types d'utilisateurs :
- `client` : Notifications de commandes
- `delivery` : Notifications de livraisons
- `admin` : Notifications administratives

## 🔄 Maintenance

### 1. Nettoyage des Tokens

Les Cloud Functions nettoient automatiquement les tokens invalides toutes les 24h.

### 2. Mise à Jour des Dépendances

```bash
# Mettre à jour les dépendances Flutter
flutter pub upgrade

# Mettre à jour les dépendances Cloud Functions
cd functions
npm update
```

### 3. Monitoring

```bash
# Surveiller les performances
firebase functions:log --only notifyOrderAssigned

# Vérifier les erreurs
firebase functions:log --level error
```

## 📚 Ressources

- [Documentation Firebase Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Documentation Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Documentation Cloud Functions](https://firebase.google.com/docs/functions)

## 🆘 Support

Pour toute question ou problème :
1. Vérifiez les logs Firebase Console
2. Testez avec les fonctions de test incluses
3. Consultez la documentation Firebase
4. Contactez l'équipe de développement 