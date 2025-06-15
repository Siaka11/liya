import '../../domain/repositories/category_repository.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/category.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  CategoryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Dish>> getDishesByCategory(String categoryName) async {
    return await remoteDataSource.getDishesByCategory(categoryName);
  }

  @override
  Future<List<Category>> getCategories() async {
    // Not implemented, return empty list or throw if not used
    return [];
    // Or: throw UnimplementedError();
  }
}
