import 'dart:io';

import 'package:path/path.dart' as p;

/// Replaces a closed SQLite database using same-directory renames.
///
/// Keeping the previous database under a rollback name means a failed install
/// or post-install validation never leaves the app without its original file.
class AtomicDatabaseRestorer {
  const AtomicDatabaseRestorer();

  Future<void> restore({
    required File stagedFile,
    required File liveFile,
    required Future<void> Function(File installedFile) validateInstalled,
  }) async {
    final stagedParent = p.normalize(p.absolute(p.dirname(stagedFile.path)));
    final liveParent = p.normalize(p.absolute(p.dirname(liveFile.path)));
    if (stagedParent != liveParent) {
      throw ArgumentError('Staged and live databases must share a directory.');
    }
    if (!await stagedFile.exists()) {
      throw StateError('Staged backup does not exist.');
    }

    final rollbackFile = File(
      '${liveFile.path}.rollback-${DateTime.now().microsecondsSinceEpoch}',
    );
    var movedOriginal = false;
    var installedNewFile = false;

    try {
      for (final suffix in const ['-wal', '-shm']) {
        final sidecar = File('${liveFile.path}$suffix');
        if (await sidecar.exists()) await sidecar.delete();
      }

      if (await liveFile.exists()) {
        await liveFile.rename(rollbackFile.path);
        movedOriginal = true;
      }

      await stagedFile.rename(liveFile.path);
      installedNewFile = true;
      await validateInstalled(liveFile);

      if (movedOriginal && await rollbackFile.exists()) {
        await rollbackFile.delete();
      }
    } catch (_) {
      if (installedNewFile && await liveFile.exists()) {
        await liveFile.delete();
      }
      if (movedOriginal && await rollbackFile.exists()) {
        await rollbackFile.rename(liveFile.path);
      }
      rethrow;
    }
  }
}
