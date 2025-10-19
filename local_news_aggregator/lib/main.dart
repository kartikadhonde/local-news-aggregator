import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LocalNewsAggregatorApp());
}

class LocalNewsAggregatorApp extends StatelessWidget {
  const LocalNewsAggregatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local News Aggregator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
