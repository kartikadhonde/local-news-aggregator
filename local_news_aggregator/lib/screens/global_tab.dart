import 'package:flutter/material.dart';
import '../models/news.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/news_service.dart';
import '../widgets/news_card.dart';

class GlobalTab extends StatefulWidget {
  const GlobalTab({super.key});

  @override
  State<GlobalTab> createState() => _GlobalTabState();
}

class _GlobalTabState extends State<GlobalTab> {
  late Future<List<News>> _globalNews;

  @override
  void initState() {
    super.initState();
    _initGlobalNews();
  }

  Future<void> _initGlobalNews() async {
    setState(() {
      _globalNews = _fetchGlobalNews();
    });
  }

  Future<List<News>> _fetchGlobalNews() async {
    final articles = await NewsService().fetchGlobalNews();
    return _filterRemovedArticles(articles);
  }

  Future<List<News>> _filterRemovedArticles(
    List<Map<String, dynamic>> articles,
  ) async {
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
      return articles.map((json) => News.fromJson(json)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<News>>(
      future: _globalNews,
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
                  'Loading global news...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your connection and try again',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _globalNews = _fetchGlobalNews();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.newspaper_outlined,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No News Found',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for updates',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              NewsCard(news: snapshot.data![index]),
        );
      },
    );
  }
}
