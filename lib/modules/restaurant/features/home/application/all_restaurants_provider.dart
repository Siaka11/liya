import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/restaurant_repository_impl.dart';
import '../domain/entities/restaurant.dart';
import 'package:http/http.dart' as http;
import '../data/datasources/restaurant_remote_datasource.dart';

final allRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repo = RestaurantRepositoryImpl(
    RestaurantRemoteDatasource(http.Client()),
  );
  return await repo.getAllRestaurantsFromMySQL();
});
