import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/theme/app_theme.dart';

void main() {
  test('light and dark themes build with the warm rose scheme', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      expect(theme.useMaterial3, isTrue);
      expect(theme.textTheme.bodyMedium?.fontFamily, 'PlusJakartaSans');
      // Deep-rose accent, not the old teal.
      expect(theme.colorScheme.primary, isNot(const Color(0xFF2E7D6F)));
    }
  });

  testWidgets('a themed scaffold renders without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: Center(child: Text('Linnet'))),
      ),
    );
    expect(find.text('Linnet'), findsOneWidget);
  });
}
