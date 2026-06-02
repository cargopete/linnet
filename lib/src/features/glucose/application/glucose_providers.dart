import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/glucose_repository.dart';
import '../domain/glucose.dart';

final glucoseRepositoryProvider = Provider<GlucoseRepository>(
  (ref) => GlucoseRepository(ref.watch(appDatabaseProvider)),
);

/// All glucose readings, newest first, kept live.
final glucoseReadingsProvider = StreamProvider<List<GlucoseReading>>(
  (ref) => ref.watch(glucoseRepositoryProvider).watchAll(),
);
