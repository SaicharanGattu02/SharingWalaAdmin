import 'package:flutter_test/flutter_test.dart';
import 'package:sharingwalaadmin/main.dart';

void main() {
  testWidgets('Admin app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SharingwalaAdminApp());
    expect(find.byType(SharingwalaAdminApp), findsOneWidget);
  });
}
