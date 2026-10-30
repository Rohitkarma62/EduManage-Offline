import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// A PDF managed by EduManage inside the app's private documents directory.
class StoredDocument {
  const StoredDocument({
    required this.file,
    required this.fileName,
    required this.title,
    required this.modifiedAt,
    required this.sizeBytes,
  });

  final File file;
  final String fileName;
  final String title;
  final DateTime modifiedAt;
  final int sizeBytes;
}

/// Stores generated PDFs without relying on user-visible external storage.
class DocumentStorage {
  DocumentStorage({required Directory baseDirectory})
      : _directory = Directory(p.join(baseDirectory.path, 'edumanage_documents'));

  final Directory _directory;

  Future<StoredDocument> savePdf({
    required Uint8List bytes,
    required String title,
  }) async {
    if (bytes.length < 8 ||
        String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const FormatException('The document is not a valid PDF file.');
    }
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title cannot be empty.');
    }
    await _directory.create(recursive: true);
    final safeTitle = normalizedTitle
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final fileName = '${safeTitle.isEmpty ? 'document' : safeTitle}-$stamp.pdf';
    final file = File(p.join(_directory.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return StoredDocument(
      file: file,
      fileName: fileName,
      title: normalizedTitle,
      modifiedAt: await file.lastModified(),
      sizeBytes: await file.length(),
    );
  }

  Future<List<StoredDocument>> listPdfs() async {
    if (!await _directory.exists()) return const [];
    final documents = <StoredDocument>[];
    await for (final entity in _directory.list(followLinks: false)) {
      if (entity is! File || p.extension(entity.path).toLowerCase() != '.pdf') {
        continue;
      }
      final stat = await entity.stat();
      documents.add(StoredDocument(
        file: entity,
        fileName: p.basename(entity.path),
        title: p.basenameWithoutExtension(entity.path),
        modifiedAt: stat.modified,
        sizeBytes: stat.size,
      ));
    }
    documents.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return documents;
  }

  Future<void> delete(StoredDocument document) async {
    final expectedPath = p.normalize(p.absolute(p.join(_directory.path, document.fileName)));
    final actualPath = p.normalize(p.absolute(document.file.path));
    if (expectedPath != actualPath ||
        p.dirname(actualPath) != p.normalize(p.absolute(_directory.path))) {
      throw ArgumentError('The document does not belong to EduManage storage.');
    }
    if (await document.file.exists()) await document.file.delete();
  }
}
