import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/order/domain/entities/beverage.dart';

// État d'un article de commande
class OrderItemState {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final String restaurantId;
  final String description;
  final int quantity;
  final List<BeverageSelection> accompaniments;

  OrderItemState({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
    required this.description,
    required this.quantity,
    this.accompaniments = const [],
  });

  OrderItemState copyWith({
    String? id,
    String? name,
    String? price,
    String? imageUrl,
    String? restaurantId,
    String? description,
    int? quantity,
    List<BeverageSelection>? accompaniments,
  }) {
    return OrderItemState(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      restaurantId: restaurantId ?? this.restaurantId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      accompaniments: accompaniments ?? this.accompaniments,
    );
  }

  double get totalPrice {
    final priceValue =
        double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    final accompanimentsTotal =
        accompaniments.fold(0.0, (sum, acc) => sum + (acc.totalPrice));
    return (priceValue * quantity) + accompanimentsTotal;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItemState &&
        other.id == id &&
        other.accompaniments == accompaniments;
  }

  @override
  int get hashCode => id.hashCode ^ accompaniments.hashCode;
}

// État global de la commande
class ModernOrderState {
  final Map<String, OrderItemState> items;
  final bool isLoading;
  final String? error;

  ModernOrderState({
    required this.items,
    this.isLoading = false,
    this.error,
  });

  ModernOrderState copyWith({
    Map<String, OrderItemState>? items,
    bool? isLoading,
    String? error,
  }) {
    return ModernOrderState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Calculer le nombre total d'articles
  int get totalItems {
    return items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  // Calculer le prix total
  double get totalPrice {
    return items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Vérifier si la commande est vide
  bool get isEmpty => items.isEmpty;

  // Vérifier si la commande a des articles
  bool get isNotEmpty => items.isNotEmpty;

  // Obtenir la liste des articles
  List<OrderItemState> get itemsList => items.values.toList();

  // Obtenir le restaurant ID principal (le premier restaurant ajouté)
  String? get restaurantId {
    if (items.isEmpty) return null;
    final normalizedId =
        _normalizeRestaurantId(items.values.first.restaurantId);
    return _mapRestaurantId(normalizedId);
  }

  // Obtenir tous les restaurants dans la commande
  Set<String> get restaurantIds {
    return items.values.map((item) {
      final normalizedId = _normalizeRestaurantId(item.restaurantId);
      return _mapRestaurantId(normalizedId);
    }).toSet();
  }

  // Vérifier si tous les articles sont du même restaurant
  bool get isFromSameRestaurant {
    return restaurantIds.length <= 1;
  }

  // Obtenir la quantité d'un article spécifique
  int getItemQuantity(String id) {
    return items[id]?.quantity ?? 0;
  }

  // Méthode pour normaliser les restaurantId
  String _normalizeRestaurantId(String restaurantId) {
    // Supprimer les espaces, convertir en minuscules et normaliser les formats
    String normalized = restaurantId.trim().toLowerCase();

    // Si c'est un nombre, le convertir en string pour la cohérence
    if (int.tryParse(normalized) != null) {
      normalized = int.parse(normalized).toString();
    }

    return normalized;
  }

  // Méthode pour mapper les restaurantId entre les différentes sources
  String _mapRestaurantId(String restaurantId) {
    // Mapping entre les différents formats de restaurantId
    // Ce mapping associe les restaurantId des plats populaires aux id des restaurants
    final restaurantIdMapping = {
      // Mapping des restaurantId des plats populaires vers les id des restaurants
      '1': '1',
      '2': '2',
      '3': '3',
      '4': '4',
      '5': '5',
      // Ajouter d'autres mappings selon vos données réelles
    };

    return restaurantIdMapping[restaurantId] ?? restaurantId;
  }
}

// Notifier pour gérer l'état de la commande
class ModernOrderNotifier extends StateNotifier<ModernOrderState> {
  ModernOrderNotifier() : super(ModernOrderState(items: {}));

  String generateItemKey(
      String dishId, List<BeverageSelection> accompaniments) {
    if (accompaniments.isEmpty) return dishId;
    final accompKey = accompaniments
        .map((a) => '${a.beverage.id}_${a.selectedSize}_${a.quantity}')
        .join('-');
    return '$dishId-$accompKey';
  }

  void addOrUpdateConfig({
    required String key,
    required String id,
    required String name,
    required String price,
    required String imageUrl,
    required String restaurantId,
    required String description,
    required List<BeverageSelection> accompaniments,
    required int quantity,
  }) {
    final currentItems = Map<String, OrderItemState>.from(state.items);
    if (quantity > 0) {
      currentItems[key] = OrderItemState(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        restaurantId: restaurantId,
        description: description,
        quantity: quantity,
        accompaniments: accompaniments,
      );
    } else {
      currentItems.remove(key);
    }
    state = state.copyWith(items: currentItems);
  }

  void updateAccompaniments({
    required String id,
    required List<BeverageSelection> accompaniments,
  }) {
    final currentItems = Map<String, OrderItemState>.from(state.items);
    if (currentItems.containsKey(id)) {
      final existing = currentItems[id]!;
      currentItems[id] = existing.copyWith(accompaniments: accompaniments);
      state = state.copyWith(items: currentItems);
    }
  }

  void addItem({
    required String id,
    required String name,
    required String price,
    required String imageUrl,
    required String restaurantId,
    required String description,
    List<BeverageSelection> accompaniments = const [],
  }) {
    final normalizedRestaurantId = _normalizeRestaurantId(restaurantId);
    final mappedRestaurantId = _mapRestaurantId(normalizedRestaurantId);
    final currentItems = Map<String, OrderItemState>.from(state.items);

    if (currentItems.containsKey(id)) {
      final existingItem = currentItems[id]!;
      currentItems[id] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      currentItems[id] = OrderItemState(
        id: id,
        name: name,
        price: price,
        imageUrl: imageUrl,
        restaurantId: mappedRestaurantId,
        description: description,
        quantity: 1,
        accompaniments: accompaniments,
      );
    }
    state = state.copyWith(items: currentItems);
  }

  // Méthode pour normaliser les restaurantId (utilise la même logique que ModernOrderState)
  String _normalizeRestaurantId(String restaurantId) {
    // Supprimer les espaces, convertir en minuscules et normaliser les formats
    String normalized = restaurantId.trim().toLowerCase();

    // Si c'est un nombre, le convertir en string pour la cohérence
    if (int.tryParse(normalized) != null) {
      normalized = int.parse(normalized).toString();
    }

    return normalized;
  }

  // Méthode pour mapper les restaurantId entre les différentes sources
  String _mapRestaurantId(String restaurantId) {
    // Mapping entre les différents formats de restaurantId
    // Ce mapping associe les restaurantId des plats populaires aux id des restaurants
    final restaurantIdMapping = {
      // Mapping des restaurantId des plats populaires vers les id des restaurants
      '1': '1',
      '2': '2',
      '3': '3',
      '4': '4',
      '5': '5',
      // Ajouter d'autres mappings selon vos données réelles
    };

    return restaurantIdMapping[restaurantId] ?? restaurantId;
  }

  // Retirer un article de la commande
  void removeItem(String id) {
    final currentItems = Map<String, OrderItemState>.from(state.items);
    if (currentItems.containsKey(id)) {
      final existingItem = currentItems[id]!;
      if (existingItem.quantity > 1) {
        currentItems[id] =
            existingItem.copyWith(quantity: existingItem.quantity - 1);
      } else {
        currentItems.remove(id);
      }
      state = state.copyWith(items: currentItems);
    }
  }

  // Supprimer complètement un article
  void removeItemCompletely(String id) {
    final currentItems = Map<String, OrderItemState>.from(state.items);
    currentItems.remove(id);
    state = state.copyWith(items: currentItems);
  }

  // Obtenir la quantité d'un article
  int getItemQuantity(String id) {
    return state.items[id]?.quantity ?? 0;
  }

  // Vider la commande
  void clearOrder() {
    state = ModernOrderState(items: {});
  }

  // Passer la commande
  Future<void> placeOrder() async {
    if (state.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implémenter la logique de passage de commande
      // 1. Créer la commande dans Firebase
      // 2. Calculer les frais de livraison
      // 3. Envoyer la notification

      // Simuler un délai
      await Future.delayed(const Duration(seconds: 2));

      // Vider la commande après succès
      state = ModernOrderState(items: {});
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void removeAllVariants(String id) {
    final currentItems = Map<String, OrderItemState>.from(state.items);
    currentItems.removeWhere((key, item) => item.id == id);
    state = state.copyWith(items: currentItems);
  }

  void removeItemByKey(String key) {
    final currentItems = Map<String, OrderItemState>.from(state.items);
    if (currentItems.containsKey(key)) {
      final existingItem = currentItems[key]!;
      if (existingItem.quantity > 1) {
        currentItems[key] =
            existingItem.copyWith(quantity: existingItem.quantity - 1);
      } else {
        currentItems.remove(key);
      }
      state = state.copyWith(items: currentItems);
    }
  }
}

// Provider global pour la commande moderne
final modernOrderProvider =
    StateNotifierProvider<ModernOrderNotifier, ModernOrderState>((ref) {
  return ModernOrderNotifier();
});

// Provider pour obtenir la quantité d'un article spécifique
final itemQuantityProvider = Provider.family<int, String>((ref, itemId) {
  final orderState = ref.watch(modernOrderProvider);
  return orderState.getItemQuantity(itemId);
});

// Provider pour vérifier si la commande est vide
final isOrderEmptyProvider = Provider<bool>((ref) {
  final orderState = ref.watch(modernOrderProvider);
  return orderState.isEmpty;
});

// Provider pour le prix total
final orderTotalPriceProvider = Provider<double>((ref) {
  final orderState = ref.watch(modernOrderProvider);
  return orderState.totalPrice;
});

// Provider pour le nombre total d'articles
final orderTotalItemsProvider = Provider<int>((ref) {
  final orderState = ref.watch(modernOrderProvider);
  return orderState.totalItems;
});

// Provider pour mapper les restaurantId aux noms de restaurants
final restaurantNameProvider =
    Provider.family<String?, String>((ref, restaurantId) {
  // Mapping des restaurantId vers les noms de restaurants
  // Ce mapping peut être étendu avec une vraie base de données
  final restaurantNames = {
    '1': 'Restaurant Le Gourmet',
    '2': 'Pizza Palace',
    '3': 'Sushi Bar',
    '4': 'Burger House',
    '5': 'Café Central',
    // Ajouter d'autres mappings selon vos besoins
  };

  final normalizedId = _normalizeRestaurantId(restaurantId);
  return restaurantNames[normalizedId] ?? restaurantId;
});

// Provider pour mapper les restaurantId entre les différentes sources
final restaurantIdMapperProvider =
    Provider.family<String, String>((ref, restaurantId) {
  // Mapping entre les différents formats de restaurantId
  // Ce mapping associe les restaurantId des plats populaires aux id des restaurants
  final restaurantIdMapping = {
    // Mapping des restaurantId des plats populaires vers les id des restaurants
    '1': '1',
    '2': '2',
    '3': '3',
    '4': '4',
    '5': '5',
    // Ajouter d'autres mappings selon vos données réelles
  };

  final normalizedId = _normalizeRestaurantId(restaurantId);
  return restaurantIdMapping[normalizedId] ?? restaurantId;
});

// Provider pour obtenir le nom du restaurant à partir de l'ID
final restaurantNameFromIdProvider =
    Provider.family<String, String>((ref, restaurantId) {
  final normalizedId = _normalizeRestaurantId(restaurantId);
  final mappedId = _mapRestaurantId(normalizedId);

  // Mapping des noms de restaurants
  final restaurantNames = {
    '1': 'Restaurant Le Gourmet',
    '2': 'Pizza Palace',
    '3': 'Sushi Bar',
    '4': 'Burger House',
    '5': 'Café Central',
  };

  return restaurantNames[mappedId] ?? 'Restaurant $mappedId';
});

// Fonction utilitaire pour normaliser les restaurantId
String _normalizeRestaurantId(String restaurantId) {
  // Supprimer les espaces, convertir en minuscules et normaliser les formats
  String normalized = restaurantId.trim().toLowerCase();

  // Si c'est un nombre, le convertir en string pour la cohérence
  if (int.tryParse(normalized) != null) {
    normalized = int.parse(normalized).toString();
  }

  return normalized;
}

// Fonction utilitaire pour mapper les restaurantId
String _mapRestaurantId(String restaurantId) {
  // Mapping entre les différents formats de restaurantId
  final restaurantIdMapping = {
    '1': '1',
    '2': '2',
    '3': '3',
    '4': '4',
    '5': '5',
  };

  return restaurantIdMapping[restaurantId] ?? restaurantId;
}
