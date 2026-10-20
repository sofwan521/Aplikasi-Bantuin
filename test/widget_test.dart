import 'package:flutter_test/flutter_test.dart';
import 'package:uts/main.dart';

void main() {
  testWidgets('Beranda menampilkan kolom pencarian', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BantuinApp());

    expect(find.text('Cari'), findsOneWidget);
  });
}
