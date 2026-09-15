import 'package:flutter_test/flutter_test.dart';

import 'package:somativa_flutter/main.dart';

void main() {
  testWidgets('MundoGhibliApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MundoGhibliApp());
  });
}
