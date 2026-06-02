import 'dart:io';

import 'package:health/health.dart';

import '../../cycle_logging/domain/daily_log.dart';
import '../../cycle_logging/domain/flow_intensity.dart';
import '../domain/health_flow_mapping.dart';

/// Result of an import: the menstrual-flow days read from HealthKit, ready to be
/// merged into the local store by the caller (so other logged fields survive).
class HealthImport {
  const HealthImport(this.days);
  final List<DailyLog> days;
  int get count => days.length;
}

/// Thin, defensive wrapper around the `health` plugin, scoped to the one
/// reproductive datum HealthKit exposes cleanly: menstrual flow. Every call is
/// iOS-gated and the caller decides when to invoke it — nothing here runs
/// unless the user explicitly connects Apple Health.
class HealthService {
  HealthService([Health? health]) : _health = health ?? Health();

  final Health _health;

  static const List<HealthDataType> _types = [HealthDataType.MENSTRUATION_FLOW];

  /// HealthKit is iOS-only; on anything else this service is inert.
  bool get isSupported => Platform.isIOS;

  /// Requests read+write access to menstrual flow. Returns whether granted.
  Future<bool> requestPermissions() async {
    if (!isSupported) return false;
    await _health.configure();
    return _health.requestAuthorization(
      _types,
      permissions: const [HealthDataAccess.READ_WRITE],
    );
  }

  /// Writes each non-empty flow day to HealthKit. [periodStartDates] flags which
  /// days are the first of a cycle (HealthKit's `isStartOfCycle`). Returns the
  /// number of days written.
  Future<int> exportFlow(
    Iterable<DailyLog> logs, {
    Set<DateTime> periodStartDates = const {},
  }) async {
    if (!isSupported) return 0;
    await _health.configure();
    var written = 0;
    for (final log in logs) {
      if (log.flow == FlowIntensity.none) continue;
      final start = log.date;
      final end = log.date.add(const Duration(hours: 23, minutes: 59));
      final ok = await _health.writeMenstruationFlow(
        flow: HealthFlowMapping.toMenstrualFlow(log.flow),
        startTime: start,
        endTime: end,
        isStartOfCycle: periodStartDates.contains(start),
      );
      if (ok) written++;
    }
    return written;
  }

  /// Reads menstrual-flow points in [start, end] and collapses them to one flow
  /// value per day (last write wins within a day).
  Future<HealthImport> importFlow({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!isSupported) return const HealthImport([]);
    await _health.configure();
    final points = await _health.getHealthDataFromTypes(
      types: _types,
      startTime: start,
      endTime: end,
    );
    final byDate = <DateTime, FlowIntensity>{};
    for (final point in points) {
      final value = point.value;
      if (value is MenstruationFlowHealthValue) {
        final d = point.dateFrom;
        final date = DateTime(d.year, d.month, d.day);
        byDate[date] = HealthFlowMapping.fromMenstrualFlow(value.flow);
      }
    }
    final days = [
      for (final entry in byDate.entries)
        DailyLog(date: entry.key, flow: entry.value),
    ];
    return HealthImport(days);
  }
}
