import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../services/location_service.dart';
import '../widgets/news_card.dart';

class LocalTab extends StatefulWidget {
  const LocalTab({super.key});

  @override
  State<LocalTab> createState() => _LocalTabState();
}

class _LocalTabState extends State<LocalTab> {
  Future<List<News>>? _localNews;
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _initLocalNews();
  }

  Future<void> _initLocalNews() async {
    try {
      // Get country code for API
      final countryCode = await LocationService().getCountryCode();

      // Optionally get city for display
      final city = await LocationService().getCity();

      setState(() {
        _locationName = city;
        _localNews = _fetchLocalNews(countryCode);
      });
    } catch (e) {
      setState(() {
        _localNews = Future.error("Failed to get location: $e");
      });
    }
  }

  Future<List<News>> _fetchLocalNews(String countryCode) async {
    final articles = await NewsService().fetchLocalNews(countryCode);
    return articles.map((json) => News.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_localNews == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return FutureBuilder<List<News>>(
      future: _localNews!,
      builder: (context, snapshot) {
        if (_locationName == null &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No local news found.'));
        }

        return Column(
          children: [
            if (_locationName != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Showing news for $_locationName",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) =>
                    NewsCard(news: snapshot.data![index]),
              ),
            ),
          ],
        );
      },
    );
  }
}
