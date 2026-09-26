import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verishift_app/core/app.dart';

void main() {
  testWidgets('root resolves to login and login form renders',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final deps = await AppDependencies.create(prefsOverride: prefs);
    await tester.pumpWidget(SmartAttendanceApp(deps: deps));
    // Splash (/) shows first.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 1));
    // Splash redirects unauthenticated users to /login.
    expect(find.text('Sign in'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
