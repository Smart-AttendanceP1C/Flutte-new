import 'package:flutter_test/flutter_test.dart';
import 'package:verishift_app/core/routing/app_router.dart';
import 'package:verishift_app/core/routing/app_routes.dart';
import 'package:verishift_app/features/instructor/data/instructor_models.dart';
import 'package:verishift_app/features/student/data/student_models.dart';

void main() {
  test('guard sends unauthenticated users to login', () {
    expect(
      AppRouter.guard(
          isAuthenticated: false, target: AppRoutes.studentScan),
      AppRoutes.login,
    );
    expect(
      AppRouter.guard(
          isAuthenticated: false,
          target: AppRoutes.instructorDashboard),
      AppRoutes.login,
    );
    expect(
      AppRouter.guard(isAuthenticated: true, target: AppRoutes.studentScan),
      AppRoutes.studentScan,
    );
    expect(
      AppRouter.guard(isAuthenticated: false, target: AppRoutes.login),
      AppRoutes.login,
    );
  });

  test('student attendance parses real backend shape', () {
    final a = StudentAttendance.fromJson({
      'attendance_event_id': 7,
      'session_id': 3,
      'scanned_at': '2026-09-01T09:00:00Z',
      'validation_status': 'accepted',
      'attendance_status': 'present',
      'rejection_reason': null,
      'section_id': 2,
      'section_code': 'SEC-01',
      'course_id': 1,
      'course_code': 'CS-402',
      'course_name': 'Deep Learning',
    });
    expect(a.eventId, 7);
    expect(a.attendanceStatus, 'present');
    expect(a.courseCode, 'CS-402');
  });

  test('risk student parses real backend shape incl. unavailable', () {
    final ok = RiskStudent.fromJson({
      'student_id': 5,
      'student_code': 'STU-1',
      'name': 'A B',
      'risk_probability': 0.82,
      'risk_percentage': 82.0,
      'risk_band': 'High',
      'is_flagged': true,
      'features': {'attendance_rate_to_date': 0.5},
    });
    expect(ok.riskBand, 'High');
    expect(ok.features?['attendance_rate_to_date'], 0.5);

    final missing = RiskStudent.fromJson({
      'student_id': 6,
      'student_code': 'STU-2',
      'name': 'C D',
      'risk_probability': null,
      'risk_percentage': null,
      'risk_band': 'unavailable',
      'is_flagged': false,
      'error': 'AI risk unavailable for this student',
    });
    expect(missing.riskBand, 'unavailable');
    expect(missing.riskPercentage, isNull);
  });

  test('correction request parses real backend shape', () {
    final r = CorrectionRequest.fromJson({
      'id': 11,
      'attendance_event_id': 7,
      'evidence': 'Medical Excuse — clinic note',
      'status': 'pending',
      'reviewer_id': null,
      'reason': null,
      'created_at': '2026-09-20T10:00:00Z',
      'course_code': 'MATH-310',
      'course_name': 'Discrete Mathematics',
      'scanned_at': '2026-09-20T08:00:00Z',
      'session_id': 3,
    });
    expect(r.id, 11);
    expect(r.status, 'pending');
  });
}
