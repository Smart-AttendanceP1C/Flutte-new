# UI → API Mapping (15 pages → real backend)

Rule: reference layout is frozen; real data is mapped INTO it. Where the
contract has no endpoint for a displayed block, the block keeps reference
content and is marked STATIC-REF below (never fabricated as backend data).

- P01 Sign In → `POST /api/v1/auth/login` (`AuthProvider.login` →
  `AuthRepositoryImpl` → `AuthRemoteDataSource` → `ApiClient`). Real JWT
  persisted, role from backend, routing by role. Loading/disabled/error states.
- P02 Welcome → no API (navigation only) → `/studentHome` (replace), `/qrScanner` (push).
- P03 Instructor Menu → `GET /api/v1/staff/me` (`StaffProvider.loadHeader`, name binding; fallback reference text only when logged out). Rows navigate; unsupported actions show honest “not available yet”.
- P04 Profile → session user (`AuthProvider.user`: name/id/email) + Theme/Language (`SettingsController`/`LocalStorage`, persisted, RTL). Stats cards STATIC-REF (no aggregate endpoint).
- P05 Check-In → identity from session user; Scan button → real P06 flow. Session card/metrics STATIC-REF (no active-session/aggregate endpoint).
- P06 Scanner → `POST /scan {token}` → `POST /check-in {scanTicket}` (`ScanProvider` → `ScanRepositoryImpl` → `ScanRemoteDataSource`); invalid/duplicate(409)/rate-limit(429)/401/403/network states; manual 6-digit code validated locally then same flow. Camera permission + lifecycle handled.
- P07 Correction receipt → STATIC-REF receipt (no submission form in refs). Layer ready: `CorrectionRepository` create/list/my/review + `CatalogRepository`; error/success mapping centralized.
- P08 Logs → `GET /api/v1/students/me/attendance` + `GET /api/v1/attendance/records` (`AttendanceProvider.loadMyAttendance`, loading/error/empty/loaded, month pager now functional, counts derived from records).
- P09 Session Closed → navigation only (stack cleared to single Home).
- P10 Reports/AI → `GET /sessions/{id}/roster` (`SessionProvider.loadRoster`, empty/loading/error/loaded, rows mapped to reference cards); Live Check → `GET /students/me/risk` (+features) with loading/error/retry (student-only; instructor gets real 403 state). Stats/chips derived from roster.
- P11 Telemetry → identity from session user; mesh/node content STATIC-REF device telemetry (no backend endpoint).
- P12 Dashboard → `GET /api/v1/staff/me` (+sections best-effort) header binding; pulse/monitoring aggregates STATIC-REF (no aggregate endpoint); roster cards STATIC-REF (no selected-section context; `GET sections/{id}/students` layer ready).
- P13 Generate QR → `POST /sessions {timetable_id}` → `GET /sessions/{id}/qr` (`SessionProvider.generate/refreshQr/close`); loading/ready/error states; no fake tokens.
- P14 Support → no API (static help content + honest unavailable-action messages).
- P15 Logout → `POST` none (no contract endpoint): clears token/session (`LocalStorage.clearSession`), `removeUntil(/,false)`; shows session user.

Cross-cutting: `ApiClient` (base URL, Bearer, status mapping incl. real `error.message` envelope, timeouts, safe `[API]` logging, `getBytes` for export); `failureMessage` prefers real backend messages for 401/403; role guards unconditional on backend role (`isInstructor/isAdmin`), student shell blocks instructor/admin; `guardRole` central.
