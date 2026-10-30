import 'dart:io';
import 'dart:typed_data';

import 'package:edumanage_offline/core/storage/document_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late DocumentStorage storage;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('edumanage-docs-');
    storage = DocumentStorage(baseDirectory: temporaryDirectory);
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('saves and lists a PDF in private app document storage', () async {
    final saved = await storage.savePdf(
      bytes: Uint8List.fromList('%PDF-1.4 test'.codeUnits),
      title: 'Bonafide Certificate / Student',
    );

    expect(saved.fileName, endsWith('.pdf'));
    expect(saved.fileName, isNot(contains('/')));
    expect(await saved.file.exists(), isTrue);
    expect((await storage.listPdfs()).single.fileName, saved.fileName);
  });

  test('rejects empty titles and non-PDF data', () async {
    expect(
      () => storage.savePdf(
        bytes: Uint8List.fromList('not a pdf'.codeUnits),
        title: 'Invalid',
      ),
      throwsFormatException,
    );
    expect(
      () => storage.savePdf(
        bytes: Uint8List.fromList('%PDF-1.4'.codeUnits),
        title: '  ',
      ),
      throwsArgumentError,
    );
  });

  test('deletes only documents owned by this storage instance', () async {
    final saved = await storage.savePdf(
      bytes: Uint8List.fromList('%PDF-1.4 test'.codeUnits),
      title: 'Receipt',
    );
    await storage.delete(saved);
    expect(await saved.file.exists(), isFalse);
    expect(await storage.listPdfs(), isEmpty);
  });
}
