import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:linnet/src/features/cycle_logging/domain/flow_intensity.dart';
import 'package:linnet/src/features/health_sync/domain/health_flow_mapping.dart';

void main() {
  test('light/medium/heavy round-trip exactly', () {
    for (final f in [
      FlowIntensity.light,
      FlowIntensity.medium,
      FlowIntensity.heavy,
    ]) {
      final m = HealthFlowMapping.toMenstrualFlow(f);
      expect(HealthFlowMapping.fromMenstrualFlow(m), f);
    }
  });

  test('none maps to none both ways', () {
    expect(
      HealthFlowMapping.toMenstrualFlow(FlowIntensity.none),
      MenstrualFlow.none,
    );
    expect(
      HealthFlowMapping.fromMenstrualFlow(MenstrualFlow.none),
      FlowIntensity.none,
    );
  });

  test('unspecified and spotting both read as spotting', () {
    expect(
      HealthFlowMapping.fromMenstrualFlow(MenstrualFlow.unspecified),
      FlowIntensity.spotting,
    );
    expect(
      HealthFlowMapping.fromMenstrualFlow(MenstrualFlow.spotting),
      FlowIntensity.spotting,
    );
  });

  test('null (missing value) reads as none', () {
    expect(HealthFlowMapping.fromMenstrualFlow(null), FlowIntensity.none);
  });
}
