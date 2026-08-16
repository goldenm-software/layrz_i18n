import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layrz_i18n_example/main.dart';

void main() {
  testWidgets('example app builds and renders translations', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify plain text translations (t and tc methods)
    expect(find.text('Hello, Alice!'), findsOneWidget);
    expect(find.text('5 items'), findsOneWidget);

    // Verify rich text translation (te method) rendered within RichText
    expect(find.byType(RichText), findsWidgets);
  });
}
