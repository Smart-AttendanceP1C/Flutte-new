# UI 15-Screen Inventory — `flutter P1C_UI_Images/` (single source of truth)

App display name: **Smart Attendance**. No redesign; API data is mapped into
these exact layouts.

| # | Reference file | Screen | Route | Role | Parent → Children |
|---|---|---|---|---|---|
| 01 | `1-Sin in.jpeg` | Sign In | `/` (LoginScreen) | shared | — → Demo removed; `/welcome` or `/lecturerDashboard` by backend role |
| 02 | `2-welcome.jpeg` | Welcome / Express Check-In | `/welcome` (WelcomeCheckinScreen) | student | Login → StudentHome (`/studentHome`), QR Scanner (`/qrScanner`); Back → Login (replaced, so exit) |
| 03 | `3-instructor menu.jpeg` | Instructor Menu (no bottom nav) | `/instructorMenu` (InstructorMenuScreen) | instructor | Reports/Settings → Generate QR (`/generateQr`), Dashboard (`/lecturerDashboard`), AI (`/aiRisk`), Support (`/support`), Logout (`/logout`); Back → previous |
| 04 | `4-student menu.jpeg` | Profile / Student Menu | `/studentMenu` (ProfileScreen) | shared (role-aware) | Shell tab or standalone → Home/Scanner/Logs/Telemetry/Support/Theme/Language/Logout; Back → previous |
| 05 | `5-student home.jpeg` | Student Home / Check-In tab | `/studentHome` idx0 (StudentHomeShell + CheckInTab) | student | Login/Welcome → Scan (`/qrScanner`); tabs Logs/Telemetry/Profile; Back → exit (root) |
| 06 | `6-scanner.jpeg` | Room QR Scanner | `/qrScanner` (ScanScreen) | student | CheckIn/Welcome → Session Closed (`/sessionClosed`) on success; manual code sheet; bottom tabs → shell; Back → previous |
| 07 | `7-correct request.jpeg` | Correction Submitted receipt | `/correctionSubmitted` (CorrectionSubmittedScreen) | student | Profile → Logs (`/studentHome` idx1), Support (`/support`); Back → previous |
| 08 | `8-student dashboard.jpeg` | Attendance Logs / History | `/studentHome` idx1 (LogsTab) | student | Shell tab; month pager; Back → n/a (tab) |
| 09 | `9-closed.jpeg` | Session Closed / Thank You | `/sessionClosed` (SessionClosedScreen) | student | Scan success → Home (`/studentHome`, stack cleared); Back → Home |
| 10 | `10-AI.png` | Attendance Report / AI Risk | `/aiRisk` (AiRiskScreen) | instructor | Dashboard/Menu → Generate QR, Dashboard, Menu; Live Check sheet (`GET students/me/risk`); Back → previous |
| 11 | `11-telemetry.jpeg` | Telemetry | `/studentHome` idx2 (TelemetryTab) | student | Shell tab; device-side telemetry (no backend endpoint); Back → n/a (tab) |
| 12 | `12-instrucror dashboard.jpeg` | Lecturer Dashboard / Admin Console | `/lecturerDashboard` (+`/adminConsole` alias, AdminConsoleScreen) | instructor | Login → QR (`/generateQr`), Reports (`/aiRisk`), Profile (`/studentMenu`); Back → exit (root) |
| 13 | `13-generate scanner.jpeg` | Session QR Code | `/generateQr` (GenerateQrScreen) | instructor | Dashboard/Menu → Generate action (`POST sessions` + `GET qr`); bottom Home/QR/Reports/Profile; Back → previous |
| 14 | `14-support.jpeg` | Support | `/support` (SupportScreen) | shared | Any menu → Back → opener |
| 15 | `15-log out.jpeg` | Log Out confirm | `/logout` (LogoutScreen) | shared | Any → confirm clears token/session → Login (`removeUntil(/,false)`); Back after logout cannot reach auth screens |

Buttons/navigation actions per screen are implemented with normal `pushNamed`
(Back returns) except Login/Logout/session-close root transitions
(`pushReplacement` / `removeUntil`). Bottom tabs on instructor use `pushNamed`
with same-tab guard (no duplicates, Back returns).
