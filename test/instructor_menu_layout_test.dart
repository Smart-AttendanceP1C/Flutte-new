import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verishift_app/core/app.dart';
import 'package:verishift_app/core/network/api_client.dart';
import 'package:verishift_app/core/routing/app_routes.dart';
import 'package:verishift_app/features/instructor/screens/instructor_menu_screen.dart';

/// Regression test for the Instructor Menu rendering crash:
/// `RenderBox was not laid out ... 'hasSize'` (+ `BoxConstraints forces an
/// infinite width`).
///
/// Root cause was the Launch [ElevatedButton] in the QR card: it inherits
/// `minimumSize: Size.fromHeight(56)` (infinite min width) from [AppTheme],
/// but is measured with unbounded width as a [Row] child, so it threw during
/// layout and aborted the whole screen subtree. Uses the real app + theme
/// (a plain MaterialApp with the default theme never reproduced it).
void main() {
  testWidgets('instructor menu lays out with no crash at phone width',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final errors = <String>[];
    final oldHandler = FlutterError.onError;
    FlutterError.onError =
        (details) => errors.add(details.toString());
    addTearDown(() => FlutterError.onError = oldHandler);

    SharedPreferences.setMockInitialValues({
      'sa.token': 'test.token.value',
      'sa.user': jsonEncode({
        'id': 1,
        'name': 'Test Lecturer',
        'email': 'staff1@bua.edu.eg',
        'role': 'lecturer',
      }),
    });
    final prefs = await SharedPreferences.getInstance();
    final api = ApiClient(
      tokenProvider: () async => 'test.token.value',
      httpClient: MockClient((_) => throw http.ClientException('offline')),
    );
    final deps = await AppDependencies.create(
      prefsOverride: prefs,
      apiOverride: api,
    );
    await tester.pumpWidget(SmartAttendanceApp(deps: deps));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));

    deps.navigatorKey.currentState!.pushNamedAndRemoveUntil(
        AppRoutes.instructorMenu, (r) => false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 110));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(InstructorMenuScreen), findsOneWidget);

    final crashClass = errors
        .where((e) =>
            e.contains('was not laid out') ||
            e.contains('forces an infinite width'))
        .toList();
    expect(crashClass, isEmpty,
        reason: 'Layout crash (hasSize/infinite width):\n'
            '${crashClass.take(2).join('\n---\n')}');

    final menuFile = errors
        .where((e) => e.contains('instructor_menu_screen.dart'))
        .toList();
    expect(menuFile, isEmpty,
        reason: 'Instructor menu layout errors:\n'
            '${menuFile.take(3).join('\n---\n')}');
  });
}
