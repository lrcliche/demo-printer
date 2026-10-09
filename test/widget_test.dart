import 'package:flutter_test/flutter_test.dart';
import 'package:demo_printer/main.dart';

void main() {
  testWidgets('Printer App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DemoPrinterApp());
    expect(find.text('Impresión por USB / Térmica'), findsOneWidget);
  });
}
