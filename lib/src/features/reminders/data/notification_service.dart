import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/reminder.dart';

/// Schedules opt-in daily local reminders. Entirely defensive: every call is
/// wrapped so a notification hiccup can never break the app, and nothing is ever
/// scheduled unless the user enabled a reminder. Notification text is generic.
///
/// This layer touches platform plugins and cannot be exercised in unit tests;
/// the scheduling *logic* lives in [nextDailyInstance], which is tested.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Initialises timezones and the plugin. Safe to call once at startup.
  Future<void> init() async {
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } on Object {
      _ready = false;
    }
  }

  /// Asks the OS for notification permission. Returns whether granted.
  Future<bool> requestPermission() async {
    if (!Platform.isIOS) return false;
    try {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } on Object {
      return false;
    }
  }

  /// Cancels everything and reschedules the enabled reminders. Call after any
  /// change so the OS schedule mirrors the stored reminders.
  Future<void> sync(List<Reminder> reminders) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      for (final r in reminders.where((r) => r.enabled)) {
        await _schedule(r);
      }
    } on Object {
      // Best-effort; never throw into the UI.
    }
  }

  Future<void> _schedule(Reminder r) async {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      r.hour,
      r.minute,
    );
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id: r.kind.index,
      title: 'Linnet',
      body: r.kind.body,
      scheduledDate: when,
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }
}
