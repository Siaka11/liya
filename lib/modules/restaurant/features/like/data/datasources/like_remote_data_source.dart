import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/liked_dish.dart';

abstract class LikeRemoteDataSource {
  Future<List<LikedDish>> getLikedDishes(String userId);
  Future<void> likeDish(LikedDish dish);
  Future<void> unlikeDish(String dishId, String userId);
  Future<bool> isDishLiked(String dishId, String userId);
}

class LikeRemoteDataSourceImpl implements LikeRemoteDataSource {
  final FirebaseFirestore _firestore;

  LikeRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<LikedDish>> getLikedDishes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('liked_dishes')
          .where('userId', isEqualTo: userId)
          .orderBy('likedAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LikedDish.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting liked dishes: $e');
      return [];
    }
  }

  @override
  Future<void> likeDish(LikedDish dish) async {
    try {
      final docId = '${dish.userId}_${dish.id}';
      await _firestore.collection('liked_dishes').doc(docId).set(dish.toJson());
    } catch (e) {
      print('Error liking dish: $e');
      rethrow;
    }
  }

  @override
  Future<void> unlikeDish(String dishId, String userId) async {
    try {
      final docId = '${userId}_$dishId';
      await _firestore.collection('liked_dishes').doc(docId).delete();
    } catch (e) {
      print('Error unliking dish: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isDishLiked(String dishId, String userId) async {
    try {
      final docId = '${userId}_$dishId';
      final doc = await _firestore.collection('liked_dishes').doc(docId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if dish is liked: $e');
      return false;
    }
  }
}
