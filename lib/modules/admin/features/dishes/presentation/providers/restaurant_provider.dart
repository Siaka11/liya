import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/restaurant_remote_data_source.dart';
import '../../data/models/restaurant_model.dart';

final restaurantListProvider =
    FutureProvider<List<RestaurantModel>>((ref) async {
  final dataSource = RestaurantRemoteDataSource();
  return await dataSource.getAllRestaurants();
});
