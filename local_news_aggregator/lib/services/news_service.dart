import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_key.dart';

class NewsService {
  static const _baseUrl = 'https://newsapi.org/v2';
  static const _apiKey = apiKey;

  Future<List<Map<String, dynamic>>> fetchLocalNews(
    String countryCode, {
    String? city,
    String? state,
    String? country,
    bool localSourcesOnly = false,
  }) async {
    try {
      String url;

      if (city != null && city.isNotEmpty) {
        String locationQuery = _buildLocationQuery(city, state, country);

        url =
            '$_baseUrl/everything?'
            'q=$locationQuery&'
            'searchIn=title,description,content&'
            'language=en&'
            'sortBy=publishedAt&'
            'pageSize=100&'
            'apiKey=$_apiKey';
      } else if (state != null && state.isNotEmpty) {
        String stateQuery = Uri.encodeComponent('"$state"');
        if (country != null && country.isNotEmpty) {
          stateQuery = '$stateQuery+AND+${Uri.encodeComponent('"$country"')}';
        }

        url =
            '$_baseUrl/everything?'
            'q=$stateQuery&'
            'searchIn=title,description,content&'
            'language=en&'
            'sortBy=publishedAt&'
            'pageSize=100&'
            'apiKey=$_apiKey';
      } else {
        url = '$_baseUrl/top-headlines?country=$countryCode&apiKey=$_apiKey';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> articles = List<Map<String, dynamic>>.from(
          data['articles'] ?? [],
        );

        if (city != null && city.isNotEmpty) {
          articles = _filterByLocationRelevance(
            articles,
            city,
            state,
            country,
            localSourcesOnly: localSourcesOnly,
          );
        } else if (localSourcesOnly && state != null && state.isNotEmpty) {
          articles = articles.where((article) {
            String source = (article['source']?['name'] ?? '')
                .toString()
                .toLowerCase();
            return _isLocalNewsSource(source, state.toLowerCase());
          }).toList();
        }

        return articles;
      } else {
        throw Exception('Failed to load local news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching local news: $e');
    }
  }

  String _buildLocationQuery(String city, String? state, String? country) {
    String query = Uri.encodeComponent('"$city"');

    if (state != null && state.isNotEmpty) {
      query = '$query+AND+${Uri.encodeComponent('"$state"')}';
    }

    if (country != null && country.isNotEmpty) {
      query = '$query+AND+${Uri.encodeComponent('"$country"')}';
    }

    query = '$query+AND+(${Uri.encodeComponent('local OR news OR city')}';
    query = '$query+OR+${Uri.encodeComponent('municipal OR metro OR region')})';

    return query;
  }

  List<Map<String, dynamic>> _filterByLocationRelevance(
    List<Map<String, dynamic>> articles,
    String city,
    String? state,
    String? country, {
    bool localSourcesOnly = false,
  }) {
    return articles.where((article) {
      String title = (article['title'] ?? '').toString().toLowerCase();
      String description = (article['description'] ?? '')
          .toString()
          .toLowerCase();
      String content = (article['content'] ?? '').toString().toLowerCase();
      String source = (article['source']?['name'] ?? '')
          .toString()
          .toLowerCase();

      if (localSourcesOnly) {
        bool isLocalSource = _isLocalNewsSource(source, city.toLowerCase());
        if (!isLocalSource) {
          return false;
        }
      }

      String allText = '$title $description $content $source';
      String cityLower = city.toLowerCase();

      bool hasCityInTitle = title.contains(cityLower);
      bool hasCityInDescription = description.contains(cityLower);
      bool hasCityInContent = content.contains(cityLower);

      if (hasCityInTitle || hasCityInDescription) {
        return true;
      }

      if (state != null && state.isNotEmpty) {
        String stateLower = state.toLowerCase();
        bool hasState = allText.contains(stateLower);
        if (hasCityInContent && hasState) {
          return true;
        }
      }

      bool isLocalSource = _isLocalNewsSource(source, cityLower);
      if (isLocalSource && hasCityInContent) {
        return true;
      }

      return false;
    }).toList();
  }

  bool _isLocalNewsSource(String source, String city) {
    List<String> localIndicators = [
      'local',
      'times',
      'post',
      'tribune',
      'herald',
      'gazette',
      'chronicle',
      'journal',
      'news',
      'daily',
      city,
    ];

    for (String indicator in localIndicators) {
      if (source.contains(indicator)) {
        return true;
      }
    }

    return false;
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
