import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/logout_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/instructor/screens/correction_queue_screen.dart';
import '../../features/instructor/screens/generate_qr_screen.dart';
import '../../features/instructor/screens/instructor_dashboard_screen.dart';
import '../../features/instructor/screens/instructor_menu_screen.dart';
import '../../features/instructor/screens/instructor_shell.dart';
import '../../features/instructor/screens/manual_attendance_screen.dart';
import '../../features/instructor/screens/risk_report_screen.dart';
import '../../features/student/screens/attendance_history_screen.dart';
import '../../features/student/screens/correction_request_screen.dart';
import '../../features/student/screens/correction_submitted_screen.dart';
import '../../features/student/screens/scan_qr_screen.dart';
import '../../features/student/screens/session_closed_screen.dart';
import '../../features/student/screens/student_home_screen.dart';
import '../../features/student/screens/student_menu_screen.dart';
import '../../features/student/screens/student_pass_screen.dart';
import '../../features/student/screens/student_shell.dart';
import '../../features/support/screens/support_screen.dart';
import 'app_routes.dart';
import 'route_guards.dart';

/// Clean router. No telemetry, no welcome/ID, no location screens.
/// Unknown routes show a friendly 404 instead of crashing.
/// "/" is the real root: SplashScreen resolves auth → Login/Student/Instructor.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case AppRoutes.root:
        page = const SplashScreen();
      case AppRoutes.login:
        page = const LoginScreen();
      case AppRoutes.logout:
        page = const LogoutScreen();
      case AppRoutes.support:
        page = const SupportScreen();
      case AppRoutes.studentScan:
        page = const ScanQrScreen();
      case AppRoutes.studentHome:
        final tab = settings.arguments is int
            ? (settings.arguments! as int).clamp(0, 2)
            : 0;
        page = StudentShell(initialIndex: tab);
      case AppRoutes.studentHistory:
        page = const StudentShell(initialIndex: 1);
      case AppRoutes.studentMenu:
        page = const StudentShell(initialIndex: 2);
      case AppRoutes.studentPass:
        page = const StudentPassScreen();
      case AppRoutes.studentCorrection:
        page = const CorrectionRequestScreen();
      case AppRoutes.studentCorrectionSubmitted:
        page = const CorrectionSubmittedScreen();
      case AppRoutes.studentSessionClosed:
        page = const SessionClosedScreen();
      case AppRoutes.instructor:
        page = const InstructorShell(initialIndex: 0);
      case AppRoutes.instructorMenu:
        page = const InstructorShell(initialIndex: 3);
      case AppRoutes.instructorDashboard:
        page = const InstructorShell(initialIndex: 0);
      case AppRoutes.instructorGenerateQr:
        page = const InstructorShell(initialIndex: 1);
      case AppRoutes.instructorReports:
        page = const InstructorShell(initialIndex: 2);
      case AppRoutes.instructorManual:
        page = const ManualAttendanceScreen();
      case AppRoutes.instructorCorrections:
        page = const CorrectionQueueScreen();
      default:
        page = _UnknownRoute(name: settings.name);
    }
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  /// Auth + role guard: unauthenticated users are sent to login,
  /// wrong-role users are sent to their own home.
  /// Kept backward-compatible (boolean-only) for existing tests.
  static String guard({
    required bool isAuthenticated,
    required String target,
    String? role,
  }) {
    if (role == null) {
      return RouteGuards.guardSimple(
        isAuthenticated: isAuthenticated,
        target: target,
      );
    }
    return RouteGuards.guard(
      isAuthenticated: isAuthenticated,
      role: role,
      target: target,
    );
  }
}

/// Direct tab-less pages used by shells (avoids nested navigators).
class InstructorTabs {
  static const pages = <Widget>[
    InstructorDashboardScreen(),
    GenerateQrScreen(),
    RiskReportScreen(),
    InstructorMenuScreen(),
  ];
}

class StudentTabs {
  static const pages = <Widget>[
    StudentHomeScreen(),
    AttendanceHistoryScreen(),
    StudentMenuScreen(),
  ];
}

class _UnknownRoute extends StatelessWidget {
  final String? name;
  const _UnknownRoute({this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Text(context.tr('route_nf',
              {'v': name ?? context.tr('unknown')}))),
    );
  }
}
