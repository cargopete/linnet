import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/util/secure_clipboard.dart';
import '../data/backup_service.dart';
import '../data/cloud_backup_service.dart';

/// Opt-in, zero-knowledge encrypted backup. Off by default — nothing happens
/// until the user explicitly creates or restores a backup. Creating one hands
/// the encrypted file straight to the iOS share sheet (so it never lingers in a
/// USB/Files-browsable folder); restoring lets the user pick that file back. Only
/// the user's passphrase or recovery key can open it.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  static const _fileName = 'linnet-backup.json';
  bool _busy = false;

  Future<File> _tempBackupFile() async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/$_fileName');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Encrypted backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'A backup is a single encrypted file you control — no account, no '
                'server. It can only be opened with your passphrase or your '
                'recovery key. If you lose both, the backup cannot be recovered '
                'by anyone, including us. That is the point.',
              ),
            ),
          ),
          const SizedBox(height: 8),
          _iCloudSection(),
          const Divider(height: 32),
          Text('Manual file backup', style: theme.textTheme.titleMedium),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Create encrypted backup'),
            subtitle: const Text('Choose a passphrase; keep your recovery key'),
            onTap: _busy ? null : _createBackup,
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore from backup'),
            subtitle: const Text('Replaces all current data on this device'),
            onTap: _busy ? null : _restoreBackup,
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // --- iCloud ---

  Widget _iCloudSection() {
    final service = ref.read(cloudBackupServiceProvider);
    if (!service.isSupported) {
      return const ListTile(
        leading: Icon(Icons.cloud_outlined),
        title: Text('iCloud backup'),
        subtitle: Text('Available on iPhone'),
        enabled: false,
      );
    }
    final enabled = ref.watch(cloudBackupEnabledProvider).value ?? false;
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.cloud_outlined),
          title: const Text('Back up to iCloud'),
          subtitle: Text(
            enabled
                ? 'On — recover on a new phone with your Apple ID'
                : 'Auto-backup an encrypted copy to your iCloud',
          ),
          value: enabled,
          onChanged: _busy
              ? null
              : (v) => v ? _enableICloud() : _disableICloud(),
        ),
        if (enabled)
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Back up now'),
            onTap: _busy ? null : _icloudBackupNow,
          ),
        ListTile(
          leading: const Icon(Icons.cloud_download_outlined),
          title: const Text('Restore from iCloud'),
          subtitle: const Text('On a new phone — replaces current data'),
          onTap: _busy ? null : _restoreFromICloud,
        ),
      ],
    );
  }

  Future<void> _restoreFromICloud() async {
    final secret = await _askRestoreSecret();
    if (secret == null) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(cloudBackupServiceProvider);
      if (secret.useRecoveryKey) {
        await service.restoreWithRecoveryKey(secret.value);
      } else {
        await service.restoreWithPassphrase(secret.value);
      }
      _snack('Restored from iCloud.');
    } catch (e) {
      _snack('Could not restore from iCloud: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<({bool useRecoveryKey, String value})?> _askRestoreSecret() {
    return showModalBottomSheet<({bool useRecoveryKey, String value})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _SecretPrompt(),
    );
  }

  Future<void> _enableICloud() async {
    final passphrase = await _askPassphrase(confirm: true);
    if (passphrase == null) return;
    setState(() => _busy = true);
    try {
      final recoveryKey = await ref
          .read(cloudBackupServiceProvider)
          .enable(passphrase);
      ref.invalidate(cloudBackupEnabledProvider);
      if (mounted) {
        await _showRecoveryKey(
          ExportResult('', recoveryKey),
          sourceNote:
              'Your encrypted backup now lives in your iCloud — recover it on a '
              'new phone with your Apple ID.',
        );
      }
    } catch (e) {
      _snack('Could not turn on iCloud backup: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _icloudBackupNow() async {
    setState(() => _busy = true);
    try {
      await ref.read(cloudBackupServiceProvider).backupNow();
      _snack('Backed up to iCloud.');
    } catch (e) {
      _snack('iCloud backup failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disableICloud() async {
    await ref.read(cloudBackupServiceProvider).disable();
    ref.invalidate(cloudBackupEnabledProvider);
    _snack('iCloud backup turned off.');
  }

  // --- Create ---

  Future<void> _createBackup() async {
    final passphrase = await _askPassphrase(confirm: true);
    if (passphrase == null) return;
    setState(() => _busy = true);
    try {
      final result = await ref.read(backupServiceProvider).export(passphrase);
      // Write to a temp file and hand it to the share sheet so the user saves
      // the encrypted backup wherever they like; then delete the temp copy.
      final file = await _tempBackupFile();
      await file.writeAsString(result.fileContents);
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/json')],
            subject: 'Linnet encrypted backup',
          ),
        );
      } finally {
        if (file.existsSync()) await file.delete();
      }
      if (mounted) await _showRecoveryKey(result);
    } catch (e) {
      _snack('Backup failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showRecoveryKey(
    ExportResult result, {
    String sourceNote =
        'Keep the encrypted file you just shared somewhere safe — that file is '
        'your backup.',
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup created'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Save this recovery key somewhere safe. It can open your backup '
                'even without your passphrase — and it is the only way back in '
                'if you forget it.',
              ),
              const SizedBox(height: 12),
              SelectableText(
                result.recoveryKey,
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 12),
              Text(sourceNote, style: Theme.of(ctx).textTheme.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => SecureClipboard.copy(result.recoveryKey),
            child: const Text('Copy key'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // --- Restore ---

  Future<void> _restoreBackup() async {
    final input = await showModalBottomSheet<_RestoreInput>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _RestoreSheet(),
    );
    if (input == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore and replace?'),
        content: const Text(
          'Restoring replaces all data currently on this device with the '
          'contents of the backup. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      if (input.useRecoveryKey) {
        await service.importWithRecoveryKey(input.fileContents, input.secret);
      } else {
        await service.importWithPassphrase(input.fileContents, input.secret);
      }
      _snack('Backup restored.');
    } catch (e) {
      _snack('Could not restore: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // --- Helpers ---

  Future<String?> _askPassphrase({bool confirm = false}) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => _PassphraseDialog(
        controller: controller,
        confirmController: confirm ? confirmController : null,
      ),
    );
    controller.dispose();
    confirmController.dispose();
    return result;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PassphraseDialog extends StatefulWidget {
  const _PassphraseDialog({required this.controller, this.confirmController});
  final TextEditingController controller;
  final TextEditingController? confirmController;

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final confirming = widget.confirmController != null;
    return AlertDialog(
      title: Text(confirming ? 'Choose a passphrase' : 'Enter passphrase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Passphrase'),
          ),
          if (confirming)
            TextField(
              controller: widget.confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm passphrase',
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('OK')),
      ],
    );
  }

  void _submit() {
    final pass = widget.controller.text;
    if (pass.length < 8) {
      setState(() => _error = 'Use at least 8 characters.');
      return;
    }
    if (widget.confirmController != null &&
        pass != widget.confirmController!.text) {
      setState(() => _error = 'Passphrases do not match.');
      return;
    }
    Navigator.of(context).pop(pass);
  }
}

class _RestoreInput {
  const _RestoreInput({
    required this.fileContents,
    required this.secret,
    required this.useRecoveryKey,
  });
  final String fileContents;
  final String secret;
  final bool useRecoveryKey;
}

class _RestoreSheet extends StatefulWidget {
  const _RestoreSheet();

  @override
  State<_RestoreSheet> createState() => _RestoreSheetState();
}

class _RestoreSheetState extends State<_RestoreSheet> {
  final _backup = TextEditingController();
  final _secret = TextEditingController();
  bool _useRecoveryKey = false;
  String? _pickedName;

  @override
  void dispose() {
    _backup.dispose();
    _secret.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(withData: true);
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    if (mounted) {
      setState(() {
        _backup.text = utf8.decode(bytes);
        _pickedName = result!.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Restore from backup',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(_pickedName ?? 'Choose backup file'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _backup,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Backup contents',
              helperText: 'Choose your backup file above, or paste it here',
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Passphrase')),
              ButtonSegment(value: true, label: Text('Recovery key')),
            ],
            selected: {_useRecoveryKey},
            onSelectionChanged: (s) =>
                setState(() => _useRecoveryKey = s.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _secret,
            obscureText: !_useRecoveryKey,
            decoration: InputDecoration(
              labelText: _useRecoveryKey ? 'Recovery key' : 'Passphrase',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              if (_backup.text.trim().isEmpty || _secret.text.trim().isEmpty) {
                return;
              }
              Navigator.of(context).pop(
                _RestoreInput(
                  fileContents: _backup.text.trim(),
                  secret: _secret.text.trim(),
                  useRecoveryKey: _useRecoveryKey,
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

/// Prompts for a passphrase or recovery key (used for iCloud restore).
class _SecretPrompt extends StatefulWidget {
  const _SecretPrompt();

  @override
  State<_SecretPrompt> createState() => _SecretPromptState();
}

class _SecretPromptState extends State<_SecretPrompt> {
  final _secret = TextEditingController();
  bool _useRecoveryKey = false;

  @override
  void dispose() {
    _secret.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Unlock your iCloud backup',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Passphrase')),
              ButtonSegment(value: true, label: Text('Recovery key')),
            ],
            selected: {_useRecoveryKey},
            onSelectionChanged: (s) =>
                setState(() => _useRecoveryKey = s.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _secret,
            obscureText: !_useRecoveryKey,
            decoration: InputDecoration(
              labelText: _useRecoveryKey ? 'Recovery key' : 'Passphrase',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              final value = _secret.text.trim();
              if (value.isEmpty) return;
              Navigator.of(
                context,
              ).pop((useRecoveryKey: _useRecoveryKey, value: value));
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
