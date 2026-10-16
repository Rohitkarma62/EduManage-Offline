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

  test('creates and reads staff details locally', () async {
    final id = await database.saveStaff(
      fullName: 'Asha Sharma',
      role: 'Teacher',
      phone: '9876543210',
      email: 'asha@example.com',
      monthlySalaryPaise: 2850000,
    );

    final staff = await database.getStaffRecords();

    expect(staff, hasLength(1));
    expect(staff.single.read<int>('id'), id);
    expect(staff.single.read<String>('full_name'), 'Asha Sharma');
    expect(staff.single.read<String>('role'), 'Teacher');
    expect(staff.single.read<String>('phone'), '9876543210');
    expect(staff.single.read<String>('email'), 'asha@example.com');
    expect(staff.single.read<int>('monthly_salary_paise'), 2850000);
    expect(staff.single.read<int>('is_active'), 1);
  });

  test('updates existing staff without creating a duplicate', () async {
    final id = await database.saveStaff(
      fullName: 'Asha Sharma',
      role: 'Teacher',
    );

    await database.saveStaff(
      id: id,
      fullName: 'Asha S.',
      role: 'Senior Teacher',
      monthlySalaryPaise: 3000000,
    );

    final staff = await database.getStaffRecords();

    expect(staff, hasLength(1));
    expect(staff.single.read<String>('full_name'), 'Asha S.');
    expect(staff.single.read<String>('role'), 'Senior Teacher');
    expect(staff.single.read<int>('monthly_salary_paise'), 3000000);
  });

  test('deactivates staff but retains the record for reactivation', () async {
    final id = await database.saveStaff(
      fullName: 'Ravi Patel',
      role: 'Accountant',
    );

    await database.setStaffActive(id, isActive: false);

    expect(await database.getStaffRecords(), isEmpty);
    var allStaff = await database.getStaffRecords(includeInactive: true);
    expect(allStaff, hasLength(1));
    expect(allStaff.single.read<int>('is_active'), 0);

    await database.setStaffActive(id, isActive: true);
    allStaff = await database.getStaffRecords();
    expect(allStaff, hasLength(1));
    expect(allStaff.single.read<int>('is_active'), 1);
  });

  test('rejects blank names, blank roles, and negative salary', () async {
    await expectLater(
      database.saveStaff(fullName: '  ', role: 'Teacher'),
      throwsArgumentError,
    );
    await expectLater(
      database.saveStaff(fullName: 'Asha', role: ' '),
      throwsArgumentError,
    );
    await expectLater(
      database.saveStaff(
        fullName: 'Asha',
        role: 'Teacher',
        monthlySalaryPaise: -1,
      ),
      throwsArgumentError,
    );
  });
}
