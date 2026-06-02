import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/common/crypto/database_key_store.dart';
import 'src/common/database/database.dart';
import 'src/common/preferences.dart';
import 'src/common/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap the encrypted store: fetch (or mint) the Keychain DEK, then open
  // the database with it. Everything downstream receives these via overrides.
  final keyStore = DatabaseKeyStore();
  final keyHex = await keyStore.getOrCreateKeyHex();
  final database = AppDatabase(keyHex);
  final appLockEnabled =
      (await database.getSetting('appLockEnabled')) == 'true';
  final onboarded =
      (await database.getSetting('hasCompletedOnboarding')) == 'true';
  final reflectionRaw = await database.getSetting('reflectionPregnancyId');
  final reflectionId = (reflectionRaw == null || reflectionRaw.isEmpty)
      ? null
      : int.tryParse(reflectionRaw);

  runApp(
    ProviderScope(
      overrides: [
        databaseKeyStoreProvider.overrideWithValue(keyStore),
        appDatabaseProvider.overrideWithValue(database),
        appLockEnabledInitialProvider.overrideWithValue(appLockEnabled),
        onboardingCompleteInitialProvider.overrideWithValue(onboarded),
        reflectionInitialIdProvider.overrideWithValue(reflectionId),
      ],
      child: const LinnetApp(),
    ),
  );
}
