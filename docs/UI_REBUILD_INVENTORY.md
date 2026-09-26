# UI Rebuild Inventory — Phase 1 (Source of Truth: `flutter P1C_UI_Images/flutter P1C/`)

> 15 reference images inspected. This document is the build checklist for the clean rebuild.
> Global rules for Phase 1: NO telemetry, NO location, NO ID-after-login, NO API. Student `Login → Scan QR` directly.
> App display name: **Smart Attendance**.

---

## PAGE 01 — `1-Sin in.jpeg`
- **Screen name:** Sign In (Login)
- **Role:** Unauthenticated (shared)
- **Route:** `/login` (initial route)
- **Navigation:** Sign in → Student: `/student/scan` · Instructor: `/instructor` · Back: none (root) · No ID screen after login
- **Visible components:**
  - Dark navy page `#0A1445`, dotted globe wash top-left
  - BUA lockup: dotted globe + `BUA` (white, 64, w900) + `BADR UNIVERSITY IN ASSIUT` (mono 10) + `جامعة بدر بأسيوط`
  - `Sign in` (serif 34 white, centered) + `Enter your credentials to continue` (15, `#8EA2D8`)
  - Labels `YOUR EMAIL` / `PASSWORD` (mono 13, `#8EA2D8`, ls 1.2)
  - White fields (radius 10, h ~58): hint `e.g. Ahmed Al-Rashidi@bua.edu.eg`, password `••••••••` + eye toggle
  - Blue button `Sign in` (`#2456E6`, radius 10, h 58, serif 18)
  - Password visibility toggle works; basic email/password validation; loading state disables button

## PAGE 02 — `2-welcome.jpeg` — **REMOVED FROM FLOW (intentional)**
- **Screen name:** Welcome / Express Check-In (Student ID entry)
- **Role:** Was student post-login
- **Route:** NONE — deleted. No `/welcome`, no ID route, no ID form, no ID validation screen
- **Reason:** Requirement §3/§4: no ID page after login. Student goes `Login → Scan QR` directly
- **Reference components (for record only):** `Smart Attendance` header + `Active` pill, `EXPRESS CHECK-IN` chip, `Welcome back` serif, description, `Student ID` card with `2023000000` + `Match` pill, `Clock In with Student ID →` (blue pill), `Scan your QR Code` (outline), time footer `10:56:37 AM / UTC-5 Shift #4`, `Enterprise Identity Verification Protocol 4.2`
- **Replacement:** post-login student lands on PAGE 06 Scan QR directly

## PAGE 03 — `3-instructor menu.jpeg`
- **Screen name:** Instructor Menu
- **Role:** Instructor
- **Route:** `/instructor/menu` (also a tab in instructor shell)
- **Navigation:** Back/Close → `/instructor` (dashboard shell). Log Out → `/logout`. Each row navigates (no dead buttons — see mapping)
- **Visible components:**
  - Header: fingerprint icon, `VeriShift`→ rebranded `Smart Attendance`, `FACULTY` chip, `×` close
  - Profile card: `TM` avatar (`#1A3A8A`), `Dr. Tarek Mansour`, `Faculty of Computer Science & Eng.`, `ID: FAC-4819 • Hall 302 Active`, `⋮`
  - Stat trio: `TODAY SESSIONS 3/4`, `STUDENTS LOGGED 142`, `AVG ATTENDANCE 94.8%`
  - `ATTENDANCE TOOLS` + `BEACON LIVE` label
  - `QR Generate` navy card (rotating token, `Token rotation: 15s`, `Launch →`) → `/instructor/generate-qr`
  - Rows: `Lecturer Dashboard` (LIVE) → `/instructor/dashboard`; `Manual Attendance Correction` → `/instructor/reports`; `Courses & Sections (4 Active)` → `/instructor/dashboard`; `Correction Requests (3 Pending)` → `/instructor/reports`; `Admin Management` → `/instructor/dashboard`; `Support & Help Desk` → `/support`
  - `← Close Dashboard` (outline) → back; `Log Out` (red outline) → `/logout`
  - Footer mono: version line (rebranded, no geofence/beacon wording)
- **Rebrand note:** header title uses `Smart Attendance`; telemetry/beacon/geofence wording removed or neutralised in rebuild

## PAGE 04 — `4-student menu.jpeg`
- **Screen name:** Student Menu (Profile tab)
- **Role:** Student
- **Route:** `/student/menu` (Profile tab of student shell)
- **Navigation:** `Close Menu / Return to App` → back to `/student/home`; `Log Out` → `/logout`; each row navigates
- **Visible components:**
  - Header: fingerprint, `Smart Attendance`, `STUDENT` chip, `×`
  - Profile card (navy top border): avatar photo placeholder (initials `SM`), `Salma Mahmoud`, `Computer Science & Engineering`, `ID: 2023000000` chip + `Hall 302 Connected` green chip (rebuilt without location wording: `Session Active`)
  - Stats: `ATTENDANCE RATE 96.4% Optimal`, `CLASSES ATTENDED 28/30 Term 1`, `DISPUTES RESOLVED 2 Active In Review`
  - `ATTENDANCE ACTIONS` + `Real-Time Core`: `Student Home` → `/student/home`; `QR Scanner SCAN NOW →` (highlighted) → `/student/scan`; `QR Display / Student Pass` → `/student/pass`
  - `RECORDS & COMPLIANCE`: `Attendance History` → `/student/history`; `Correction Request (1 Pending)` → `/student/correction`
  - `ACCOUNT & SUPPORT` + `Online`: `Campus IT & Support` → `/support` (**Telemetry row DELETED**, no placeholder)
  - `← Close Menu / Return to App` (navy) + `Log Out` (red outline)
- **Modification:** Telemetry & Diagnostics row removed entirely

## PAGE 05 — `5-student home.jpeg`
- **Screen name:** Student Home (Check In tab)
- **Role:** Student
- **Route:** `/student/home` (tab 0 of student shell)
- **Navigation:** `Scan QR Code to Check In →` → `/student/scan`; bottom nav: Check In / Logs / Profile (telemetry tab removed); top icons decorative
- **Visible components:**
  - Header: `Smart Attendance` serif + `Campus Mesh`→ rebuilt as `Session Active` pill (no mesh/location)
  - Profile card: `SM` avatar, `Salma Mahmoud ✓`, `2023000000`, `B.Sc. AI & Software Systems`, `In Geofence`→ rebuilt as `Checked In` neutral pill (no geofence)
  - Active session card (navy top border): `Active Session` pill + `09:12 AM • Mon`, `CS-402: Deep Learning` serif 22, `Room 304 (Main Hall) • Dr. Harrison`, graduation-cap icon
  - Two info tiles: `Geofence Status Verified (±2m Lock)` → rebuilt `Session Status / Verified`; `BLE Beacon Aud-B-304-Beacon` → rebuilt `Room Aud-B-304` (no BLE/location)
  - Amber countdown bar: `Check-in window closes in: 07m 48s`
  - Navy button `Scan QR Code to Check In →` (radius 14, h 56)
  - Caption (neutralised, no geofence/BLE wording)
  - `Term Attendance Metrics` + `View Full Analytics` → `/student/history`
  - `ATTENDANCE RATE 94.2% • Good Standing` + ring; `Absence Buffer 3 left`; `Attended 38 Lectures`; `Absences 2 Approved`; `Late Flags 1 <5 mins`
  - `Campus Services` icon trio (decorative + shortcuts to scan/history/support)

## PAGE 06 — `6-scanner.jpeg`
- **Screen name:** Room Attendance QR Scanner (FIRST authenticated student screen)
- **Role:** Student
- **Route:** `/student/scan` — **direct landing after student login**
- **Navigation:** Back → `/student/home`; `Confirm Instant QR Attendance →` → `/student/correction-submitted`? No — confirm simulates a successful scan → `/student/session-closed`? Decision: `Confirm` → success dialog → `/student/home`; bottom nav same 3-tab shell. `Simulate Scan` triggers demo scan state (clearly temporary UI-only)
- **Visible components:**
  - Header: fingerprint, `Smart Attendance`, status dot, offline icon (decorative)
  - Sub-header: `Salma Mahmoud • 2023000000` + `Verified ID` green
  - Title `Room Attendance QR Scanner` serif
  - Scanner viewport (dark gradient, radius 24): top pills `Aud-B-304 Beacon (98%)` → rebuilt `Room Aud-B-304` + `Ready` (no beacon/geofence); corner brackets blue; center target; `SEARCHING DYNAMIC QR` pill; bottom bar `Auditorium B • Room 304` + `Simulate Scan` blue button
  - Bottom sheet: grabber, blue pill button `Confirm Instant QR Attendance →`
  - Live camera via `mobile_scanner` (structure works; `Simulate Scan` guarantees verifiable interaction without a real code)
- **Modifications:** beacon/geofence pills neutralised; camera permission = CAMERA only

## PAGE 07 — `7-correct request.jpeg`
- **Screen name:** Correction Request Submitted (success receipt)
- **Role:** Student
- **Route:** `/student/correction-submitted` (form at `/student/correction` submits here)
- **Navigation:** `View in Attendance Logs` (blue) → `/student/history`; `Download Request Slip (PDF/CSV)` → snackbar (UI-only); support link → `/support`; back → `/student/correction`
- **Visible components:**
  - Header `Smart Attendance / ACADEMIC LEDGER` + `STU-2024-8842` chip
  - Green `LOGGED` badge, `Correction Request Submitted` serif 26, description for `MATH-310`
  - `# Tx Ref: #REQ-9042 • Hash: 0x7F2a8c…c39a88` mono bar
  - `LEDGER RECEIPT ENTRY / Today, 11:36 AM` card: `COURSE & FACULTY MATH-310 Discrete Mathematics • Prof. Linda K.` + `TICKET ID #REQ-9042`; `ORIGINAL SCAN Late (+2m grace) 11:32:14 AM EST` (red) vs `REQUESTED STATUS Verified On-Time` (green)
  - `STATED REASON: Beacon / Geofence Drift` → rebuilt neutral `Schedule Conflict` (no location); attachment row `kiosk_sw08_queue_timestamp.jpg / EXIF validated • 1.4 MB` → rebuilt `attachment added`; `Cryptographic Proof: 0x7F2a8c…` mono chip
  - `Audit Pipeline (ETA: 24–48 hrs)`: Step 1 Done, Step 2 In Progress (Dr. Linda K.), Step 3 Pending
  - Buttons as above; footer `Need urgent help? Contact Academic Registrar Support`

## PAGE 08 — `8-student dashboard.jpeg`
- **Screen name:** Attendance History / Logs
- **Role:** Student
- **Route:** `/student/history` (tab 1 of student shell)
- **Navigation:** `Filter` → bottom sheet (UI-only); course chips filter list (UI-only); `View Reason / View Audit / View Attestation` → `/student/correction-submitted`; back via bottom nav
- **Visible components:**
  - Header `Smart Attendance / ACADEMIC LEDGER` + `2023000000` chip
  - `Salma Mahmoud (Senior Y4)` + `AI • Audit Hash Live`→ rebuilt `Attendance Record`; `Filter` button
  - Month card `October 2024` + `< Wk 8 of 14 >`; stat tiles: `Rate 94.2% +1.4%`, `Present 38`, `Approved 2 Med Leaves`, `Late/Unex 1/0 <5m grace`
  - Course chips: `All Courses, CS-402, MATH-310, LAB-204, PHY…`; status tabs `All (41) / Verified (38) / Excused (2) / Flagged (1)` + `Sync: 2m ago`→ rebuilt `Updated just now`
  - Day groups: `Today Mon, Oct 21 (2 Sessions)`, `Yesterday (1)`, `Thu, Oct 17 (2)`
  - Session cards: punch time block + course chip + class time + status pill (`Verified`, `Late (+2m)`, `Excused`) + title + room/instructor + footer meta + link; excused card shows approver + attestation link

## PAGE 09 — `9-closed.jpeg`
- **Screen name:** Session Closed / Thank You
- **Role:** Student
- **Route:** `/student/session-closed`
- **Navigation:** `Return to Home →` → `/student/home`; `View Full History / Logs` → `/student/history`; back → home
- **Visible components:**
  - Header `Smart Attendance`
  - `Attendance Attested` + `Session Closed` pill; ring graphic + `Synced` pill
  - `Thank You, See You Soon!` serif; description (ledger wording neutralised to `securely recorded`)
  - Blue pill `Return to Home →`; outline `View Full History / Logs`
  - Bottom nav 3-tab (no telemetry)

## PAGE 10 — `10-AI.png`
- **Screen name:** Attendance Risk / Reports (Instructor)
- **Role:** Instructor
- **Route:** `/instructor/reports`
- **Navigation:** Back → `/instructor/menu`; rows/filter UI-only; bottom via instructor shell (Home/QR/Reports/Menu)
- **Visible components (low-res source):** risk header `ABSENCE RISK NOTICE`, totals (`48 At-Risk`, `78.4%`, `Critical (5)`), risk filter chips (`All`, `Critical`, `Medium`, `Low`), student rows with avatar initials, name, attendance bar, status chip (`Low Risk`, `Medium`, `High`, `Very High`), meta (`Total absences`, `Consecutive`), actions (`Notify`, `Review`, `Send to Advisor`), bottom bar `Mark All Read`-style actions
- **Rebuild note:** source is low-resolution; layout/proportions matched as closely as possible; documented as remaining difference. No AI backend — all rows are clearly-marked temporary UI-only data

## PAGE 11 — `11-telemetry.jpeg` — **REMOVED (intentional)**
- **Screen name:** Telemetry Engine / BLE Mesh / Geofence Ledger / Sync Epoch Clock
- **Route:** NONE — screen, route, tab, widgets, providers, models, services, fake data all deleted
- **Reason:** Requirement §1: telemetry completely removed. No placeholder, no dead route, no bottom-nav item
- **Replacement:** student bottom nav is now 3 items (Check In / Logs / Profile); no telemetry anywhere including menus, dashboards, footers

## PAGE 12 — `12-instrucror dashboard.jpeg`
- **Screen name:** Instructor Dashboard (Admin Console / Today's Pulse)
- **Role:** Instructor
- **Route:** `/instructor/dashboard` (tab 0 of instructor shell; legacy alias `/lecturerDashboard`/`/adminConsole` removed)
- **Navigation:** `View REQ-9042 →` → `/instructor/reports`; `+ Add Student / + Add Faculty` → snackbar/dialog (UI-only, no backend); roster edit/delete → snackbar; cards tap → detail snackbar
- **Visible components:**
  - Header `Smart Attendance + ADMIN CONSOLE` chip
  - `System Live • 14 Nodes Synced`→ rebuilt `System Live` + `EPOCH 04:34:43 UTC`→ rebuilt clock (no nodes/telemetry); profile `TM Dr. Tariq Al-Mansoor, Faculty Admin / Registrar`
  - `Today's Pulse` + `Auto-refresh 5s`: `TOTAL PRESENT 2,845 +2.4% vs last wk, 94.2% Attendance`; `ACTIVE HALLS 18, All telemetry locked`→ rebuilt `All sessions on schedule / 100% Schedule Health`; `FLAGGED DRIFT 7, GPS/Beacon variance`→ rebuilt `FLAGGED 7, Needs review / Audit Queue Active`; `CORRECTIONS 4, Appeals requiring sign-off, View REQ-9042 →`
  - `Active Lecture Monitoring` + `QR 15s Pulse`: `CS-402 Deep Learning, Auditorium B • Prof. Harrison, Checked In 128/135, Aud-B-304`→ rebuilt `Room Aud-B-304`, `94.8% Sync`, `Dynamic Salt #88AA / Expires in 08s`→ rebuilt `Session code … / Refreshes periodically`; `MATH-310 Discrete Math, Science Wing Hall C • Dr. Linda Zhao, 86/90 Kiosk SW-08, ±2m Accuracy`→ rebuilt `Room verified`
  - `Access & Records Management (Admin Hub)`: `+ Add Student` (navy) / `+ Add Faculty` (outline); filter chips `All (32) / Students / Faculty` + search/sort (UI-only); roster rows `LZ Dr. Linda Zhao Faculty…`, `KA Kareem Al-Omari Student…`, `SA Sara Al-Husseini Student…` with edit/delete + `Permissions ›` / `Biometrics Linked ›`→ rebuilt neutral `View ›`

## PAGE 13 — `13-generate scanner.jpeg`
- **Screen name:** Session QR Code / Generate QR (Instructor)
- **Role:** Instructor
- **Route:** `/instructor/generate-qr` (tab 1 of instructor shell)
- **Navigation:** `Generate QR Code` toggles QR vs placeholder (UI-only, uses `qr_flutter`, no backend); `Generate QR / Log (0)` tabs switch (UI-only); bottom nav instructor shell
- **Visible components:**
  - Sky-blue header (`#2AA6E2`): `03:44 PM` status row (rebuilt without device status icons dependency — plain text clock), `Instructor Portal / AttendSync`→ rebuilt `Instructor Portal / Smart Attendance`, person icon, `Active Course CS-401: Advanced Algorithms • Live` card
  - Tab bar `✨ Generate QR | 📋 Log (0)`
  - White card (radius 24): `Instructor Access Only` pill, `Session QR Code` serif, `Students scan this to mark attendance`, dashed QR placeholder (`Tap Generate to create QR`) ↔ generated QR (`qr_flutter`, payload = clearly-marked temporary UI-only session string), `QR expires after 60 seconds` (countdown UI-only)
  - Bottom blue button `✨ Generate QR Code` (toggles to `Refresh QR Code`); `Log (0)` shows empty-state card (no fake attendance API)

## PAGE 14 — `14-support.jpeg`
- **Screen name:** Support
- **Role:** Shared (student + instructor)
- **Route:** `/support`
- **Navigation:** Back arrow → pops to caller; FAQ rows → expand/collapse (UI-only); `Email Support / Call Helpline` → snackbar (no backend); `Send Feedback` → snackbar + clear
- **Visible components:**
  - Header: back `←`, `Support` serif, info icon; grabber
  - `How can we help?` serif 28
  - `FREQUENTLY ASKED QUESTIONS` mono label; FAQ card (radius 20): `How to mark attendance…`, `Attendance reports…`, `Account settings…` each with icon tile + `›`
  - `DIRECT CONTACT` label; two cards: `Email Support / Typically replies in 2h / support@attendtra…`, `Call Helpline / Mon–Fri, 9am–5pm / +1 (800) 555-0199`
  - Info bar `Your school ID: ATH-94821…`; navy `Send Feedback` button; `App Version 2.4.1 (Build 8902)`

## PAGE 15 — `15-log out.jpeg`
- **Screen name:** Log Out (confirm)
- **Role:** Shared (shows current user)
- **Route:** `/logout`
- **Navigation:** `←` → pop; `Yes, Log Out` → clears `AuthState` + `pushNamedAndRemoveUntil(/login)`; `Stay Logged In` → pop; after logout authenticated routes are unreachable (guard)
- **Visible components:**
  - Header `Smart Attendance` + `LIVE` pill
  - White card: lock icon + logout badge, `Log Out of Smart Attendance?` serif, user row `SM Salma Mahmoud / AI Engineering / 2023000000` (instructor variant shows Dr. Tarek)
  - Two tiles: `ACTIVE BEACON Hall 302 / BLE Session Safe`→ rebuilt `CURRENT SESSION Hall 302 / Session on schedule`; `TODAY'S SHIFT 2 Verified / All Lectures Logged`
  - Info card `Session Security Enclave…`→ rebuilt neutral `You will be signed out on this device.` (no beacon/proximity wording)
  - `Remember Student ID / Quick biometric login enabled` + switch (UI-only)
  - Navy `Yes, Log Out` + light `Stay Logged In`; footer version line (rebranded, no geofence/enclave wording)
