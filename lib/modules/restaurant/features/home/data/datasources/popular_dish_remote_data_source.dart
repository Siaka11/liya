import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/entities/popular_dish.dart';

abstract class PopularDishRemoteDataSource {
  Future<List<PopularDish>> getPopularDishes();
}

class PopularDishRemoteDataSourceImpl implements PopularDishRemoteDataSource {
  final http.Client client;

  PopularDishRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PopularDish>> getPopularDishes() async {
    // Simulation d'une API (remplacez par votre endpoint réel)
    final response = await client.get(Uri.parse('http://api-restaurant.toptelsig.com/populardish'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PopularDish.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load popular dishes: ${response.statusCode}');
    }
  }
}