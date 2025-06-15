import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/category_remote_data_source.dart';
import '../data/repositories/category_repository_impl.dart';
import '../domain/entities/dish.dart';

final categoryRepositoryProvider = Provider((ref) {
  return CategoryRepositoryImpl(CategoryRemoteDataSourceImpl(
      baseUrl: 'http://api-restaurant.toptelsig.com'));
});

final dishesByCategoryProvider =
    FutureProvider.family<List<Dish>, String>((ref, categoryName) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getDishesByCategory(categoryName);
});
