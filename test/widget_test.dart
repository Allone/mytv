import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mytv/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MyTvApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}