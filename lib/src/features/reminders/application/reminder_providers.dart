import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/notification_service.dart';
import '../data/reminder_repository.dart';
import '../domain/reminder.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(appDatabaseProvider)),
);

/// All reminders (every kind, with defaults), kept live.
final remindersProvider = StreamProvider<List<Reminder>>(
  (ref) => ref.watch(reminderRepositoryProvider).watchAll(),
);

/// The notification service. Overridden in `main` with the initialised instance.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);
