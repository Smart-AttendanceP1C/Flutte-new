# UI Inventory — source: `flutter P1C_UI_Images/flutter P1C/` (15 images, inspected)

App display name: **Smart Attendance**. Global removals (override references): NO telemetry, NO location, NO ID-after-login. Student `Login → Scan QR` directly.

## 01 `1-Sin in.jpeg` — Sign In (Login, unauthenticated, route `/login`)
Components: navy page, BUA lockup, `Sign in` + subtitle, `YOUR EMAIL` + `PASSWORD` white fields, eye toggle, blue `Sign in` button.
Buttons/navigation/fields: email field, password field + visibility, submit → student `/student/scan`, lecturer/TA → `/instructor`; validation errors inline; loading disables button.
Required backend: `POST /api/v1/auth/login` → `access_token` + `user.role`.

## 02 `2-welcome.jpeg` — Welcome / Express Check-In (REMOVED, no route)
Was a Student-ID entry screen. Deleted per requirements (no ID route/form/validation). Replaced by direct `Login → Scan QR`.
Required backend: none (removed).

## 03 `3-instructor menu.jpeg` — Instructor Menu (role lecturer/ta, route `/instructor/menu`)
Components: header (brand + `FACULTY` + close), profile card TM/FAC-4819, stats (3/4, 142, 94.8%), `ATTENDANCE TOOLS` QR-Generate card (`Launch`), rows: Lecturer Dashboard (LIVE), Manual Attendance Correction, Courses & Sections (4 Active), Correction Requests (3 Pending), Admin Management, Support & Help Desk, `Close Dashboard`, `Log Out`.
Buttons/navigation: QR Generate → `/instructor/generate-qr`; Lecturer Dashboard → `/instructor/dashboard`; Manual Correction → reports/manual flow; Courses → dashboard sections; Correction Requests → review queue; Admin Management → dashboard (scoped; admin-only imports NOT in UI); Support → `/support`; Close → back; Log Out → `/logout`.
Required backend: `GET /staff/me` (profile), `GET /staff/me/sections`, `GET /staff/me/timetable`, `GET /attendance/correction-requests?status=pending` (badge count), roster/risk for stats.

## 04 `4-student menu.jpeg` — Student Menu / Profile tab (role student, route `/student/menu`)
Components: header (brand + `STUDENT` + close), profile card SM/2023000000, stats (96.4%, 28/30, 2 Active), `ATTENDANCE ACTIONS`: Student Home, QR Scanner + `SCAN NOW`, QR Display / Student Pass; `RECORDS & COMPLIANCE`: Attendance History, Correction Request + `1 Pending`; `ACCOUNT & SUPPORT`: Campus IT & Support; `Close Menu / Return to App`; `Log Out`. Telemetry row DELETED.
Buttons/navigation: each row → home/scan/pass/history/correction/support; Close → `/student/home`; Log Out → `/logout`.
Required backend: `GET /students/me` (profile), `GET /students/me/attendance` (rate/classes), `GET /attendance/correction-requests/me` (pending badge).

## 05 `5-student home.jpeg` — Student Home / Check In tab (role student, route `/student/home`)
Components: brand header + session pill; profile card SM; Active Session card (CS-402 Deep Learning, Room 304, Dr. Harrison, status tiles, `07m 48s` countdown bar, navy `Scan QR Code to Check In →`); Term Attendance Metrics (94.2%, ring, Absence Buffer, Attended/Absences/Late); Campus Services trio.
Buttons/navigation: Scan button → `/student/scan`; `View Full Analytics` → `/student/history`; services → scan/history/correction; bottom nav Check In/Logs/Profile.
Required backend: `GET /students/me`, `GET /students/me/sections` (enrolled sections → active session card), `GET /students/me/attendance` (metrics computed client-side). Countdown bar: session `started_at` display only (no invented expiry).

## 06 `6-scanner.jpeg` — Room Attendance QR Scanner (role student, route `/student/scan`, FIRST post-login screen)
Components: header + `Verified ID`; title; dark viewport (status pills, corners, `SEARCHING DYNAMIC QR`, room bar + `Simulate Scan`); `Confirm Instant QR Attendance →` sheet.
Buttons/navigation/fields: live camera via `mobile_scanner`; `Simulate Scan` fills scanned-token state ONLY from a real camera decode (no pasted/invented tokens accepted); Confirm → `POST /attendance/scan` (token) → `POST /attendance/check-in` (scanTicket) → `/student/session-closed`; errors shown verbatim; back → `/student/home`.
Required backend: `POST /api/v1/attendance/scan` + `POST /api/v1/attendance/check-in`. No fake success.

## 07 `7-correct request.jpeg` — Correction Request Submitted (role student, route `/student/correction-submitted`; form at `/student/correction`)
Components: ledger header + STU chip; `LOGGED` badge; title; MATH-310 description; Tx Ref/Hash bar (real ticket id); receipt card (course/faculty, original scan vs requested status, stated reason, attachment row, proof); Audit Pipeline (3 steps, ETA); `View in Attendance Logs`; `Download Request Slip (PDF/CSV)`; support link.
Buttons/navigation: View logs → `/student/history`; Download → REAL `GET /attendance/records/export?format=csv|pdf` file download (no fake file); back → correction form.
Required backend: `POST /attendance/correction-requests` (create) + `GET /attendance/correction-requests/me` (receipt). Form requires a REAL `attendance_event_id` from history/`me` list; `evidence` = reason+details text.

## 08 `8-student dashboard.jpeg` — Attendance History / Logs (role student, route `/student/history`)
Components: ledger header + ID chip; name + Senior Y4; `Filter`; month card (October 2024, Wk 8 of 14); Rate/Present/Approved/Late tiles; course chips; status tabs + updated label; day groups (Today/Yesterday/Thu Oct 17); session cards (punch block, course chip, title, room, status pill, footer meta + View links).
Buttons/navigation/fields: Filter sheet; course chips filter; View Reason/Audit/Attestation → correction receipt; bottom nav.
Required backend: canonical `GET /attendance/records` (student scope) with `GET /students/me/attendance` + `GET /courses` + `GET /students/me/sections` for filters/labels. Metrics computed client-side from real records.

## 09 `9-closed.jpeg` — Session Closed / Thank You (role student, route `/student/session-closed`)
Components: brand header; `Attendance Attested` + `Session Closed`; ring + `Synced`; title; description; `Return to Home →`; `View Full History / Logs`.
Buttons/navigation: Return → `/student/home`; View history → `/student/history`; back → home. No API call (post-check-in receipt of the real `POST /check-in` result passed from scanner).
Required backend: none directly (displays the confirmed real check-in outcome).

## 10 `10-AI.png` — Attendance Risk / Reports (role lecturer/ta, route `/instructor/reports`; low-res source)
Components: risk header + totals; filter chips (All/Critical/Medium/Low); student rows (initials, name, attendance bar, Low/Medium/High/Very High chip, absences meta, Notify/Review/Send-to-Advisor actions); bottom actions.
Buttons/navigation/fields: section picker (real `GET /staff/me/sections`); row tap → roster/manual-correction context; actions surface real status/errors (no invented notify/advisor endpoints).
Required backend: `GET /staff/me/sections/:sectionId/risk` (real; per-student `unavailable` shown as-is) + `GET /sections/:sectionId/students` + `GET /attendance/records` for context.

## 11 `11-telemetry.jpeg` — Telemetry (REMOVED, no route/tab/widgets/providers/models/services/data)
Deleted per requirements. Student bottom nav is 3 items (Check In/Logs/Profile). No placeholder/dead route.
Required backend: none (no such backend feature exists either).

## 12 `12-instrucror dashboard.jpeg` — Instructor Dashboard / Admin Console (role lecturer/ta, route `/instructor/dashboard`)
Components: brand + `ADMIN CONSOLE`; `System Live` + clock; TM profile; `Today's Pulse` + `Auto-refresh 5s` (TOTAL PRESENT, ACTIVE HALLS, FLAGGED, CORRECTIONS + `View REQ-9042`); Active Lecture Monitoring (CS-402 128/135, MATH-310 86/90, salt/expiry, accuracy); Access & Records (Add Student/Faculty, All/Students/Faculty chips, search/sort, roster rows LZ/KA/SA with edit/delete + Permissions/Biometrics links).
Buttons/navigation: `View REQ-9042` → review queue; Add buttons → NOT backend-supported for lecturer (admin-only CSV imports) → honest "requires admin" message, no fake creation; roster edit/delete → manual-attendance update flow where session-open, else honest message; filters/search UI-only over real roster.
Required backend: `GET /staff/me`, `GET /staff/me/sections`, `GET /staff/me/timetable`, `GET /attendance/sessions/:sessionId/roster`, `GET /attendance/correction-requests?status=pending`, `GET /attendance/records`. Pulse/monitoring numbers are computed from these real payloads (scoped to my sections), never university-wide fakes.

## 13 `13-generate scanner.jpeg` — Session QR Code / Generate QR (role lecturer/ta, route `/instructor/generate-qr`)
Components: sky header (clock, `Instructor Portal / Smart Attendance`, person icon, Active Course card + Live); `Generate QR | Log (0)` tabs; white card (`Instructor Access Only`, `Session QR Code`, subtitle, QR placeholder ↔ real `qr_flutter` image, `QR expires after 60 seconds`); bottom `Generate QR Code` button.
Buttons/navigation/fields: course/timetable picker (real); Generate → `POST /attendance/sessions` (open) then `GET /sessions/:id/qr` (token, 10s rotation, auto-refresh); Log tab → real roster list (`GET /roster`); Close session action (`PATCH /close`); bottom instructor nav.
Required backend: `POST /attendance/sessions` + `GET /attendance/sessions/:sessionId/qr` + `GET /attendance/sessions/:sessionId/roster` + `PATCH /attendance/sessions/:sessionId/close`.

## 14 `14-support.jpeg` — Support (shared, route `/support`)
Components: back + `Support` + info; grabber; `How can we help?`; FAQ card (mark attendance, reports, account settings); Direct Contact (Email/Call cards); school-ID info bar; `Send Feedback`; version line.
Buttons/navigation: back pops; FAQ expands (UI-only); Email/Call/Feedback → honest UI-only message (NO support backend exists; documented, no fake ticket API).
Required backend: none (no support endpoints in `server.js`). Account-settings row deep-links to real `PATCH /students/me` (name/password) for students.

## 15 `15-log out.jpeg` — Log Out confirm (shared, route `/logout`)
Components: brand + `LIVE`; lock icon; `Log Out of Smart Attendance?`; user row; session/shift tiles; security info card (neutral wording); Remember-ID switch (UI-only); `Yes, Log Out` + `Stay Logged In`; version line.
Buttons/navigation: Yes → clear token/session + `pushNamedAndRemoveUntil(/login)`; guarded routes unreachable after logout; Stay/back pops.
Required backend: none (no logout endpoint; stateless JWT discarded client-side + session store cleared).
