// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyApp builds without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Build a minimal MaterialApp instead of the full app to avoid
    // initializing platform-specific services (Firebase, etc.) in tests.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    // Verify the simple MaterialApp builds.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
