

import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantsUseCase {
  late final RestaurantRepository restaurantRepository;

  GetRestaurantsUseCase(this.restaurantRepository);

  Future<List<Restaurant>> execute() async {
    return await restaurantRepository.getRestaurants();
  }

}