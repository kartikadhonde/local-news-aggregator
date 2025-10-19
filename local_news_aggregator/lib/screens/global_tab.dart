import 'package:flutter/material.dart';
import '../models/news.dart';
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
    return articles.map((json) => News.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<News>>(
      future: _globalNews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No global news found.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              NewsCard(news: snapshot.data![index]),
        );
      },
    );
  }
}
