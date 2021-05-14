import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Sales mirror |", () {
    testWidgets("Empty list. Should show feedback message",
        (WidgetTester tester) async {});
    testWidgets("Null list. Should show feedback message",
        (WidgetTester tester) async {});
    testWidgets(
        "Normal list. Should show cards", (WidgetTester tester) async {});
  });
}
