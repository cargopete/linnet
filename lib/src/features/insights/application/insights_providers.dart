import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../domain/symptom_insights.dart';

/// Symptom insights over the last 90 days, recomputed when logs change.
final symptomInsightsProvider = Provider<SymptomInsights>((ref) {
  final logs = ref.watch(allLogsProvider).value ?? const [];
  return SymptomInsights.from(logs, asOf: DateTime.now());
});
