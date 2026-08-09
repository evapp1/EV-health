import 'dart:async';

import 'package:ev_health/application/scan_progress/scan_progress_controller.dart';
import 'package:ev_health/application/scan_progress/scan_progress_coordinator.dart';
import 'package:ev_health/application/scan_progress/scan_progress_state.dart';
import 'package:ev_health/domain/models/vehicle.dart';
import 'package:ev_health/infrastructure/demo/demo_fixture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opening controller does not fabricate completed progress', () {
    final fake = _FakeCoordinator();
    final container = _container(fake);
    addTearDown(container.dispose);

    final state = container.read(scanProgressControllerProvider);

    expect(fake.startCalls, 0);
    expect(
      state.stages.every((stage) => stage.status is ScanStagePending),
      isTrue,
    );
  });

  test('start invokes only the injected coordinator once', () async {
    final fake = _FakeCoordinator();
    final container = _container(fake);
    addTearDown(container.dispose);
    final controller = container.read(scanProgressControllerProvider.notifier);

    await controller.start();
    await controller.start();

    expect(fake.startCalls, 1);
    expect(fake.startedVehicle, same(DemoFixture.vehicle));
  });

  test('cancellation is idempotent and releases session resources', () async {
    final fake = _FakeCoordinator(cancelEmitsEvent: true);
    final container = _container(fake);
    addTearDown(container.dispose);
    final controller = container.read(scanProgressControllerProvider.notifier);
    await controller.start();
    fake.emit(const ScanStarted());

    await controller.cancel();
    await controller.cancel();
    await Future<void>.delayed(Duration.zero);

    expect(fake.cancelCalls, 1);
    expect(fake.releaseCalls, 1);
    expect(
      container.read(scanProgressControllerProvider),
      isA<ScanProgressCancelled>(),
    );
  });

  test('complete, partial, and failed outcomes release resources', () async {
    for (final terminal in <ScanProgressEvent>[
      const ScanPartiallyCompleted('No result.'),
      const ScanFailed('Stopped.'),
    ]) {
      final fake = _FakeCoordinator();
      final container = _container(fake);
      final controller = container.read(
        scanProgressControllerProvider.notifier,
      );
      await controller.start();
      fake.emit(const ScanStarted());
      fake.emit(terminal);
      await Future<void>.delayed(Duration.zero);
      expect(fake.releaseCalls, 1);
      container.dispose();
    }

    final fake = _FakeCoordinator();
    final container = _container(fake);
    final controller = container.read(scanProgressControllerProvider.notifier);
    await controller.start();
    fake.emit(const ScanStarted());
    for (final stage in ScanStage.values) {
      fake.emit(ScanStageCompleted(stage));
    }
    fake.emit(const ScanCompleted());
    await Future<void>.delayed(Duration.zero);
    expect(fake.releaseCalls, 1);
    container.dispose();
  });

  test('illegal coordinator transition fails safely and releases', () async {
    final fake = _FakeCoordinator();
    final container = _container(fake);
    addTearDown(container.dispose);
    final controller = container.read(scanProgressControllerProvider.notifier);
    await controller.start();

    fake.emit(const ScanCompleted());
    await Future<void>.delayed(Duration.zero);

    expect(
      container.read(scanProgressControllerProvider),
      isA<ScanProgressFailed>(),
    );
    expect(fake.releaseCalls, 1);
  });
}

ProviderContainer _container(_FakeCoordinator coordinator) => ProviderContainer(
  overrides: [
    scanProgressVehicleProvider.overrideWithValue(DemoFixture.vehicle),
    scanProgressCoordinatorProvider.overrideWithValue(coordinator),
  ],
);

final class _FakeCoordinator implements ScanProgressCoordinator {
  _FakeCoordinator({this.cancelEmitsEvent = false});

  final bool cancelEmitsEvent;
  final StreamController<ScanProgressEvent> _events =
      StreamController<ScanProgressEvent>.broadcast(sync: true);
  int startCalls = 0;
  int cancelCalls = 0;
  int releaseCalls = 0;
  Vehicle? startedVehicle;

  @override
  Stream<ScanProgressEvent> get events => _events.stream;

  @override
  Future<void> start(Vehicle vehicle) async {
    startCalls += 1;
    startedVehicle = vehicle;
  }

  @override
  Future<void> cancel() async {
    cancelCalls += 1;
    if (cancelEmitsEvent) {
      emit(const ScanCancelled());
    }
  }

  @override
  Future<void> release() async {
    releaseCalls += 1;
  }

  void emit(ScanProgressEvent event) => _events.add(event);
}
