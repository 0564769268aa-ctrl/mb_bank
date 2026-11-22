// Widget test cho ứng dụng MB BANK DEMO.

import 'package:flutter_test/flutter_test.dart';

import 'package:mb_bank_demo/main.dart';

void main() {
  testWidgets('hiển thị màn đăng nhập khi chưa đăng nhập',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DemoApp());

    expect(find.text('MB BANK DEMO'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
