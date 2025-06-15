import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ProfileRemoteDataSourceMySQL(http.Client()),
  );
});

final profileProvider =
    FutureProvider.family<UserProfile, String>((ref, phoneNumber) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getUserProfile(phoneNumber);
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
    (profile) => profile.address,
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
