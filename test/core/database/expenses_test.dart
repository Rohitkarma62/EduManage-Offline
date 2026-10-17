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

  test('records an expense and includes it in the monthly summary', () async {
    final now = DateTime.now();
    await database.recordExpense(
      category: 'Utilities',
      description: 'Electricity bill',
      amountPaise: 125050,
      paymentMethod: 'UPI',
      spentAt: DateTime(now.year, now.month, 5),
      reference: 'BILL-101',
    );

    final expenses = await database.getExpenses(month: now);
    final summary = await database.getExpenseSummary(month: now);

    expect(expenses, hasLength(1));
    expect(expenses.single.read<String>('category'), 'Utilities');
    expect(expenses.single.read<String>('description'), 'Electricity bill');
    expect(expenses.single.read<int>('amount_paise'), 125050);
    expect(expenses.single.read<String>('payment_method'), 'UPI');
    expect(expenses.single.read<String>('reference'), 'BILL-101');
    expect(summary, {'count': 1, 'totalPaise': 125050});
  });

  test('filters expenses by month and keeps older expenses out of summary', () async {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 12);
    await database.recordExpense(
      category: 'Rent',
      description: 'Previous month rent',
      amountPaise: 500000,
      paymentMethod: 'Bank transfer',
      spentAt: previousMonth,
    );
    await database.recordExpense(
      category: 'Supplies',
      description: 'Stationery',
      amountPaise: 25000,
      paymentMethod: 'Cash',
      spentAt: now,
    );

    final current = await database.getExpenses(month: now);
    final summary = await database.getExpenseSummary(month: now);

    expect(current, hasLength(1));
    expect(current.single.read<String>('description'), 'Stationery');
    expect(summary, {'count': 1, 'totalPaise': 25000});
  });

  test('rejects invalid expense amounts, categories, and payment methods', () async {
    final now = DateTime.now();
    Future<void> record({
      String category = 'Other',
      int amountPaise = 100,
      String method = 'Cash',
    }) =>
        database.recordExpense(
          category: category,
          description: 'Test expense',
          amountPaise: amountPaise,
          paymentMethod: method,
          spentAt: now,
        );

    await expectLater(record(amountPaise: 0), throwsArgumentError);
    await expectLater(record(amountPaise: -100), throwsArgumentError);
    await expectLater(record(category: '  '), throwsArgumentError);
    await expectLater(record(method: 'Crypto'), throwsArgumentError);
    expect(await database.getExpenses(), isEmpty);
  });

  test('rejects future expense dates', () async {
    await expectLater(
      database.recordExpense(
        category: 'Other',
        description: 'Future expense',
        amountPaise: 100,
        paymentMethod: 'Cash',
        spentAt: DateTime.now().add(const Duration(days: 2)),
      ),
      throwsArgumentError,
    );
  });
}
