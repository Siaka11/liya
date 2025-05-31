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
    final snapshot = await _firestore
        .collection('liked_dishes')
        .where('userId', isEqualTo: userId)
        .orderBy('likedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => LikedDish.fromJson(doc.data())).toList();
  }

  @override
  Future<void> likeDish(LikedDish dish) async {
    final docId = '${dish.userId}_${dish.id}';
    await _firestore.collection('liked_dishes').doc(docId).set(dish.toJson());
  }

  @override
  Future<void> unlikeDish(String dishId, String userId) async {
    final docId = '${userId}_$dishId';
    await _firestore.collection('liked_dishes').doc(docId).delete();
  }

  @override
  Future<bool> isDishLiked(String dishId, String userId) async {
    final docId = '${userId}_$dishId';
    final doc = await _firestore.collection('liked_dishes').doc(docId).get();
    return doc.exists;
  }
}
