import 'package:dartz/dartz.dart';
import 'package:liya/modules/restaurant/features/card/domain/entities/cart_item.dart';
import '../../../../core/failure.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addToCart(
      String userId, CartItem cartItem) async {
    try {
      final cartItemModel = CartItemModel(
        id: cartItem.id,
        name: cartItem.name,
        price: cartItem.price,
        imageUrl: cartItem.imageUrl,
        restaurantId: cartItem.restaurantId,
        description: cartItem.description,
        rating: cartItem.rating,
        quantity: cartItem.quantity,
        user: cartItem.user,
      );
      await remoteDataSource.addToCart(userId, cartItemModel);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems(String userId) async {
    try {
      final cartItems = await remoteDataSource.getCartItems(userId);
      return Right(cartItems);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(
      String userId, String itemName) async {
    try {
      await remoteDataSource.removeFromCart(userId, itemName);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    await remoteDataSource.clearCart(userId);
  }
}
