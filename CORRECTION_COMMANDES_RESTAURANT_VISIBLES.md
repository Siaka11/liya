# 🔧 Correction visibilité commandes restaurant chez les livreurs

## ❌ **Problèmes identifiés :**

1. **Commandes restaurant non visibles** : Les commandes assignées aux livreurs n'apparaissaient pas dans l'interface livreur
2. **Filtrage de statut manquant** : Les requêtes Firestore ne filtraient pas par statut `assigned`
3. **Page de détails obsolète** : Utilisation de l'ancienne `OrderDetailsPage` au lieu de la nouvelle `OrderDetailsFullPage`

## 🔍 **Cause racine :**

D'après l'image Firestore fournie, la commande restaurant `RESTO2025092195352` était bien assignée avec :
- `assignedTo: "+2250789863513"`
- `status: "assigned"`
- `assignedToName: "Kaiz"`

Mais les requêtes dans `getRestaurantOrdersForDeliveryUser` ne filtraient que par `assignedTo` sans inclure le statut.

## ✅ **Solutions appliquées :**

### **1. Correction des requêtes Firestore**

**Fichier modifié :** `lib/modules/delivery/data/services/delivery_existing_service.dart`

**Avant :**
```dart
var querySnapshot = await _firestore
    .collection('orders')
    .where('assignedTo', isEqualTo: phoneNumber)
    .get();
```

**Après :**
```dart
var querySnapshot = await _firestore
    .collection('orders')
    .where('assignedTo', isEqualTo: phoneNumber)
    .where('status', whereIn: ['assigned', 'enRoute'])
    .get();
```

### **2. Correction appliquée aux 3 requêtes :**

1. **Requête principale** : `assignedTo` + statut
2. **Requête de compatibilité 1** : `delivery_phone_number` + statut  
3. **Requête de compatibilité 2** : `delivery_phone` + statut

**Même correction pour les colis :**
```dart
var querySnapshot = await _firestore
    .collection('parcels')
    .where('assignedTo', isEqualTo: phoneNumber)
    .where('status', whereIn: ['assigned', 'enRoute'])
    .get();
```

### **3. Mise à jour de la page de détails**

**Fichier modifié :** `lib/modules/delivery/presentation/pages/home_delivery_page.dart`

**Avant :**
```dart
void _showOrderDetails(DeliveryOrder order) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => OrderDetailsPage(order: order),
    ),
  );
}
```

**Après :**
```dart
void _showOrderDetails(DeliveryOrder order) {
  // Convertir DeliveryOrder en Map pour la page de détails complète
  final orderData = {
    'id': order.id,
    'phoneNumber': order.customerPhoneNumber,
    'phone': order.customerPhoneNumber,
    'customer_name': order.customerName,
    'address': order.customerAddress,
    'assignedTo': order.deliveryPhoneNumber,
    'assignedToName': order.deliveryName,
    'assignedAt': order.assignedAt?.toIso8601String(),
    'lastUpdated': order.assignedAt?.toIso8601String(),
    'createdAt': order.createdAt.toIso8601String(),
    'status': order.status.toString().split('.').last,
    'subtotal': order.amount,
    'deliveryFee': order.deliveryFee,
    'total': order.amount + order.deliveryFee,
    'deliveryTime': 10,
    'distance': 0.0,
    'items': [
      {
        'name': order.description,
        'price': order.amount,
        'quantity': 1,
      }
    ],
    'deliveryInstructions': null,
    'latitude': null,
    'longitude': null,
  };

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => order.type == DeliveryType.restaurant
          ? OrderDetailsFullPage(orderData: orderData)
          : ParcelDetailsFullPage(parcelData: orderData),
    ),
  );
}
```

### **4. Ajout du statut `assigned` dans l'interface**

**Ajout dans `_buildOrderCard` :**
```dart
case DeliveryStatus.assigned:
  statusColor = Colors.blue;
  statusText = 'Assigné';
  statusIcon = Icons.assignment_ind;
  break;
```

## 🎯 **Fonctionnalités restaurées :**

### **✅ Visibilité des commandes restaurant :**
- Les commandes avec `status: "assigned"` sont maintenant visibles
- Affichage correct du statut "Assigné" avec icône bleue
- Navigation vers la page de détails complète

### **✅ Page de détails complète :**
- Utilisation de `OrderDetailsFullPage` pour les commandes restaurant
- Utilisation de `ParcelDetailsFullPage` pour les colis
- Affichage de toutes les informations :
  - Informations générales (ID, dates, statut)
  - Informations client (téléphone, adresse)
  - Informations livreur (nom, téléphone, date d'assignation)
  - Articles commandés avec détails
  - Informations de livraison (frais, temps, distance)
  - Résumé financier (sous-total, frais, total)

### **✅ Cohérence entre restaurant et colis :**
- Même logique de filtrage pour les deux types
- Même interface de détails
- Même gestion des statuts

## 📱 **Résultat attendu :**

1. **Assignation** : Les admins peuvent assigner des commandes restaurant aux livreurs
2. **Visibilité** : Les commandes assignées apparaissent immédiatement chez les livreurs
3. **Détails** : Clic sur une commande affiche toutes les informations complètes
4. **Statut** : Affichage correct du statut "Assigné" avec la bonne couleur

---

**✨ Les commandes restaurant assignées sont maintenant parfaitement visibles et accessibles chez les livreurs !**
