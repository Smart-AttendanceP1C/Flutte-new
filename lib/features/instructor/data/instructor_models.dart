// Real backend models for the instructor side (shapes from server.js).
import '../../../core/network/api_parsing.dart';

class StaffProfile {
  final int id;
  final String name;
  final String email;
  final String role;
  final String staffCode;
  final String status;
  const StaffProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.staffCode,
    required this.status,
  });
  factory StaffProfile.fromJson(Map<String, dynamic> j) => StaffProfile(
        id: asInt(j['id'], 'id'),
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        role: (j['role'] ?? '').toString(),
        staffCode: (j['staff_code'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
      );
}

class StaffSection {
  final int id;
  final String sectionCode;
  final String semester;
  final String academicYear;
  final int courseId;
  final String courseCode;
  final String courseName;
  const StaffSection({
    required this.id,
    required this.sectionCode,
    required this.semester,
    required this.academicYear,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
  });
  factory StaffSection.fromJson(Map<String, dynamic> j) => StaffSection(
        id: asInt(j['id'], 'id'),
        sectionCode: (j['section_code'] ?? '').toString(),
        semester: (j['semester'] ?? '').toString(),
        academicYear: (j['academic_year'] ?? '').toString(),
        courseId: asInt(j['course_id'], 'course_id'),
        courseCode: (j['course_code'] ?? '').toString(),
        courseName: (j['course_name'] ?? '').toString(),
      );
}

class TimetableEntry {
  final int id;
  final int sectionId;
  final String sectionCode;
  final int courseId;
  final String courseCode;
  final String courseName;
  final String roomName;
  final String building;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  const TimetableEntry({
    required this.id,
    required this.sectionId,
    required this.sectionCode,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.roomName,
    required this.building,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
  factory TimetableEntry.fromJson(Map<String, dynamic> j) => TimetableEntry(
        id: asInt(j['id'], 'id'),
        sectionId: asInt(j['section_id'], 'section_id'),
        sectionCode: (j['section_code'] ?? '').toString(),
        courseId: asInt(j['course_id'], 'course_id'),
        courseCode: (j['course_code'] ?? '').toString(),
        courseName: (j['course_name'] ?? '').toString(),
        roomName: (j['room_name'] ?? '').toString(),
        building: (j['building'] ?? '').toString(),
        dayOfWeek: (j['day_of_week'] ?? '').toString(),
        startTime: (j['start_time'] ?? '').toString(),
        endTime: (j['end_time'] ?? '').toString(),
      );
}

class AttendanceSession {
  final int id;
  final int timetableId;
  final int openedBy;
  final String? startedAt;
  final String? endedAt;
  final String status;
  const AttendanceSession({
    required this.id,
    required this.timetableId,
    required this.openedBy,
    required this.startedAt,
    required this.endedAt,
    required this.status,
  });
  factory AttendanceSession.fromJson(Map<String, dynamic> j) =>
      AttendanceSession(
        id: asInt(j['id'], 'id'),
        timetableId: asInt(j['timetable_id'], 'timetable_id'),
        openedBy: asInt(j['opened_by'], 'opened_by'),
        startedAt: j['started_at']?.toString(),
        endedAt: j['ended_at']?.toString(),
        status: (j['status'] ?? '').toString(),
      );
}

class SessionQrToken {
  final String token;
  final int rotationSec;
  final String expiresAt;
  const SessionQrToken({
    required this.token,
    required this.rotationSec,
    required this.expiresAt,
  });
  factory SessionQrToken.fromJson(Map<String, dynamic> j) => SessionQrToken(
        token: (j['token'] ?? '').toString(),
        rotationSec: asIntOrNull(j['rotationSec']) ?? 10,
        expiresAt: (j['expiresAt'] ?? '').toString(),
      );
}

class RosterEntry {
  final int studentId;
  final String studentName;
  final String studentEmail;
  final String studentCode;
  final String attendanceStatus;
  final int? attendanceEventId;
  final String? scannedAt;
  const RosterEntry({
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.studentCode,
    required this.attendanceStatus,
    required this.attendanceEventId,
    required this.scannedAt,
  });
  factory RosterEntry.fromJson(Map<String, dynamic> j) => RosterEntry(
        studentId: asInt(j['student_id'], 'student_id'),
        studentName: (j['student_name'] ?? '').toString(),
        studentEmail: (j['student_email'] ?? '').toString(),
        studentCode: (j['student_code'] ?? '').toString(),
        attendanceStatus: (j['attendance_status'] ?? 'absent').toString(),
        attendanceEventId: asIntOrNull(j['attendance_event_id']),
        scannedAt: j['scanned_at']?.toString(),
      );
}

class SectionStudent {
  final int id;
  final String name;
  final String email;
  final String studentCode;
  const SectionStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.studentCode,
  });
  factory SectionStudent.fromJson(Map<String, dynamic> j) => SectionStudent(
        id: asInt(j['id'], 'id'),
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        studentCode: (j['student_code'] ?? '').toString(),
      );
}

class RiskStudent {
  final int studentId;
  final String studentCode;
  final String name;
  final double? riskProbability;
  final double? riskPercentage;
  final String riskBand;
  final bool isFlagged;
  final Map<String, dynamic>? features;
  final String? error;
  const RiskStudent({
    required this.studentId,
    required this.studentCode,
    required this.name,
    required this.riskProbability,
    required this.riskPercentage,
    required this.riskBand,
    required this.isFlagged,
    required this.features,
    required this.error,
  });
  factory RiskStudent.fromJson(Map<String, dynamic> j) => RiskStudent(
        studentId: asInt(j['student_id'], 'student_id'),
        studentCode: (j['student_code'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        riskProbability: asDoubleOrNull(j['risk_probability']),
        riskPercentage: asDoubleOrNull(j['risk_percentage']),
        riskBand: (j['risk_band'] ?? 'unavailable').toString(),
        isFlagged: asBool(j['is_flagged']),
        features: j['features'] is Map
            ? Map<String, dynamic>.from(j['features'])
            : null,
        error: j['error']?.toString(),
      );
}

class CorrectionQueueItem {
  final int id;
  final int attendanceEventId;
  final String evidence;
  final String status;
  final String studentName;
  final String studentCode;
  final String courseCode;
  final String courseName;
  final String sectionCode;
  final String? createdAt;
  const CorrectionQueueItem({
    required this.id,
    required this.attendanceEventId,
    required this.evidence,
    required this.status,
    required this.studentName,
    required this.studentCode,
    required this.courseCode,
    required this.courseName,
    required this.sectionCode,
    required this.createdAt,
  });
  factory CorrectionQueueItem.fromJson(Map<String, dynamic> j) =>
      CorrectionQueueItem(
        id: asInt(j['id'], 'id'),
        attendanceEventId: asInt(j['attendance_event_id'], 'attendance_event_id'),
        evidence: (j['evidence'] ?? '').toString(),
        status: (j['status'] ?? '').toString(),
        studentName: (j['student_name'] ?? '').toString(),
        studentCode: (j['student_code'] ?? '').toString(),
        courseCode: (j['course_code'] ?? '').toString(),
        courseName: (j['course_name'] ?? '').toString(),
        sectionCode: (j['section_code'] ?? '').toString(),
        createdAt: j['created_at']?.toString(),
      );
}
