/// Centralized route guards — single source of truth for auth + role rules.
///
/// UI → Provider(AuthState) → RouteGuards → AppRouter → Screen.
/// No screen invents its own guard. No demo roles.
library;

import 'app_routes.dart';

/// Backend roles (verbatim from POST /api/v1/auth/login `user.role`).
abstract final class AppRoles {
  static const student = 'student';
  static const lecturer = 'lecturer';
  static const ta = 'ta';
  static const admin = 'admin';
  static const auditor = 'auditor';

  static bool isStudent(String? role) => role == student;
  static bool isInstructor(String? role) =>
      role == lecturer || role == ta;
  static bool isStaff(String? role) =>
      role == lecturer || role == ta || role == admin;
}

class RouteGuards {
  static const studentRoutes = {
    AppRoutes.studentScan,
    AppRoutes.studentHome,
    AppRoutes.studentHistory,
    AppRoutes.studentMenu,
    AppRoutes.studentPass,
    AppRoutes.studentCorrection,
    AppRoutes.studentCorrectionSubmitted,
    AppRoutes.studentSessionClosed,
  };

  static const instructorRoutes = {
    AppRoutes.instructor,
    AppRoutes.instructorMenu,
    AppRoutes.instructorDashboard,
    AppRoutes.instructorGenerateQr,
    AppRoutes.instructorReports,
    AppRoutes.instructorManual,
    AppRoutes.instructorCorrections,
  };

  static const protectedRoutes = {
    AppRoutes.logout,
    AppRoutes.support,
    ...studentRoutes,
    ...instructorRoutes,
  };

  /// Resolve the role home. Returns null when the role has no mobile UI
  /// (admin/auditor/unknown) — caller shows an honest message instead of
  /// inventing a screen.
  static String? homeForRole(String? role) {
    if (AppRoles.isStudent(role)) return AppRoutes.studentHome;
    if (AppRoles.isInstructor(role) || AppRoles.isStaff(role)) {
      // Staff (lecturer/ta/admin with teaching scope) lands on the
      // instructor shell (dashboard tab). Menu is one tap away.
      return AppRoutes.instructor;
    }
    return null;
  }

  /// Auth + role guard. Returns the route that should actually be shown.
  static String guard({
    required bool isAuthenticated,
    required String? role,
    required String target,
  }) {
    // Root is always allowed — SplashScreen resolves it.
    if (target == AppRoutes.root) return target;
    if (target == AppRoutes.login) {
      // Authenticated users hitting /login are bounced to their home.
      // Done in LoginScreen post-frame too; guard keeps deep-links sane.
      if (isAuthenticated) return homeForRole(role) ?? target;
      return target;
    }
    if (protectedRoutes.contains(target) && !isAuthenticated) {
      return AppRoutes.login;
    }
    if (!isAuthenticated) return target;
    // Role protection: students cannot open instructor routes and vice versa.
    // Staff (lecturer/ta/admin) may open instructor routes; students may
    // open student routes. Admin/auditor without teaching scope keep
    // access to shared routes (logout/support) only.
    if (studentRoutes.contains(target) &&
        !AppRoles.isStudent(role) &&
        // Allow staff to view? No — strict separation per spec.
        true) {
      if (!AppRoles.isStudent(role)) {
        final home = homeForRole(role);
        if (home != null && home != target) return home;
        return AppRoutes.login;
      }
    }
    if (instructorRoutes.contains(target) &&
        !AppRoles.isInstructor(role) &&
        !AppRoles.isStaff(role)) {
      final home = homeForRole(role);
      if (home != null && home != target) return home;
      return AppRoutes.login;
    }
    return target;
  }

  /// Legacy boolean-only guard (kept for unit tests / old callers).
  static String guardSimple({
    required bool isAuthenticated,
    required String target,
  }) {
    if (target == AppRoutes.login) return target;
    if (target == AppRoutes.root) return target;
    if (protectedRoutes.contains(target) && !isAuthenticated) {
      return AppRoutes.login;
    }
    return target;
  }
}
