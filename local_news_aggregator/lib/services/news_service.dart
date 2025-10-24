import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_key.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = apiKey;

  /// Fetch local news with optional location filters
  /// [countryCode] - ISO 3166-1 alpha-2 country code (e.g., 'us', 'gb', 'in')
  /// [city] - City name for filtering (optional)
  /// [state] - State/Province name for filtering (optional)
  /// [country] - Full country name for better filtering (optional)
  /// [localSourcesOnly] - Filter to show only local news sources (optional)
  Future<List<Map<String, dynamic>>> fetchLocalNews(
    String countryCode, {
    String? city,
    String? state,
    String? country,
    bool localSourcesOnly = false,
  }) async {
    try {
      // Build highly specific location-based query
      String url;

      if (city != null && city.isNotEmpty) {
        // When city is specified, create a very specific query
        // This ensures we get news ABOUT that city, not just mentioning it
        String locationQuery = _buildLocationQuery(city, state, country);

        // Use everything endpoint with specific search terms
        // Using quotes for exact phrase matching and AND operators for specificity
        url =
            '$_baseUrl/everything?'
            'q=$locationQuery&'
            'searchIn=title,description,content&' // Search in all text fields
            'language=en&'
            'sortBy=publishedAt&'
            'pageSize=100&' // Get more results for better filtering
            'apiKey=$_apiKey';
      } else if (state != null && state.isNotEmpty) {
        // State-level filtering
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
        // Country-level top headlines (default behavior)
        url = '$_baseUrl/top-headlines?country=$countryCode&apiKey=$_apiKey';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> articles = List<Map<String, dynamic>>.from(
          data['articles'] ?? [],
        );

        // Additional client-side filtering for better location specificity
        if (city != null && city.isNotEmpty) {
          articles = _filterByLocationRelevance(
            articles,
            city,
            state,
            country,
            localSourcesOnly: localSourcesOnly,
          );
        } else if (localSourcesOnly && state != null && state.isNotEmpty) {
          // Filter by local sources even if only state is provided
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

  /// Build a highly specific location query for better results
  String _buildLocationQuery(String city, String? state, String? country) {
    // Use exact phrase matching with quotes and combine with AND operators
    String query = Uri.encodeComponent('"$city"');

    // Add state/province for disambiguation (e.g., Mumbai, Maharashtra)
    if (state != null && state.isNotEmpty) {
      query = '$query+AND+${Uri.encodeComponent('"$state"')}';
    }

    // Add country for international disambiguation (e.g., Paris, France vs Paris, Texas)
    if (country != null && country.isNotEmpty) {
      query = '$query+AND+${Uri.encodeComponent('"$country"')}';
    }

    // Add common local news terms to boost relevance
    query = '$query+AND+(${Uri.encodeComponent('local OR news OR city')}';
    query = '$query+OR+${Uri.encodeComponent('municipal OR metro OR region')})';

    return query;
  }

  /// Filter articles by location relevance on the client side
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

      // If local sources only filter is enabled
      if (localSourcesOnly) {
        bool isLocalSource = _isLocalNewsSource(source, city.toLowerCase());
        if (!isLocalSource) {
          return false; // Skip non-local sources
        }
      }

      // Combine all text for searching
      String allText = '$title $description $content $source';

      String cityLower = city.toLowerCase();

      // Article must mention the city prominently
      bool hasCityInTitle = title.contains(cityLower);
      bool hasCityInDescription = description.contains(cityLower);
      bool hasCityInContent = content.contains(cityLower);

      // Give higher priority to articles with city in title or description
      if (hasCityInTitle || hasCityInDescription) {
        return true;
      }

      // If state is provided, check if both city and state are mentioned
      if (state != null && state.isNotEmpty) {
        String stateLower = state.toLowerCase();
        bool hasState = allText.contains(stateLower);
        if (hasCityInContent && hasState) {
          return true;
        }
      }

      // Check if it's from a local news source
      bool isLocalSource = _isLocalNewsSource(source, cityLower);
      if (isLocalSource && hasCityInContent) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Check if the source is a local news outlet
  bool _isLocalNewsSource(String source, String city) {
    // Common patterns for local news sources
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
