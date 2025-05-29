import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/user_profile_model.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfile profile);
  Future<List<Order>> getUserOrders(String userId);
  Future<void> addAddress(String userId, String address);
  Future<void> addPaymentMethod(String userId, String paymentMethod);
  Future<void> updatePhoneNumber(String userId, String phoneNumber);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      throw Exception('User profile not found');
    }
    return UserProfileModel.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    if (profile is! UserProfileModel) {
      throw Exception('Profile must be a UserProfileModel');
    }
    await _firestore
        .collection('users')
        .doc(profile.id)
        .set(profile.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<List<Order>> getUserOrders(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception('User not found');
    }
    final userData = userDoc.data()!;
    return (userData['orders'] as List<dynamic>? ?? [])
        .map((orderData) => Order(
              id: orderData['id'] ?? '',
              restaurantName: orderData['restaurantName'] ?? '',
              orderDate: (orderData['orderDate'] as Timestamp).toDate(),
              total: (orderData['total'] ?? 0).toDouble(),
              status: orderData['status'] ?? '',
              items: (orderData['items'] as List<dynamic>? ?? [])
                  .map((itemData) => OrderItem(
                        name: itemData['name'] ?? '',
                        quantity: itemData['quantity'] ?? 0,
                        price: (itemData['price'] ?? 0).toDouble(),
                      ))
                  .toList(),
            ))
        .toList();
  }

  @override
  Future<void> addAddress(String userId, String address) async {
    await _firestore.collection('users').doc(userId).update({
      'addresses': FieldValue.arrayUnion([address])
    });
  }

  @override
  Future<void> addPaymentMethod(String userId, String paymentMethod) async {
    await _firestore.collection('users').doc(userId).update({
      'paymentMethods': FieldValue.arrayUnion([paymentMethod])
    });
  }

  @override
  Future<void> updatePhoneNumber(String userId, String phoneNumber) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update({'phoneNumber': phoneNumber});
  }
}
