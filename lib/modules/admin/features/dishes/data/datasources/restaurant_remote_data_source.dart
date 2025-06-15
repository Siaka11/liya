import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant_model.dart';

class RestaurantRemoteDataSource {
  static const String baseUrl =
      'http://api-restaurant.toptelsig.com/restaurants';

  Future<List<RestaurantModel>> getAllRestaurants() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RestaurantModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des restaurants');
    }
  }
}
