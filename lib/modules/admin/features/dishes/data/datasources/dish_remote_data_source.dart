import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dish_model.dart';

abstract class DishRemoteDataSource {
  Future<List<DishModel>> getDishes(String restaurantId);
  Future<DishModel> getDishById(String id);
  Future<String> uploadDishImage(File imageFile, String dishId);
  Future<void> updateDishImage(String dishId, String imageUrl);
  Future<void> deleteDishImage(String imageUrl);
  Future<void> createDish(DishModel dish);
  Future<void> updateDish(DishModel dish);
  Future<void> deleteDish(String id);
}

class DishRemoteDataSourceImpl implements DishRemoteDataSource {
  final String baseUrl = 'http://api-restaurant.toptelsig.com';
  final http.Client client;

  DishRemoteDataSourceImpl(this.client);

  @override
  Future<List<DishModel>> getDishes(String restaurantId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/dishes/restaurantid/$restaurantId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DishModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch dishes: ${response.statusCode}');
    }
  }

  @override
  Future<DishModel> getDishById(String id) async {
    final response = await client.get(
      Uri.parse('$baseUrl/dish/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DishModel.fromJson(data);
    } else {
      throw Exception('Failed to fetch dish: ${response.statusCode}');
    }
  }

  @override
  Future<String> uploadDishImage(File imageFile, String dishId) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/dish/$dishId/image'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      final data = json.decode(responseData);
      return data['image_url'];
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateDishImage(String dishId, String imageUrl) async {
    final response = await client.put(
      Uri.parse('$baseUrl/dish/$dishId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'image_url': imageUrl}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update dish image: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteDishImage(String imageUrl) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/image'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'image_url': imageUrl}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete image: ${response.statusCode}');
    }
  }

  @override
  Future<void> createDish(DishModel dish) async {
    final response = await client.post(
      Uri.parse('$baseUrl/dish'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dish.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create dish: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateDish(DishModel dish) async {
    final response = await client.put(
      Uri.parse('$baseUrl/dish/${dish.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dish.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update dish: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteDish(String id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/dish/$id'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete dish: ${response.statusCode}');
    }
  }
}
