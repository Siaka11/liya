



import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<void> addToCart(CartItemModel cartItem);

  Future<List<CartItemModel>> getCartItems(String restaurantId);
}
  class CartRemoteDataSourceImpl implements CartRemoteDataSource {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addToCart(CartItemModel cartItem) async {
    // TODO: implement addToCart
    DocumentReference cartRef = _firestore.collection('carts').doc(cartItem.restaurantId);
    DocumentSnapshot cartSnapshot = await cartRef.get();
    List<Map<String, dynamic>> cartItems = [];

    if (cartSnapshot.exists) {
      cartItems = List<Map<String, dynamic>>.from((cartSnapshot.data() as Map<String, dynamic>)['items'] ?? []);
      bool itemExists = false;
      for (var item in cartItems) {
        if (item['id'] == cartItem.id) {
          item['quantity'] = (item['quantity'] as int) + cartItem.quantity;
          itemExists = true;
          break;
        }
      }
      if (!itemExists) {
        cartItems.add(cartItem.toJson());
      }
    } else {
      cartItems.add(cartItem.toJson());
    }

    await cartRef.set({
      'items': cartItems,
      'user': 'user_id',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<List<CartItemModel>> getCartItems(String restaurantId) async {
    DocumentSnapshot snapshot = await _firestore.collection('carts').doc(restaurantId).get();
    if (!snapshot.exists) {
      return [];
    }
    List<dynamic> items = (snapshot.data() as Map<String, dynamic>)['items'] ?? [];
    return items.map((item) => CartItemModel.fromJson(item)).toList();
  }
}