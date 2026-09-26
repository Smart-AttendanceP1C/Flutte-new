# UI ↔ Backend Mapping — every screen to its REAL endpoint(s)

Conventions: `B` = Bearer JWT. Role letters: S=student, L=lecturer, T=ta, A=admin. All responses are the REAL `server.js` shapes. UI transforms real data into the reference layout; nothing is redesigned.

## Login (`/login`, unauthenticated)
↓ `POST /api/v1/auth/login` `{email, password}`
↓ 200 `{success:true, data:{access_token, user:{id,name,email,role}}}` (401 `INVALID_CREDENTIALS`, 403 `ACCOUNT_INACTIVE`, 400 `VALIDATION_ERROR` — all verified live at the contract level)
↓ UI stores `access_token` (secure session store, restored on launch), keeps `user{id,name,email,role}`
↓ routes by REAL role: `student` → `/student/scan`; `lecturer`/`ta` → `/instructor`; `admin`/`auditor` → login stays with "no mobile UI for this role" message (documented, no invented screens)
↓ fields show backend `message` verbatim on error; loading state blocks duplicates.

## Student Scan QR (`/student/scan`, S) — first post-login screen
Camera decodes a QR string → client sends ONLY that string, never invented tokens:
↓ `POST /api/v1/attendance/scan` (B, S) `{token}` → 200 `{success:true, data:{scanTicket, sessionId, expiresInSec:30}}`
↓ `POST /api/v1/attendance/check-in` (B, S) `{scanTicket}` → 201 `{success:true, data:{attendance}}`
↓ UI: `SEARCHING` → `QR FOUND` → Confirm → success navigates to `/student/session-closed` with the real result; backend errors rendered verbatim: `INVALID_QR` (expired/version-mismatch), `SESSION_NOT_OPEN`, `NOT_ENROLLED`, `DUPLICATE_ATTENDANCE`, `RATE_LIMIT_EXCEEDED` (429), `INVALID_SCAN_TICKET`.
↓ Header `Verified ID` line uses `GET /students/me` `{id,name,email,student_code}`.

## Student Home (`/student/home`, S)
↓ `GET /api/v1/students/me` (B, S) → `{id,name,email,student_code,status,...}` → profile card (name, ID).
↓ `GET /api/v1/students/me/sections` (B, S) → `[{section_id,section_code,course_id,course_code,course_name,staff_id,staff_name,...}]` → Active Session card (first enrolled section: `course_code: course_name`, `staff_name`; room/time via `GET /timetable` match on `section_id` where available, else section line only — no invented room/time).
↓ `GET /api/v1/students/me/attendance` (B, S) → `[{attendance_event_id,session_id,scanned_at,validation_status,attendance_status,...}]` → metrics computed client-side: rate = present+late / total, Attended count, Absences count, Late count; ring + buffer bar reflect these real numbers (empty → zero-state, never fakes).
↓ `Scan QR Code to Check In` → `/student/scan`; `View Full Analytics` → `/student/history`.

## Student History / Logs (`/student/history`, S)
↓ `GET /api/v1/attendance/records` (B, S; student scope enforced server-side) → `{data:[{attendance_event_id,session_id,student_id,student_name,course_id,course_code,course_name,section_id,section_code,lecturer_id,lecturer_name,session_started_at,session_ended_at,scanned_at,validation_status,attendance_status,rejection_reason}], filters}` → session cards (punch = `scanned_at`, course chip = `course_code`, title = `course_name`, room/staff = `section_code • lecturer_name`, status pill = `attendance_status`, footer = `validation_status/rejection_reason`).
↓ `GET /api/v1/courses` → course filter chips (real list; selection filters client-side / via `course_id` query).
↓ `GET /api/v1/students/me/sections` → section labels for chips; tiles (Rate/Present/Approved/Late) computed from the same real records.
↓ View Reason/Audit → `/student/correction-submitted` for the matching real `attendance_event_id`.

## Correction Request form (`/student/correction`, S) → Submitted receipt (`/student/correction-submitted`, S)
Form `attendance_event_id` picker ← REAL ids from `GET /students/me/attendance` (or `GET /attendance/records`); `evidence` text = reason + details:
↓ `POST /api/v1/attendance/correction-requests` (B, S) `{attendance_event_id, evidence}` → 201 `{id,attendance_event_id,evidence,status,reviewer_id,reason,created_at,updated_at}` (404 unknown event, 403 чужой event, 409 pending-exists — all surfaced).
↓ `GET /api/v1/attendance/correction-requests/me` (B, S) → `{correction_requests:[{id,attendance_event_id,evidence,status,reviewer_id,reason,created_at,updated_at,attendance_status,scanned_at,session_id,session_started_at,section_id,section_code,course_id,course_code,course_name}]}` → receipt card (ticket `#REQ-{id}`, course/faculty, original `attendance_status`/`scanned_at` vs requested, `evidence`, `status` pipeline step, `created_at`).
↓ `GET /api/v1/attendance/records/export?format=csv|pdf` (B) → REAL file bytes download (replaces any fake slip download).
↓ Menu `1 Pending` badge = real count of `status==pending` in the `me` list.

## Session Closed (`/student/session-closed`, S)
No API call. Displays the REAL `POST /check-in` 201 outcome carried from the scanner (session id + `scanned_at`). Buttons → `/student/home`, `/student/history`.

## Student Menu (`/student/menu`, S)
↓ `GET /api/v1/students/me` → header (name, `student_code`); `GET /students/me/attendance` → stats (rate/attended); `GET /correction-requests/me` → pending badge. Rows navigate to the real screens above. Student Pass row → `/student/pass` (profile-derived QR of the student's own code — display-only, documented as NOT a check-in token).

## Instructor Menu (`/instructor/menu`, L/T)
↓ `GET /api/v1/staff/me` (B, L/T) → `{id,name,email,role,staff_code,status}` → profile header (real name/role/staff_code).
↓ `GET /api/v1/staff/me/sections` → Courses & Sections subtitle count (real `length`).
↓ `GET /api/v1/attendance/correction-requests?status=pending` → Correction Requests badge (real `length`).
↓ Rows → dashboard / generate-qr / reports(review queue) / support / logout. Stats row shows real sections/pending counts; headcount/attendance tiles are computed on the dashboard from real roster/records (menu shows the same real numbers, no invented 142/94.8%).

## Instructor Dashboard (`/instructor/dashboard`, L/T)
↓ `GET /staff/me` → header; `GET /staff/me/sections` → sections list; `GET /staff/me/timetable` → monitoring rows (real `course_code`, `room_name`/`building`, `day_of_week`, `start_time–end_time`, `section_code`).
↓ Per open session: `GET /attendance/sessions/:sessionId/roster` → `session{...}` + `roster[]` → Checked-In `present/late` count / total enrolled, `attendance_status` breakdown; monitoring card shows these real counts.
↓ `GET /attendance/correction-requests?status=pending` → Corrections card + `View REQ-{id}` → review queue.
↓ `GET /attendance/records` (lecturer scope) → Today's Pulse aggregates (present/total/flagged) computed client-side over MY sections only (documented scope difference vs reference university-wide numbers).
↓ Add Student/Faculty: NO backend support for lecturer (admin-only CSV imports) → buttons show the honest scoped message; roster edit/delete route into the real manual-update flow (open session required).

## Generate QR (`/instructor/generate-qr`, L/T)
↓ `GET /staff/me/timetable` → Active-Course/timetable picker (real `timetable_id`).
↓ `POST /api/v1/attendance/sessions` `{timetable_id}` → 201 session (errors: `SESSION_OUTSIDE_SCHEDULE`, `SESSION_ALREADY_OPEN` (409 → offer to reuse/close), `TIMETABLE_NOT_FOUND`, 403).
↓ `GET /api/v1/attendance/sessions/:sessionId/qr` → 200 `{token, rotationSec:10, expiresAt}` → `qr_flutter` renders the REAL token; auto-refresh every 10s; `expiresAt` countdown is the real value.
↓ Log tab: `GET /attendance/sessions/:sessionId/roster` → real check-in list.
↓ Close: `PATCH /attendance/sessions/:sessionId/close` → 200 closed session (403 non-opener, 409 not-open surfaced).

## Reports / AI Risk (`/instructor/reports`, L/T)
↓ `GET /staff/me/sections` → section picker (real).
↓ `GET /api/v1/staff/me/sections/:sectionId/risk` → `{section, week_number, students_count, students:[{student_id,student_code,name,risk_probability,risk_percentage,risk_band,is_flagged,features:{attendance_rate_to_date,trend_last_3,rejected_last_2,consecutive_absences,course_load}}]}` → rows (name/code, bar = `risk_percentage` or `attendance_rate_to_date`, chip = backend `risk_band` verbatim, meta = real feature values); `risk_band:"unavailable"` rows render as Unavailable (never faked).
↓ Context: `GET /sections/:sectionId/students` (roster) + `GET /attendance/records?section_id=` (history). Review actions → correction-review queue + manual-update flow (real endpoints only).

## Support (`/support`, shared) — NO backend
No support endpoints exist in `server.js`. FAQ/contact/feedback are UI-only with honest messaging. Exception: `Account settings` row → real `PATCH /students/me` (students: name/password) with current/new-password validation per backend (`WEAK_PASSWORD`, `CURRENT_PASSWORD_REQUIRED`, `INVALID_CURRENT_PASSWORD`).

## Logout (`/logout`, shared) — NO backend
No logout endpoint (stateless JWT). `Yes, Log Out` clears the session store (token + user) and `pushNamedAndRemoveUntil(/login)`; route guard then blocks all protected routes.
