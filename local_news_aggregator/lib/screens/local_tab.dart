import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../services/auth_service.dart';
import '../widgets/news_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool _localSourcesOnly = false; // New toggle for local sources filter

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
      final authService = context.read<AuthService>();
      final user = authService.currentUser;

      String? city;
      String? state;
      String? country;
      String countryCode = 'us';

      if (user?.defaultCity != null || user?.defaultState != null) {
        city = user?.defaultCity ?? '';
        state = user?.defaultState ?? '';
        country = user?.defaultCountry ?? '';
        countryCode = user?.defaultCountryCode ?? 'us';
      }

      setState(() {
        _countryCode = countryCode;
        _cityController.text = city ?? '';
        _stateController.text = state ?? '';
        _countryController.text = country ?? '';
        _locationName = city != null && city.isNotEmpty
            ? '$city, $state'
            : state ?? '';
        if ((city != null && city.isNotEmpty) ||
            (state != null && state.isNotEmpty) ||
            (country != null && country.isNotEmpty)) {
          _localNews = _fetchLocalNews();
        }
      });
    } catch (e) {
      setState(() {
        _locationName = null;
      });
    }
  }

  Future<List<News>> _fetchLocalNews() async {
    String? city = _cityController.text.trim().isNotEmpty
        ? _cityController.text.trim()
        : null;
    String? state = _stateController.text.trim().isNotEmpty
        ? _stateController.text.trim()
        : null;
    String? country = _countryController.text.trim().isNotEmpty
        ? _countryController.text.trim()
        : null;

    final articles = await NewsService().fetchLocalNews(
      _countryCode,
      city: city,
      state: state,
      country: country,
      localSourcesOnly: _localSourcesOnly,
    );
    try {
      final removed = await FirebaseFirestore.instance
          .collection('removed_articles')
          .get();
      final removedUrls = removed.docs
          .map((d) => d.data()['url'] as String?)
          .whereType<String>()
          .toSet();
      return articles
          .where((j) => !removedUrls.contains(j['url'] as String?))
          .map((json) => News.fromJson(json))
          .toList();
    } catch (_) {
      // If Firestore is not accessible (e.g., admin not authed), just show articles
      return articles.map((json) => News.fromJson(json)).toList();
    }
  }

  void _applyFilters() {
    setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
            title: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Filter Local News',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              hintText: 'e.g., New York',
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
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
                              prefixIcon: Icon(Icons.map),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _localSourcesOnly
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: SwitchListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.newspaper,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Local Sources Only',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          'Show only news from local newspapers & outlets',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        value: _localSourcesOnly,
                        onChanged: (bool value) {
                          setState(() {
                            _localSourcesOnly = value;
                            if (_localNews != null) {
                              _localNews = _fetchLocalNews();
                            }
                          });
                        },
                      ),
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
                              prefixIcon: Icon(Icons.flag),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
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
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // News List
        Expanded(
          child: _localNews == null
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_searching,
                                size: 80,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Choose a Location',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Enter a city, state, or country to view local news',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : FutureBuilder<List<News>>(
                  future: _localNews!,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading local news...',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Unable to load news',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Please check your filters and try again',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _localNews = _fetchLocalNews();
                                        });
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.newspaper_outlined,
                                      size: 64,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No News Found',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _localSourcesOnly
                                          ? 'No local news sources found for this location.\nTry turning off "Local Sources Only"'
                                          : 'Try adjusting your search filters',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_localSourcesOnly) ...[
                                      const SizedBox(height: 16),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _localSourcesOnly = false;
                                            _localNews = _fetchLocalNews();
                                          });
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Show All Sources'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return Column(
                      children: [
                        if (_locationName != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.secondary,
                                  Theme.of(context).colorScheme.tertiary,
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Showing news for: $_locationName${_localSourcesOnly ? ' (Local sources only)' : ''}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_localSourcesOnly) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.newspaper,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${snapshot.data!.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
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
