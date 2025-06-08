import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantModel>> getRestaurants(
      {int limit = 10, DocumentSnapshot? lastDocument});
  Future<RestaurantModel> getRestaurantById(String id);
  Future<List<RestaurantModel>> searchRestaurants(String query);
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<RestaurantModel>> getRestaurants(
      {int limit = 10, DocumentSnapshot? lastDocument}) async {
    try {
      Query query =
          _firestore.collection('restaurants').orderBy('name').limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return RestaurantModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch restaurants: $e');
    }
  }

  @override
  Future<RestaurantModel> getRestaurantById(String id) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(id).get();
      if (!doc.exists) {
        throw Exception('Restaurant not found');
      }
      return RestaurantModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch restaurant: $e');
    }
  }

  @override
  Future<List<RestaurantModel>> searchRestaurants(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('restaurants')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => RestaurantModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }
}
