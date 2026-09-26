/// Tolerant JSON number parsing for the real backend.
///
/// The live Vercel API serializes integer IDs as STRINGS (e.g. `"id":"5"`,
/// `"course_id":"10"`) while older rows/specs used numbers. A strict
/// `(j['id'] as num).toInt()` cast throws a TypeError on strings, which
/// controllers then surfaced as generic `no_connection` — masking the real
/// cause. These helpers accept `num` or numeric `String` and stay
/// fail-fast (throwing FormatException) only when the value is truly absent
/// or non-numeric — never fake data.
int asInt(dynamic v, String field) {
  if (v is num) return v.toInt();
  if (v is String) {
    final parsed = int.tryParse(v.trim());
    if (parsed != null) return parsed;
  }
  throw FormatException('Invalid int field: $field (${v.runtimeType})');
}

int? asIntOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

double? asDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

bool asBool(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final t = v.trim().toLowerCase();
    if (t == 'true' || t == '1') return true;
    if (t == 'false' || t == '0') return false;
  }
  return fallback;
}
