import 'package:ev_health/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies the EV Health application launch experience.
void main() {
  testWidgets('EV Health app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const EvHealthApp());

    expect(find.text('EV Health'), findsOneWidget);
    expect(find.text('Battery health reports'), findsOneWidget);
    expect(
      find.text('Clear battery insights, stored locally on your device.'),
      findsOneWidget,
    );
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
