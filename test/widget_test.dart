
import 'package:flutter_test/flutter_test.dart';
import 'package:expenses_tracker/app.dart';

void main() {
testWidgets('Expense Tracker app loads', (WidgetTester tester) async {
await tester.pumpWidget(const MyApp());

expect(find.byType(MyApp), findsOneWidget);
});
}
