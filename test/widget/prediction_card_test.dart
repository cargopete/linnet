import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/util/date_only.dart';
import 'package:linnet/src/features/predictions/domain/cycle_prediction.dart';
import 'package:linnet/src/features/predictions/presentation/prediction_card.dart';

void main() {
  testWidgets('shows ranges, confidence and a non-guarantee disclaimer', (
    tester,
  ) async {
    final prediction = CyclePrediction(
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PredictionCard(prediction: prediction)),
      ),
    );

    expect(find.text('Medium confidence'), findsOneWidget);
    expect(find.textContaining('Next period likely'), findsOneWidget);
    expect(find.textContaining('Fertile window'), findsOneWidget);
    expect(find.textContaining('not a guarantee'), findsOneWidget);
  });
}
