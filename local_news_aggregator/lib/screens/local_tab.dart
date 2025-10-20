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
  String _countryCode = 'us';

  // Filter controllers
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  bool _useAutoLocation = true;

  @override
  void initState() {
    super.initState();
    _initLocalNews();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _initLocalNews() async {
    try {
      // Get location data
      final countryCode = await LocationService().getCountryCode();
      final city = await LocationService().getCity();
      final state = await LocationService().getState();
      final country = await LocationService().getCountry();

      setState(() {
        _countryCode = countryCode;
        _cityController.text = city;
        _stateController.text = state;
        _countryController.text = country;
        _locationName = city.isNotEmpty ? '$city, $state' : state;
        _localNews = _fetchLocalNews();
      });
    } catch (e) {
      setState(() {
        _localNews = Future.error("Failed to get location: $e");
      });
    }
  }

  Future<List<News>> _fetchLocalNews() async {
    String? city = _useAutoLocation ? _cityController.text : null;
    String? state = _useAutoLocation ? _stateController.text : null;
    String? country = _useAutoLocation ? _countryController.text : null;

    // If manual filtering, use the typed values
    if (!_useAutoLocation) {
      city = _cityController.text.trim().isNotEmpty
          ? _cityController.text.trim()
          : null;
      state = _stateController.text.trim().isNotEmpty
          ? _stateController.text.trim()
          : null;
      country = _countryController.text.trim().isNotEmpty
          ? _countryController.text.trim()
          : null;
    }

    final articles = await NewsService().fetchLocalNews(
      _countryCode,
      city: city,
      state: state,
      country: country,
    );
    return articles.map((json) => News.fromJson(json)).toList();
  }

  void _applyFilters() {
    setState(() {
      _useAutoLocation = false;
      String locationParts = '';
      if (_cityController.text.trim().isNotEmpty) {
        locationParts = _cityController.text.trim();
      }
      if (_stateController.text.trim().isNotEmpty) {
        locationParts += locationParts.isNotEmpty
            ? ', ${_stateController.text.trim()}'
            : _stateController.text.trim();
      }
      if (_countryController.text.trim().isNotEmpty) {
        locationParts += locationParts.isNotEmpty
            ? ', ${_countryController.text.trim()}'
            : _countryController.text.trim();
      }
      _locationName = locationParts.isNotEmpty
          ? locationParts
          : 'Custom Filter';
      _localNews = _fetchLocalNews();
    });
  }

  void _resetToAutoLocation() {
    setState(() {
      _useAutoLocation = true;
      _initLocalNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_localNews == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Filter Section
        Container(
          padding: const EdgeInsets.all(12.0),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Filter Local News',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        hintText: 'e.g., New York',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State/Province',
                        hintText: 'e.g., California',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        hintText: 'e.g., United States',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Search'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _resetToAutoLocation,
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Use My Location',
                  ),
                ],
              ),
            ],
          ),
        ),
        // News List
        Expanded(
          child: FutureBuilder<List<News>>(
            future: _localNews!,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.newspaper, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No local news found.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try adjusting your filters',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  if (_locationName != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        "📍 Showing news for: $_locationName",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
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
          ),
        ),
      ],
    );
  }
}
