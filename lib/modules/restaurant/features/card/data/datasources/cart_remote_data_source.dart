import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<void> addToCart(String userId, CartItemModel cartItem);
  Future<List<CartItemModel>> getCartItems(String userId);
  Future<void> removeFromCart(String userId, String itemName);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addToCart(String userId, CartItemModel cartItem) async {
    print(
        'DEBUG: Mise à jour du panier - userId: $userId, plat: ${cartItem.name}, nouvelle quantité: ${cartItem.quantity}');
    final cartRef = _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(cartItem.id);

    final snapshot = await cartRef.get();
    if (snapshot.exists) {
      final currentQuantity = snapshot.data()?['quantity'] ?? 0;
      print(
          'DEBUG: Mise à jour - Ancienne quantité: $currentQuantity, Nouvelle quantité: ${cartItem.quantity}');
      await cartRef.update({'quantity': cartItem.quantity});
    } else {
      print(
          'DEBUG: Création nouvelle entrée avec quantité: ${cartItem.quantity}');
      await cartRef.set(cartItem.toFirestore());
    }
  }

  @override
  Future<List<CartItemModel>> getCartItems(String userId) async {
    print('DEBUG: Fetching cart items for userId: $userId');
    final querySnapshot = await _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .get();
    print('DEBUG: Found ${querySnapshot.docs.length} cart items');

    final items = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      print(
          'DEBUG: Cart item from Firestore - ID: ${doc.id}, Quantity: ${data['quantity']}');
      return CartItemModel.fromFirestore(data, doc.id);
    }).toList();
    return items;
  }

  @override
  Future<void> removeFromCart(String userId, String itemName) async {
    print('DEBUG: Suppression de l\'article $itemName du panier de $userId');
    final cartRef = _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(itemName);

    await cartRef.delete();
    print('DEBUG: Article supprimé avec succès');
  }
}
