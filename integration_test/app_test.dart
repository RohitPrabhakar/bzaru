import 'package:flutter/material.dart';
import 'package:flutter_bzaru/app.dart';
import 'package:flutter_bzaru/ui/pages/auth/login/login_bottom_sheet.dart';
import 'package:flutter_bzaru/ui/pages/splash.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      "Validations on text form fields after user presses login button, enters way too long number",
      (WidgetTester tester) async {
    await tester.pumpWidget(BzaruApp(home: SplashPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Login"));
    await tester.enterText(find.byType(TextFormField), "8888");
    await tester.pumpAndSettle();
    await tester.tap(find.text("Login with Phone"));
    await tester.pumpAndSettle();

    expect(find.byType(LoginBottomSheet), findsOneWidget);
    expect(find.text("Number can't be less than 10 digits"), findsOneWidget);
  });
}
