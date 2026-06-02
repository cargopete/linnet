import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/health_service.dart';

final healthServiceProvider = Provider<HealthService>((ref) => HealthService());
