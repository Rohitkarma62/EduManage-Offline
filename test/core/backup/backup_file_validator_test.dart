import 'dart:io';
import 'dart:typed_data';

import 'package:edumanage_offline/core/backup/backup_file_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupFileValidator', () {
    test('accepts the SQLite file signature', () {
      final bytes = Uint8List.fromList([
        ...BackupFileValidator.sqliteHeader,
        ...List<int>.filled(84, 0),
      ]);
      expect(() => BackupFileValidator.validateHeader(bytes), returnsNormally);
    });

    test('rejects files that are not SQLite databases', () {
      expect(
        () => BackupFileValidator.validateHeader(
          Uint8List.fromList('not a database'.codeUnits),
        ),
        throwsFormatException,
      );
    });

    test('rejects truncated SQLite files', () {
      expect(
        () => BackupFileValidator.validateHeader(
          Uint8List.fromList(BackupFileValidator.sqliteHeader),
        ),
        throwsFormatException,
      );
    });

    test('rejects an invalid file before opening it with Drift', () async {
      final directory =
          await Directory.systemTemp.createTemp('edumanage-backup-test-');
      try {
        final file = File('${directory.path}/invalid.sqlite');
        await file.writeAsString('not sqlite');
        await expectLater(
          BackupFileValidator.validateFile(file),
          throwsFormatException,
        );
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });
}
