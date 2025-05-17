import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dish_model.dart';

abstract class DishRemoteDataSource {
  Future<List<DishModel>> getDishesByRestaurant(String restaurantId);
}

class DishRemoteDataSourceImpl implements DishRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  DishRemoteDataSourceImpl({required this.client, this.baseUrl = 'http://api-restaurant.toptelsig.com'});

  @override
  Future<List<DishModel>> getDishesByRestaurant(String restaurantId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/dishes/restaurantid/$restaurantId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => DishModel.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des plats : Code d\'état ${response.statusCode}');
    }
  }
}