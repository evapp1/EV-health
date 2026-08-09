import 'package:ev_health/app/app.dart';
import 'package:ev_health/features/scan_progress/presentation/screens/scan_progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TASK-015 Start Scan navigates to /scan/progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      const EvHealthApp(initialLocation: '/setup/vehicle'),
    );
    await tester.pumpAndSettle();

    final confirm = find.byKey(const Key('confirm-supported-vehicle'));
    await tester.scrollUntilVisible(confirm, 250);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(find.text('Prepare for battery scan'), findsOneWidget);
    final start = find.byKey(const Key('start-scan-action'));
    await tester.scrollUntilVisible(start, 250);
    await tester.tap(start);
    await tester.pump();
    await tester.pump();

    expect(find.byType(ScanProgressScreen), findsOneWidget);
    expect(find.text('Checking your battery'), findsOneWidget);
    expect(find.text('DEMO MODE — SIMULATED SCAN'), findsOneWidget);
  });
}
