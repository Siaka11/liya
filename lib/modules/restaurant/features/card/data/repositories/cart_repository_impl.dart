import 'package:dartz/dartz.dart';

import 'package:liya/modules/restaurant/core/failure.dart';

import 'package:liya/modules/restaurant/features/card/domain/entities/cart_item.dart';

import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository{
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addTocart(CartItem cartItem) async{
    try {
      final cartItemModel = CartItemModel(
        id: cartItem.id,
        name: cartItem.name,
        restaurantId: cartItem.restaurantId,
        price: cartItem.price,
        quantity: cartItem.quantity,
        imageUrl: cartItem.imageUrl,
        description: cartItem.description,
        rating: cartItem.rating,
        user: cartItem.user,
      );
      await remoteDataSource.addToCart(cartItemModel);
      return Right(null);
    } catch (e) {
    return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems(String restaurantId) async{
    try {
      final cartItems = await remoteDataSource.getCartItems(restaurantId);
      return Right(cartItems);
    } catch (e) {
      return Left(ServerFailure());
    }
  }


}