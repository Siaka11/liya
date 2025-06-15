import 'package:dartz/dartz.dart' as dartz;
import 'package:liya/core/failure.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<dartz.Either<Failure, UserProfile>> getUserProfile(String userId);
  Future<dartz.Either<Failure, void>> updateUserProfile(UserProfile profile);
  Future<dartz.Either<Failure, List<Order>>> getUserOrders(String userId);
  Future<dartz.Either<Failure, void>> addAddress(String userId, String address);
  Future<dartz.Either<Failure, void>> addPaymentMethod(
      String userId, String paymentMethod);
  Future<dartz.Either<Failure, void>> updatePhoneNumber(
      String userId, String phoneNumber);
}
