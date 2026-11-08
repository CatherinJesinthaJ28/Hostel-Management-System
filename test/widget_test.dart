import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Hostel Management app test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Hostel Management'),
        ),
      ),
    );

    expect(find.text('Hostel Management'), findsOneWidget);
  });
}