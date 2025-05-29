import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/search_result.dart';
import '../models/search_result_model.dart';

abstract class SearchRemoteDataSource {
  Future<List<SearchResult>> search(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final String apiUrl;
  SearchRemoteDataSourceImpl({required this.apiUrl});

  @override
  Future<List<SearchResult>> search(String query) async {
    final response = await http.get(Uri.parse('$apiUrl/search?query=$query'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => SearchResultModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la recherche');
    }
  }
}
