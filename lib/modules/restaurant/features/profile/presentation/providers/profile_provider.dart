import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ProfileRemoteDataSourceImpl(),
  );
});

final profileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getUserProfile(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
});

final userOrdersProvider =
    FutureProvider.family<List<Order>, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getUserOrders(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (orders) => orders,
  );
});

final userAddressesProvider =
    FutureProvider.family<List<String>, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getUserProfile(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile.addresses,
  );
});

final userPaymentMethodsProvider =
    FutureProvider.family<List<String>, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getUserProfile(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile.paymentMethods,
  );
});
