import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/dish_repository_impl.dart';
import '../domain/entities/dish.dart';
import 'package:http/http.dart' as http;
import '../data/datasources/dish_remote_data_source.dart';

final allDishesProvider = FutureProvider<List<Dish>>((ref) async {
  final repo = DishRepositoryImpl(
    remoteDataSource: DishRemoteDataSourceImpl(client: http.Client()),
  );
  return await repo.getAllDishesFromMySQL();
});
