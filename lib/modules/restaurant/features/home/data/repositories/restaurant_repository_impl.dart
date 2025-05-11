import 'package:liya/modules/restaurant/features/home/data/datasources/restaurant_remote_datasource.dart';

import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  late final RestaurantRemoteDatasource datasource;

  RestaurantRepositoryImpl(this.datasource);

  @override
  Future<List<Restaurant>> getRestaurants() {
    return  datasource.getRestaurants();
  }


}