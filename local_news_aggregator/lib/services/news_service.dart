import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_key.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = apiKey;

  Future<List<Map<String, dynamic>>> fetchLocalNews(String countryCode) async {
    try {
      final url = '$_baseUrl/top-headlines?country=$countryCode&apiKey=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['articles'] ?? []);
      } else {
        throw Exception('Failed to load local news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching local news: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchGlobalNews() async {
    try {
      final url = '$_baseUrl/top-headlines?category=general&apiKey=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['articles'] ?? []);
      } else {
        throw Exception('Failed to load global news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching global news: $e');
    }
  }
}
