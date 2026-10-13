import 'package:edumanage_offline/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app opens the initial dashboard', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: EduManageApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('EduManage Offline'), findsOneWidget);
    expect(find.text('Institute dashboard'), findsOneWidget);
    expect(find.text('Local database'), findsOneWidget);
  });
}
