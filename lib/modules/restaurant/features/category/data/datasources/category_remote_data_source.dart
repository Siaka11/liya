import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dish_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<DishModel>> getDishesByCategory(String categoryName);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final String baseUrl;
  CategoryRemoteDataSourceImpl({required this.baseUrl});

  @override
  Future<List<DishModel>> getDishesByCategory(String categoryName) async {
    final response =
        await http.get(Uri.parse('$baseUrl/dishes/category/$categoryName'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => DishModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load dishes');
    }
  }
}
