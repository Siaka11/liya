import 'package:dartz/dartz.dart';
import 'package:liya/modules/restaurant/features/card/domain/repositories/cart_repository.dart';

import '../../../../core/failure.dart';
import '../entities/cart_item.dart';

class AddToCart {
  final CartRepository cartRepository;

  AddToCart(this.cartRepository);

  Future<Either<Failure, void>> call(String userId, CartItem cartItem) async {
    return await cartRepository.addToCart(userId, cartItem);
  }
}