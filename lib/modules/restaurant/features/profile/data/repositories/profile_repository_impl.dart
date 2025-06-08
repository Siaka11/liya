import 'package:dartz/dartz.dart' as dartz;
import 'package:liya/core/failure.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSourceMySQL remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<dartz.Either<Failure, UserProfile>> getUserProfile(
      String phoneNumber) async {
    try {
      final profile = await remoteDataSource.getUserProfileByPhone(phoneNumber);
      return dartz.Right(profile);
    } catch (e) {
      return dartz.Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> updateUserProfile(
      UserProfile profile) async {
    return const dartz.Right(null);
  }

  @override
  Future<dartz.Either<Failure, List<Order>>> getUserOrders(
      String userId) async {
    return dartz.Right([]);
  }

  @override
  Future<dartz.Either<Failure, void>> addAddress(
      String userId, String address) async {
    return const dartz.Right(null);
  }

  @override
  Future<dartz.Either<Failure, void>> addPaymentMethod(
      String userId, String paymentMethod) async {
    return const dartz.Right(null);
  }

  @override
  Future<dartz.Either<Failure, void>> updatePhoneNumber(
      String userId, String phoneNumber) async {
    return const dartz.Right(null);
  }
}
