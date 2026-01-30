import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rampcheck_flutter/main.dart';

void main() {
  testWidgets('App launches and shows jobs list', (WidgetTester tester) async {
    await tester.pumpWidget(const RampCheckApp());

    expect(find.text('RampCheck - Maintenance Jobs'), findsOneWidget);
  });

  testWidgets('Empty state shows when no jobs', (WidgetTester tester) async {
    await tester.pumpWidget(const RampCheckApp());
    await tester.pumpAndSettle();

    expect(find.text('No maintenance jobs yet'), findsOneWidget);
    expect(find.text('Tap + to create your first job'), findsOneWidget);
  });
}
