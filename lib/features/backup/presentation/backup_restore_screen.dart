import 'dart:io';

import 'package:edumanage_offline/core/backup/atomic_database_restorer.dart';
import 'package:edumanage_offline/core/backup/backup_file_validator.dart';
import 'package:edumanage_offline/core/database/database_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _working = false;

  Future<File> _databaseFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.join(directory.path, 'edumanage_offline.sqlite'));
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createBackup() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final database = ref.read(appDatabaseProvider);
      await database.customStatement('PRAGMA wal_checkpoint(FULL)');
      final file = await _databaseFile();
      if (!await file.exists()) {
        throw StateError('The local database file was not found.');
      }
      final now = DateTime.now();
      final stamp = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}-'
          '${now.minute.toString().padLeft(2, '0')}';
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save EduManage backup',
        fileName: 'edumanage-backup-$stamp.sqlite',
        bytes: await file.readAsBytes(),
      );
      if (savedPath != null) {
        _showMessage('Backup exported successfully.');
      }
    } catch (error) {
      _showMessage('Backup failed: $error');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _restoreBackup() async {
    if (_working) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'Restoring replaces all institute data on this device with the '
          'selected backup. Export a current backup first if you need to keep '
          'the existing data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _working = true);
    String? temporaryPath;
    try {
      final selection = await FilePicker.platform.pickFiles(
        dialogTitle: 'Choose an EduManage SQLite backup',
        type: FileType.custom,
        allowedExtensions: const ['sqlite', 'db'],
        withData: true,
        allowMultiple: false,
      );
      if (selection == null) return;
      final bytes = selection.files.single.bytes;
      if (bytes == null) {
        throw const FormatException('The selected backup could not be read.');
      }
      BackupFileValidator.validateHeader(bytes);

      final directory = await getApplicationDocumentsDirectory();
      temporaryPath = p.join(
        directory.path,
        'edumanage-restore-${DateTime.now().microsecondsSinceEpoch}.sqlite',
      );
      final temporaryFile = File(temporaryPath);
      await temporaryFile.writeAsBytes(bytes, flush: true);

      await BackupFileValidator.validateFile(temporaryFile);

      final liveFile = await _databaseFile();
      final liveDatabase = ref.read(appDatabaseProvider);
      await liveDatabase.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      await liveDatabase.close();
      ref.invalidate(appDatabaseProvider);
      await const AtomicDatabaseRestorer().restore(
        stagedFile: temporaryFile,
        liveFile: liveFile,
        validateInstalled: BackupFileValidator.validateFile,
      );
      if (!mounted) return;
      _showMessage('Backup restored. Reopen the app to refresh all screens.');
      context.go('/');
    } catch (error) {
      _showMessage('Restore failed: $error');
    } finally {
      if (temporaryPath != null) {
        final temporaryFile = File(temporaryPath);
        if (await temporaryFile.exists()) {
          await temporaryFile.delete();
        }
      }
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.backup_outlined, size: 52),
          const SizedBox(height: 12),
          Text(
            'Keep a safe copy of your institute data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Backups include the local SQLite database: students, classes, '
            'fees, attendance, staff, salary payments, expenses, exams and '
            'results. Save backups somewhere separate from this device.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create backup',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Export a complete SQLite database file to a location you choose.',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _working ? null : _createBackup,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Export backup'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restore backup',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose a previous EduManage .sqlite or .db backup. '
                    'The existing database will be replaced.',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _working ? null : _restoreBackup,
                      icon: const Icon(Icons.restore),
                      label: const Text('Choose backup to restore'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_working) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Working with the local database…'),
          ],
          const SizedBox(height: 16),
          const Text(
            'Important: restoring a backup replaces current data. Keep a '
            'separate copy before restoring. Backups may contain sensitive '
            'student and financial information.',
          ),
        ],
      ),
    );
  }
}
