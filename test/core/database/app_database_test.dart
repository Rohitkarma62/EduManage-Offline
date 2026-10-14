import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('stores and reads institute setup details locally', () async {
    await database.into(database.institutes).insert(
          InstitutesCompanion.insert(
            name: 'North Star Institute',
            academicYear: '2026-2027',
          ),
        );

    final records = await database.select(database.institutes).get();

    expect(records, hasLength(1));
    expect(records.single.name, 'North Star Institute');
    expect(records.single.academicYear, '2026-2027');
    expect(records.single.currencyCode, 'INR');
  });
}
