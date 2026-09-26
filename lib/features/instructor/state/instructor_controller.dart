import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../data/instructor_api.dart';
import '../data/instructor_models.dart';

/// Instructor bootstrap state: real profile + sections + timetable.
class InstructorController extends ChangeNotifier {
  final InstructorApi api;
  InstructorController(this.api);

  bool loading = false;
  String? error;
  StaffProfile? profile;
  List<StaffSection> sections = [];
  List<TimetableEntry> timetable = [];
  List<CorrectionQueueItem> pending = [];
  bool _loaded = false;

  Future<void> load({bool force = false}) async {
    if (loading || (_loaded && !force)) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        api.me(),
        api.mySections(),
        api.myTimetable(),
        api.correctionQueue(status: 'pending'),
      ]);
      profile = results[0] as StaffProfile;
      sections = results[1] as List<StaffSection>;
      timetable = results[2] as List<TimetableEntry>;
      pending = results[3] as List<CorrectionQueueItem>;
      _loaded = true;
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'no_connection';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);

  void reset() {
    profile = null;
    sections = [];
    timetable = [];
    pending = [];
    error = null;
    loading = false;
    _loaded = false;
    notifyListeners();
  }
}
