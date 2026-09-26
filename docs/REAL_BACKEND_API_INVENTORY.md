# Real Backend API Inventory — `https://perry-lee-stay-firefox.trycloudflare.com`

Source: local `openapi.yaml` (contract reference ONLY) + live verification below.
Prefix `/api/v1` kept exactly. Auth: JWT `Authorization: Bearer <token>`
centralized in `ApiClient` (never on login). Contract defines request shapes
and status codes; **no response bodies are defined** — all parsing tolerant.

`runtime verified` = real HTTP observed from this machine. Authenticated
endpoints need a valid JWT + role + resource IDs.

| Method + Path | Auth | Feature → UI page | Runtime verified |
|---|---|---|---|
| `POST /api/v1/auth/login` `{email,password}` | no | Login → P01 | YES: bad creds → 401 `INVALID_CREDENTIALS`; shape `{"success":false,"error":{"code","message","request_id"}}` |
| `GET /api/v1/users` | admin JWT | none (no admin-list UI) | NO — needs admin JWT |
| `GET /api/v1/courses` | JWT | none (no catalog UI) | NO — needs JWT |
| `GET /api/v1/sections` | JWT | none (no catalog UI) | NO — needs JWT |
| `GET /api/v1/sections/{sectionId}/students` | JWT | none (no section picker UI) | NO — needs JWT + section id |
| `GET /api/v1/students/me` | student JWT | Profile P04, CheckIn P05, Logs P08, Telemetry P11 identity | NO — needs student JWT (layer: `currentUser`/`studentMe`, tolerant) |
| `PATCH /api/v1/students/me` `{name?,current_password?,new_password?}` | student JWT | none (no edit-profile UI) | NO — needs student JWT |
| `GET /api/v1/students/me/sections` | student JWT | none (no sections UI) | NO — needs student JWT |
| `GET /api/v1/students/me/attendance` | student JWT | Logs P08 (`myAttendance`), CheckIn metrics | NO — needs student JWT |
| `GET /api/v1/students/me/risk-features` | student JWT | Live Check sheet (P10) | NO — needs student JWT |
| `GET /api/v1/students/me/risk` | student JWT | Live Check sheet (P10, advisory) | NO — needs student JWT |
| `GET /api/v1/staff` | admin JWT | none (no staff-list UI) | NO — needs admin JWT |
| `GET /api/v1/staff/me` | staff JWT | Dashboard P12 + Menu P03 headers (`StaffProvider`) | YES (prior host run: 200 + sections 200; this host: needs staff JWT) |
| `GET /api/v1/staff/me/sections` | staff JWT | Dashboard counts (best-effort) | YES (prior host run: 200) |
| `GET /api/v1/staff/me/timetable` | staff JWT | Generate QR default `timetable_id` context | NO — needs staff JWT |
| `GET /api/v1/staff/me/sections/{sectionId}/risk` | staff JWT (own section) | Reports P10 section-risk merge (`sectionRisk`, typed `SectionRiskEntry`) | NO — needs staff JWT + assigned section id |
| `GET /api/v1/timetable` | JWT | none (no timetable UI) | NO — needs JWT |
| `POST /api/v1/attendance/sessions` `{timetable_id}` | staff JWT | Generate QR P13 (`SessionProvider.generate`) | NO — needs staff JWT + valid timetable id + schedule window |
| `PATCH /api/v1/attendance/sessions/{id}/close` | staff JWT | `SessionProvider.close` (best-effort on reset) | NO — needs staff JWT + open session |
| `GET /api/v1/attendance/sessions/{id}/qr` | staff JWT | Generate QR P13 (`fetchQrToken`) | NO — needs staff JWT + open session |
| `GET /api/v1/attendance/sessions/{id}/roster` | staff JWT | Reports P10 (`loadRoster`) | NO — needs staff JWT + open session |
| `PATCH /api/v1/attendance/sessions/{id}/students/{sid}` `{attendance_status,reason}` | staff JWT | none (no manual-entry form UI) | NO — needs staff JWT + ids |
| `POST /api/v1/attendance/scan` `{token}` | student JWT | Scanner P06 step 1 | NO — needs student JWT + real QR token |
| `POST /api/v1/attendance/check-in` `{scanTicket}` | student JWT | Scanner P06 step 2 | NO — needs scan ticket |
| `GET /api/v1/attendance/records` + filters | JWT | Logs P08 (`records`), CheckIn metrics | NO — needs JWT |
| `GET /api/v1/attendance/records/export?format=csv\|pdf` | JWT | none (no download UI) | NO — needs JWT (raw-bytes `getBytes` ready) |
| `POST /api/v1/attendance/correction-requests` | student JWT | none (no correction form UI; P07 is a static receipt) | NO — needs student JWT |
| `GET /api/v1/attendance/correction-requests?status=` | JWT | none (no review-list UI) | NO — needs JWT |
| `GET /api/v1/attendance/correction-requests/me` | student JWT | none (no list UI) | NO — needs student JWT |
| `PATCH /api/v1/attendance/correction-requests/{id}` | staff JWT | none (no review form UI) | NO — needs staff JWT + request id |
| `POST /api/v1/imports/{rooms,courses,teaching-staff,students,sections,enrollment,timetable}` (CSV) | admin JWT | none (no import UI; no multipart client) | NO — needs admin JWT + CSV |
| `GET /api/v1/audit-events` | auditor/admin JWT | none (no audit UI) | NO — needs auditor/admin JWT |
| `GET /health` | no | none (diagnostics) | YES live 200 `{"success":true,"message":"Server and database are working"}` |

Notes:
- Live Swagger (`api-docs/swagger-ui-init.js` on the foster host) is the
  newest contract snapshot: it ADDS `GET /staff/me/sections/{sectionId}/risk`
  and OMITS `GET /students/me/risk-features` + `GET /students/me/risk`
  (present in local `openapi.yaml`; kept as tolerant layer, live calls
  surface the real 404 state). Live `servers[0].url` points at the
  comfortable host (both tunnels front the same API; comfortable is
  currently DNS-dead, foster live).
- Machine-readable spec endpoints (`/openapi.json`, `/swagger.json`,
  `/api-docs.json`, `/docs`) all return 404; Swagger HTML only. Contract =
  local `openapi.yaml` (verified against live error shapes where possible).
- Real error envelope is `{"success":false,"error":{"code","message","request_id"}}`
  (NOT in `openapi.yaml`): `ApiClient` parses it first, then `detail/message`.
- `GET /api/v1/students/me` without token → 401 `UNAUTHORIZED`/`"Authorization
  token is required"` (proves Bearer requirement).
- No endpoint exists for: dashboard pulse aggregates, absence-buffer metrics,
  student active-session card, device BLE telemetry, correction receipt
  content — those screens keep reference layout with real identity/records
  where available (see mapping doc).
