import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../domain/daily_log.dart';

/// The stored log for a given date (null if nothing logged). Recomputes whenever
/// any log changes so editors and the calendar stay in sync.
final logForDateProvider = FutureProvider.family<DailyLog?, DateTime>((
  ref,
  date,
) async {
  ref.watch(allLogsProvider);
  return ref.watch(dailyLogRepositoryProvider).get(date);
});
