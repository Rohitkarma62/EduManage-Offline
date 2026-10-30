import 'dart:io';

import 'package:edumanage_offline/core/backup/atomic_database_restorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AtomicDatabaseRestorer', () {
    late Directory directory;
    late File live;
    late File staged;
    const restorer = AtomicDatabaseRestorer();

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('edumanage-restore-');
      live = File('${directory.path}/edumanage_offline.sqlite');
      staged = File('${directory.path}/staged.sqlite');
      await live.writeAsString('original database');
      await staged.writeAsString('replacement database');
    });

    tearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test('installs staged file and removes rollback copy', () async {
      await restorer.restore(
        stagedFile: staged,
        liveFile: live,
        validateInstalled: (file) async {
          expect(await file.readAsString(), 'replacement database');
        },
      );

      expect(await live.readAsString(), 'replacement database');
      expect(
        directory.listSync().where(
          (entity) => entity.path.contains('.rollback-'),
        ),
        isEmpty,
      );
    });

    test('restores original file when post-install validation fails', () async {
      await expectLater(
        restorer.restore(
          stagedFile: staged,
          liveFile: live,
          validateInstalled: (_) async {
            throw const FormatException('installed database is invalid');
          },
        ),
        throwsFormatException,
      );

      expect(await live.readAsString(), 'original database');
      expect(
        directory.listSync().where(
          (entity) => entity.path.contains('.rollback-'),
        ),
        isEmpty,
      );
    });

    test('removes invalid install when no previous database exists', () async {
      await live.delete();

      await expectLater(
        restorer.restore(
          stagedFile: staged,
          liveFile: live,
          validateInstalled: (_) async {
            throw const FormatException('invalid');
          },
        ),
        throwsFormatException,
      );

      expect(await live.exists(), isFalse);
    });

    test('removes stale WAL and SHM sidecars before replacement', () async {
      final wal = File('${live.path}-wal');
      final shm = File('${live.path}-shm');
      await wal.writeAsString('stale wal');
      await shm.writeAsString('stale shm');

      await restorer.restore(
        stagedFile: staged,
        liveFile: live,
        validateInstalled: (_) async {},
      );

      expect(await wal.exists(), isFalse);
      expect(await shm.exists(), isFalse);
      expect(await live.readAsString(), 'replacement database');
    });

    test('missing staged file leaves the live database untouched', () async {
      await staged.delete();

      await expectLater(
        restorer.restore(
          stagedFile: staged,
          liveFile: live,
          validateInstalled: (_) async {},
        ),
        throwsStateError,
      );

      expect(await live.readAsString(), 'original database');
    });

    test('rejects staged files from a different directory', () async {
      final otherDirectory =
          await Directory.systemTemp.createTemp('edumanage-staged-');
      final other = File('${otherDirectory.path}/staged.sqlite');
      await other.writeAsString('replacement');

      try {
        await expectLater(
          restorer.restore(
            stagedFile: other,
            liveFile: live,
            validateInstalled: (_) async {},
          ),
          throwsArgumentError,
        );
        expect(await live.readAsString(), 'original database');
      } finally {
        await otherDirectory.delete(recursive: true);
      }
    });
  });
}
