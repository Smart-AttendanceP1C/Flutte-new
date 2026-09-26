import '../../../core/network/api_client.dart';
import '../../../core/network/api_parsing.dart';
import 'instructor_models.dart';

/// Instructor API service → real backend. No fake data.
class InstructorApi {
  final ApiClient api;
  InstructorApi(this.api);

  Future<StaffProfile> me() async {
    final d = await api.get('/api/v1/staff/me') as Map<String, dynamic>;
    return StaffProfile.fromJson(d);
  }

  Future<List<StaffSection>> mySections() async {
    final d = await api.get('/api/v1/staff/me/sections') as List;
    return d
        .map((e) => StaffSection.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<TimetableEntry>> myTimetable() async {
    final d = await api.get('/api/v1/staff/me/timetable') as List;
    return d
        .map((e) => TimetableEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<SectionStudent>> sectionStudents(int sectionId) async {
    final d =
        await api.get('/api/v1/sections/$sectionId/students') as List;
    return d
        .map((e) => SectionStudent.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<AttendanceSession> openSession(int timetableId) async {
    final d = await api.post('/api/v1/attendance/sessions',
        body: {'timetable_id': timetableId}) as Map<String, dynamic>;
    return AttendanceSession.fromJson(d);
  }

  Future<AttendanceSession> closeSession(int sessionId) async {
    final d = await api.patch('/api/v1/attendance/sessions/$sessionId/close')
        as Map<String, dynamic>;
    return AttendanceSession.fromJson(d);
  }

  Future<SessionQrToken> sessionQr(int sessionId) async {
    final d = await api.get('/api/v1/attendance/sessions/$sessionId/qr')
        as Map<String, dynamic>;
    return SessionQrToken.fromJson(d);
  }

  Future<({Map<String, dynamic> session, List<RosterEntry> roster})>
      roster(int sessionId) async {
    final d = await api.get('/api/v1/attendance/sessions/$sessionId/roster')
        as Map<String, dynamic>;
    final roster = ((d['roster'] as List?) ?? [])
        .map((e) => RosterEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return (
      session: Map<String, dynamic>.from(d['session'] as Map),
      roster: roster
    );
  }

  Future<Map<String, dynamic>> manualUpdate({
    required int sessionId,
    required int studentId,
    required String status,
    required String reason,
  }) async {
    final d = await api.patch(
      '/api/v1/attendance/sessions/$sessionId/students/$studentId',
      body: {'attendance_status': status, 'reason': reason},
    ) as Map<String, dynamic>;
    return d;
  }

  Future<({Map<String, dynamic> section, int weekNumber, List<RiskStudent> students})>
      sectionRisk(int sectionId) async {
    final d = await api.get('/api/v1/staff/me/sections/$sectionId/risk')
        as Map<String, dynamic>;
    final students = ((d['students'] as List?) ?? [])
        .map((e) => RiskStudent.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return (
      section: Map<String, dynamic>.from(d['section'] as Map),
      weekNumber: asIntOrNull(d['week_number']) ?? 1,
      students: students,
    );
  }

  Future<List<CorrectionQueueItem>> correctionQueue({String? status}) async {
    final d = await api.get('/api/v1/attendance/correction-requests',
        query: status == null ? null : {'status': status}) as List;
    return d
        .map((e) =>
            CorrectionQueueItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> reviewCorrection({
    required int requestId,
    required String status,
    required String reason,
  }) async {
    final d = await api.patch(
      '/api/v1/attendance/correction-requests/$requestId',
      body: {'status': status, 'reason': reason},
    ) as Map<String, dynamic>;
    return d;
  }

  Future<List<Map<String, dynamic>>> records({int? sectionId}) async {
    final d = await api.get('/api/v1/attendance/records',
        query: sectionId == null ? null : {'section_id': '$sectionId'}) as List;
    return d.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
