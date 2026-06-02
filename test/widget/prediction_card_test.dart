import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/preferences.dart';
import 'package:linnet/src/common/util/date_only.dart';
import 'package:linnet/src/features/onboarding/domain/tracking_goal.dart';
import 'package:linnet/src/features/predictions/domain/cycle_prediction.dart';
import 'package:linnet/src/features/predictions/presentation/prediction_card.dart';

CyclePrediction _sample() => CyclePrediction(
  nextPeriodStart: DateTime(2025, 3, 26),
  nextPeriodWindow: DateRange(DateTime(2025, 3, 25), DateTime(2025, 3, 27)),
  ovulationDay: DateTime(2025, 3, 13),
  fertileWindow: DateRange(DateTime(2025, 3, 7), DateTime(2025, 3, 14)),
  predictedPeriodLength: 5,
  confidence: PredictionConfidence.medium,
  meanCycleLength: 28,
  cycleLengthStdDev: 1.2,
  sampleSize: 4,
  usedPopulationFallback: false,
);

Future<void> _pump(WidgetTester tester, TrackingGoal goal) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [trackingGoalProvider.overrideWithValue(goal)],
      child: MaterialApp(
        home: Scaffold(body: PredictionCard(prediction: _sample())),
      ),
    ),
  );
}

void main() {
  testWidgets('shows ranges, confidence and a non-guarantee disclaimer', (
    tester,
  ) async {
    await _pump(tester, TrackingGoal.generalHealth);

    expect(find.text('Medium confidence'), findsOneWidget);
    expect(find.textContaining('Next period likely'), findsOneWidget);
    expect(find.textContaining('Fertile window'), findsOneWidget);
    expect(find.textContaining('not a guarantee'), findsOneWidget);
  });

  testWidgets('conceive mode reframes the fertile window and shows ovulation', (
    tester,
  ) async {
    await _pump(tester, TrackingGoal.conceive);

    expect(find.textContaining('best days to try'), findsOneWidget);
    expect(find.text('Estimated ovulation'), findsOneWidget);
  });

  testWidgets('avoid mode strengthens the contraception caution', (
    tester,
  ) async {
    await _pump(tester, TrackingGoal.avoidPregnancy);

    expect(find.textContaining('higher-risk days'), findsOneWidget);
    expect(find.textContaining('not contraception'), findsOneWidget);
  });
}
