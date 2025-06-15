import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../card/data/models/cart_item_model.dart';
import '../../domain/entities/delivery_info.dart';
import '../models/delivery_info_model.dart';

abstract class CheckoutRemoteDataSource {
  Future<DeliveryInfo> getDeliveryInfo(String userId);
  Future<void> saveDeliveryInfo(String userId, DeliveryInfo deliveryInfo);
  Future<void> createOrder(
      String userId, List<CartItemModel> cartItems, DeliveryInfo deliveryInfo);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<DeliveryInfo> getDeliveryInfo(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('delivery_info')
        .doc('current')
        .get();

    if (!doc.exists) {
      throw Exception('No delivery info found');
    }

    return DeliveryInfoModel.fromFirestore(doc.data()!);
  }

  @override
  Future<void> saveDeliveryInfo(
      String userId, DeliveryInfo deliveryInfo) async {
    if (deliveryInfo is! DeliveryInfoModel) {
      throw Exception('DeliveryInfo must be a DeliveryInfoModel');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('delivery_info')
        .doc('current')
        .set((deliveryInfo as DeliveryInfoModel).toFirestore());
  }

  @override
  Future<void> createOrder(
    String userId,
    List<CartItemModel> cartItems,
    DeliveryInfo deliveryInfo,
  ) async {
    if (deliveryInfo is! DeliveryInfoModel) {
      throw Exception('DeliveryInfo must be a DeliveryInfoModel');
    }

    final orderRef = _firestore.collection('orders').doc();
    final batch = _firestore.batch();

    // Create order
    batch.set(orderRef, {
      'userId': userId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'items': cartItems.map((item) => item.toFirestore()).toList(),
      'deliveryInfo': (deliveryInfo as DeliveryInfoModel).toFirestore(),
      'total': cartItems.fold(
          0.0,
          (sum, item) =>
              sum + (double.tryParse(item.price) ?? 0) * item.quantity),
    });

    // Execute batch
    await batch.commit();
  }
}
