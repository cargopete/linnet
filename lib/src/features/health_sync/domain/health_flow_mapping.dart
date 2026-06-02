import 'package:health/health.dart';

import '../../cycle_logging/domain/flow_intensity.dart';

/// Pure, exhaustive mapping between Linnet's [FlowIntensity] and HealthKit's
/// [MenstrualFlow]. Kept separate from the plugin-touching service so it can be
/// unit tested on the host without a device.
///
/// Note: HealthKit has no "spotting" category historically, and "unspecified"
/// means flow-of-unknown-intensity — we treat both as spotting on the way in.
abstract final class HealthFlowMapping {
  static MenstrualFlow toMenstrualFlow(FlowIntensity flow) => switch (flow) {
    FlowIntensity.none => MenstrualFlow.none,
    FlowIntensity.spotting => MenstrualFlow.spotting,
    FlowIntensity.light => MenstrualFlow.light,
    FlowIntensity.medium => MenstrualFlow.medium,
    FlowIntensity.heavy => MenstrualFlow.heavy,
  };

  static FlowIntensity fromMenstrualFlow(MenstrualFlow? flow) => switch (flow) {
    MenstrualFlow.none => FlowIntensity.none,
    MenstrualFlow.unspecified => FlowIntensity.spotting,
    MenstrualFlow.light => FlowIntensity.light,
    MenstrualFlow.medium => FlowIntensity.medium,
    MenstrualFlow.heavy => FlowIntensity.heavy,
    MenstrualFlow.spotting => FlowIntensity.spotting,
    null => FlowIntensity.none,
  };
}
