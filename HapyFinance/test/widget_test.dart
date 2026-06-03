import 'package:flutter_test/flutter_test.dart';

import 'package:jijian_jizhang/app.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const JijianApp());
    // Verify the bottom nav bar is present
    expect(find.text('流水'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
