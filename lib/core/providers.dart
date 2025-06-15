import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liya/modules/restaurant/features/like/data/datasources/like_remote_data_source.dart';
import 'package:liya/modules/restaurant/features/like/data/repositories/like_repository_impl.dart';
import 'package:liya/modules/restaurant/features/like/domain/repositories/like_repository.dart';
import 'package:liya/modules/restaurant/features/like/domain/usecases/like_dish.dart';
import 'package:liya/core/storage/local_storage_factory.dart';
import 'dart:convert';

final likeRepositoryProvider = Provider<LikeRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final remoteDataSource = LikeRemoteDataSourceImpl(firestore);
  return LikeRepositoryImpl(remoteDataSource);
});

final likeDishProvider = Provider<LikeDish>((ref) {
  return LikeDish(ref.watch(likeRepositoryProvider));
});

final localStorageFactoryProvider = Provider<LocalStorageFactory>((ref) {
  return LocalStorageFactory();
});

final userIdProvider = FutureProvider<String>((ref) async {
  final localStorage = ref.watch(localStorageFactoryProvider);
  final userDetails = await localStorage.getUserDetails();
  return userDetails['phoneNumber'] ?? '';
});
