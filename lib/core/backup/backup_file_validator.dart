import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';

/// Validates a selected backup before the restore flow can touch live data.
class BackupFileValidator {
  static const sqliteHeader = <int>[
    0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66,
    0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00,
  ];

  static void validateHeader(Uint8List bytes) {
    if (bytes.length < 100 ||
        !_hasSqliteHeader(bytes)) {
      throw const FormatException('Selected file is not a SQLite database.');
    }
  }

  static bool _hasSqliteHeader(Uint8List bytes) {
    for (var index = 0; index < sqliteHeader.length; index++) {
      if (bytes[index] != sqliteHeader[index]) return false;
    }
    return true;
  }

  static Future<void> validateFile(File file) async {
    final bytes = await file.readAsBytes();
    validateHeader(bytes);

    final candidate = AppDatabase(NativeDatabase(file));
    try {
      final integrityRows =
          await candidate.customSelect('PRAGMA integrity_check').get();
      if (integrityRows.length != 1 ||
          integrityRows.single.read<String>('integrity_check') != 'ok') {
        throw const FormatException('SQLite integrity check failed.');
      }

      final foreignKeyErrors =
          await candidate.customSelect('PRAGMA foreign_key_check').get();
      if (foreignKeyErrors.isNotEmpty) {
        throw const FormatException(
          'Backup contains broken foreign-key references.',
        );
      }

      final tables = await candidate.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      ).get();
      final tableNames = tables.map((row) => row.read<String>('name')).toSet();
      const requiredTables = {
        'institutes',
        'students',
        'classes',
        'staff',
        'batches',
        'student_assignments',
      };
      if (!tableNames.containsAll(requiredTables)) {
        throw const FormatException(
          'This file is not a complete EduManage database backup.',
        );
      }

      final versionRows =
          await candidate.customSelect('PRAGMA user_version').get();
      final version = versionRows.single.read<int>('user_version');
      if (version != candidate.schemaVersion) {
        throw FormatException(
          'Backup schema version $version is not supported. '
          'Expected ${candidate.schemaVersion}.',
        );
      }
    } finally {
      await candidate.close();
    }
  }
}
