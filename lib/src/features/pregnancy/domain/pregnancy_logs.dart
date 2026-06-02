import 'package:meta/meta.dart';

/// A kick-counting session: the user taps as the baby moves, often aiming for
/// ten movements. [endTime] is null while a session is in progress.
@immutable
class KickSession {
  const KickSession({
    this.id,
    required this.pregnancyId,
    required this.startTime,
    this.endTime,
    this.kickCount = 0,
  });

  final int? id;
  final int pregnancyId;
  final DateTime startTime;
  final DateTime? endTime;
  final int kickCount;

  Duration get elapsed => (endTime ?? startTime).difference(startTime);
}

/// A single timed contraction.
@immutable
class Contraction {
  const Contraction({
    this.id,
    required this.pregnancyId,
    required this.startTime,
    required this.endTime,
  });

  final int? id;
  final int pregnancyId;
  final DateTime startTime;
  final DateTime endTime;

  Duration get duration => endTime.difference(startTime);
}

/// A prenatal appointment or scan.
@immutable
class Appointment {
  const Appointment({
    this.id,
    required this.pregnancyId,
    required this.scheduledFor,
    required this.title,
    this.notes,
  });

  final int? id;
  final int pregnancyId;
  final DateTime scheduledFor;
  final String title;
  final String? notes;
}

/// Summary statistics over a run of contractions. Pure and order-tolerant so it
/// can be unit-tested without any UI or storage.
@immutable
class ContractionStats {
  const ContractionStats({
    required this.count,
    required this.averageDuration,
    required this.averageInterval,
  });

  final int count;

  /// Mean length of a contraction.
  final Duration averageDuration;

  /// Mean time between the *starts* of consecutive contractions (i.e. the
  /// frequency). Zero when there are fewer than two contractions.
  final Duration averageInterval;

  static ContractionStats from(List<Contraction> contractions) {
    if (contractions.isEmpty) {
      return const ContractionStats(
        count: 0,
        averageDuration: Duration.zero,
        averageInterval: Duration.zero,
      );
    }
    final sorted = [...contractions]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final totalDurationMs = sorted.fold<int>(
      0,
      (sum, c) => sum + c.duration.inMilliseconds,
    );
    final avgDuration = Duration(
      milliseconds: totalDurationMs ~/ sorted.length,
    );

    var avgInterval = Duration.zero;
    if (sorted.length >= 2) {
      final spanMs = sorted.last.startTime
          .difference(sorted.first.startTime)
          .inMilliseconds;
      avgInterval = Duration(milliseconds: spanMs ~/ (sorted.length - 1));
    }

    return ContractionStats(
      count: sorted.length,
      averageDuration: avgDuration,
      averageInterval: avgInterval,
    );
  }
}
