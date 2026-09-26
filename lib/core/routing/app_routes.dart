/// Single source of truth for every route.
/// Screens navigate with `Navigator.pushNamed(context, AppRoutes.xxx)`.
abstract final class AppRoutes {
  /// Application root — resolves auth state and redirects to the correct
  /// real destination (Login OR Student Home OR Instructor Home).
  /// This fixes the historic "Route not found: /" error.
  static const root = '/';
  static const login = '/login';
  static const logout = '/logout';
  static const support = '/support';

  // Student
  static const studentScan = '/student/scan';
  static const studentHome = '/student/home';
  static const studentHistory = '/student/history';
  static const studentMenu = '/student/menu';
  static const studentPass = '/student/pass';
  static const studentCorrection = '/student/correction';
  static const studentCorrectionSubmitted = '/student/correction-submitted';
  static const studentSessionClosed = '/student/session-closed';

  // Instructor
  static const instructor = '/instructor';
  static const instructorMenu = '/instructor/menu';
  static const instructorDashboard = '/instructor/dashboard';
  static const instructorGenerateQr = '/instructor/generate-qr';
  static const instructorReports = '/instructor/reports';
  static const instructorManual = '/instructor/manual';
  static const instructorCorrections = '/instructor/corrections';
}
