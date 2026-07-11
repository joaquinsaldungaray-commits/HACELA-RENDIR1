import 'package:flutter_test/flutter_test.dart';
import 'package:hacela_rendir/app/hacela_rendir_app.dart';

void main() {
  testWidgets('La aplicación inicia correctamente', (tester) async {
    await tester.pumpWidget(const HacelaRendirApp());

    expect(find.text('HACELA RENDIR'), findsOneWidget);
  });
}