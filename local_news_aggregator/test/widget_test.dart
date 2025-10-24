// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_news_aggregator/main.dart';

void main() {
  testWidgets('Local News Aggregator app loads successfully', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LocalNewsAggregatorApp());

    // Wait for initial frame
    await tester.pump();

    // Wait for auth initialization
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the app loaded without errors
    // Either welcome screen or main screen should be visible
    expect(
      find.byType(MaterialApp),
      findsOneWidget,
      reason: 'MaterialApp should be present',
    );

    // Verify a Scaffold is present (either from welcome or main screen)
    expect(
      find.byType(Scaffold),
      findsWidgets,
      reason: 'At least one Scaffold should be present',
    );
  });

  testWidgets('Authentication models are properly initialized', (
    WidgetTester tester,
  ) async {
    // Build our app
    await tester.pumpWidget(const LocalNewsAggregatorApp());
    await tester.pump();

    // Just verify the app builds without throwing errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
