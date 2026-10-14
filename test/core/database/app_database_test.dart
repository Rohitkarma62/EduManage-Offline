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
    await database.saveInstitute(
      name: 'North Star Institute',
      academicYear: '2026-2027',
      phone: '9876543210',
    );

    final institute = await database.getInstitute();

    expect(institute, isNotNull);
    expect(institute!.name, 'North Star Institute');
    expect(institute.academicYear, '2026-2027');
    expect(institute.phone, '9876543210');
    expect(institute.currencyCode, 'INR');
  });

  test('updates the existing institute instead of creating duplicates',
      () async {
    await database.saveInstitute(
      name: 'North Star Institute',
      academicYear: '2026-2027',
    );
    await database.saveInstitute(
      name: 'North Star Academy',
      academicYear: '2027-2028',
    );

    final records = await database.select(database.institutes).get();

    expect(records, hasLength(1));
    expect(records.single.name, 'North Star Academy');
    expect(records.single.academicYear, '2027-2028');
  });
}
