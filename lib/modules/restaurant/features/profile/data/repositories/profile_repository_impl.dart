import 'package:dartz/dartz.dart' as dartz;
import 'package:liya/core/failure.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<dartz.Either<Failure, UserProfile>> getUserProfile(
      String userId) async {
    try {
      final profile = await remoteDataSource.getUserProfile(userId);
      return dartz.Right(profile);
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> updateUserProfile(
      UserProfile profile) async {
    try {
      await remoteDataSource.updateUserProfile(profile);
      return const dartz.Right(null);
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Order>>> getUserOrders(
      String userId) async {
    try {
      final orders = await remoteDataSource.getUserOrders(userId);
      return dartz.Right(orders);
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> addAddress(
      String userId, String address) async {
    try {
      await remoteDataSource.addAddress(userId, address);
      return const dartz.Right(null);
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> addPaymentMethod(
      String userId, String paymentMethod) async {
    try {
      await remoteDataSource.addPaymentMethod(userId, paymentMethod);
      return const dartz.Right(null);
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> updatePhoneNumber(
      String userId, String phoneNumber) async {
    try {
      await remoteDataSource.updatePhoneNumber(userId, phoneNumber);
      return const dartz.Right(null);
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }
}
