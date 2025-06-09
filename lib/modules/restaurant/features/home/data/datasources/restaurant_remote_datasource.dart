import 'package:http/http.dart' as http;

import '../../domain/entities/restaurant.dart';
import 'dart:convert';

import '../models/dish_model.dart';


class RestaurantRemoteDatasource {
  final http.Client client;

  RestaurantRemoteDatasource(this.client);

  Future<List<Restaurant>> getRestaurants() async {
    const String baseUrl = 'http://api-restaurant.toptelsig.com/restaurants';
    final response = await client.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Échec de la récupération des restaurants');
    }
  }

}