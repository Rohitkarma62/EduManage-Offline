import 'dart:io';

import 'package:path/path.dart' as p;

/// Replaces a closed SQLite database using same-directory renames.
///
/// The previous database remains available as a rollback until the installed
/// database has passed validation.
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

    final suffix = DateTime.now().microsecondsSinceEpoch;
    final rollbackFile = File('${liveFile.path}.rollback-$suffix');
    final failedInstallFile = File('${liveFile.path}.failed-$suffix');
    var movedOriginal = false;
    var installedNewFile = false;

    try {
      for (final sidecarSuffix in const ['-wal', '-shm']) {
        final sidecar = File('${liveFile.path}$sidecarSuffix');
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
    } catch (error, stackTrace) {
      // Move the failed install out of the way first. Deleting it directly
      // could fail and prevent the original database from being restored.
      Object? recoveryError;
      try {
        if (installedNewFile && await liveFile.exists()) {
          await liveFile.rename(failedInstallFile.path);
        }
        if (movedOriginal && await rollbackFile.exists()) {
          await rollbackFile.rename(liveFile.path);
        }
        if (await failedInstallFile.exists()) {
          try {
            await failedInstallFile.delete();
          } on FileSystemException {
            // Keep the failed copy for manual recovery; the original is live.
          }
        }
      } catch (restoreError) {
        recoveryError = restoreError;
      }

      if (recoveryError != null) {
        throw StateError(
          'Restore failed ($error) and automatic rollback also failed '
          '($recoveryError). Recovery copy: ${rollbackFile.path}',
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
