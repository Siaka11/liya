import 'package:dartz/dartz.dart';
import '../../../../../../core/failure.dart';
import '../../../card/data/datasources/cart_remote_data_source.dart';
import '../../domain/entities/delivery_info.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;
  final CartRemoteDataSource cartDataSource;

  CheckoutRepositoryImpl({
    required this.remoteDataSource,
    required this.cartDataSource,
  });

  @override
  Future<Either<Failure, DeliveryInfo>> getDeliveryInfo(String userId) async {
    try {
      final deliveryInfo = await remoteDataSource.getDeliveryInfo(userId);
      return Right(deliveryInfo);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDeliveryInfo(
      String userId, DeliveryInfo deliveryInfo) async {
    try {
      await remoteDataSource.saveDeliveryInfo(userId, deliveryInfo);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> placeOrder(String userId) async {
    try {
      // 1. Get cart items
      final cartItems = await cartDataSource.getCartItems(userId);

      // 2. Get delivery info
      final deliveryInfo = await remoteDataSource.getDeliveryInfo(userId);

      // 3. Create order
      await remoteDataSource.createOrder(userId, cartItems, deliveryInfo);

      // 4. Clear cart
      // TODO: Implement clear cart functionality

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
