import 'package:flutter_test/flutter_test.dart';
import 'package:tesclinic/main.dart';

void main() {
  testWidgets('TesClinic smoke test', (tester) async {
    await tester.pumpWidget(const TesClinicApp());
    await tester.pump();
    expect(find.byType(TesClinicApp), findsOneWidget);
  });
}
