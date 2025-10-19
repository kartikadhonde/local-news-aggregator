import 'package:flutter/material.dart';
import 'local_tab.dart';
import 'global_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Local News Aggregator'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Local'),
              Tab(text: 'Global'),
            ],
          ),
        ),
        body: const TabBarView(children: [LocalTab(), GlobalTab()]),
      ),
    );
  }
}
