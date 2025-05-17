import 'package:dartz/dartz.dart';
import 'package:liya/modules/restaurant/features/card/domain/entities/cart_item.dart';
import '../../../../core/failure.dart';

abstract class CartRepository {
  Future<Either<Failure, void>> addTocart(CartItem cartItem);
  Future<Either<Failure, List<CartItem>>> getCartItems(String restaurandId);

}