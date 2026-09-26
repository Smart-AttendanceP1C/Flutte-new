import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/auth_repository.dart';
import '../features/auth/state/auth_state.dart';
import '../features/instructor/data/instructor_api.dart';import '../features/instructor/state/instructor_controller.dart';
import '../features/instructor/state/risk_controllers.dart';
import '../features/instructor/state/session_controller.dart';
import '../features/student/data/student_api.dart';
import '../features/student/state/correction_controller.dart';
import '../features/student/state/history_controller.dart';
import '../features/student/state/scan_controller.dart';
import '../features/student/state/student_home_controller.dart';
import 'l10n/app_strings.dart';
import 'network/api_client.dart';
import 'network/api_exception.dart';
import 'settings/settings_controller.dart';
import 'storage/session_store.dart';
import 'routing/app_router.dart';
import 'routing/app_routes.dart';
import 'theme/app_theme.dart';

/// All production dependencies, built once in main() — the composition root.
///
/// Flow: Storage → ApiClient → AuthRepository/APIs → AuthState → App.
/// No circular init: ApiClient only needs a token closure; the 401 hook is
/// wired after [AuthState] exists.
class AppDependencies {
  final SettingsController settings;
  final SessionStore sessions;
  final ApiClient api;
  final AuthRepository authRepo;
  final StudentApi studentApi;
  final InstructorApi instructorApi;
  final AuthState auth;
  final GlobalKey<NavigatorState> navigatorKey;

  AppDependencies._({
    required this.settings,
    required this.sessions,
    required this.api,
    required this.authRepo,
    required this.studentApi,
    required this.instructorApi,
    required this.auth,
    required this.navigatorKey,
  });

  /// Role-appropriate liveness check for a stored JWT.
  /// Throws [ApiException] from the real backend; 401 means the stored
  /// token is invalid/expired (or belongs to a previous backend DB).
  static Future<void> validateStoredSession(
    StudentApi studentApi,
    InstructorApi instructorApi,
    SessionStore sessions,
  ) async {
    final role = sessions.user?['role']?.toString();
    if (role == 'student') {
      await studentApi.me();
      return;
    }
    if (role == 'lecturer' || role == 'ta' || role == 'admin') {
      await instructorApi.me();
      return;
    }
    // Unknown/missing role: try student, fall back to staff.
    // A 401 from either means the token itself is bad → rethrow.
    try {
      await studentApi.me();
    } on ApiException catch (e) {
      if (e.status == 401) rethrow;
      await instructorApi.me();
    }
  }

  static Future<AppDependencies> create({
    SharedPreferences? prefsOverride,
    SessionStore? sessionOverride,
    ApiClient? apiOverride,
  }) async {
    final prefs = prefsOverride ?? await SharedPreferences.getInstance();
    final settings = SettingsController(prefs);
    final sessions = sessionOverride ?? SessionStore(prefs);
    final api =
        apiOverride ?? ApiClient(tokenProvider: () async => sessions.token);
    final authRepo = AuthRepository(api: api, sessions: sessions);
    final studentApi = StudentApi(api);
    final instructorApi = InstructorApi(api);
    final auth = AuthState(repo: authRepo, sessions: sessions);
    // Central 401 handling: expired/invalid JWT clears the session.
    // The reactive [_SessionWatcher] below then bounces to Login.
    api.onUnauthorized = () => auth.handleUnauthorized();
    // Validate BEFORE first routing: stale JWTs (expired, or minted by a
    // previous backend DB) are cleared here so "/" lands on Login instead
    // of an authed shell flashing "Invalid or expired token".
    // No forced wipe: with no stored session this makes zero network calls;
    // network failures keep the optimistic session for honest retry UI.
    await auth.restore(
      validator: () =>
          validateStoredSession(studentApi, instructorApi, sessions),
    );
    return AppDependencies._(
      settings: settings,
      sessions: sessions,
      api: api,
      authRepo: authRepo,
      studentApi: studentApi,
      instructorApi: instructorApi,
      auth: auth,
      navigatorKey: GlobalKey<NavigatorState>(),
    );
  }
}

/// Composition root consumer: ONE root MaterialApp.
///
/// main.dart builds [AppDependencies] and launches this widget.
/// UI → Provider → Repository → ApiClient → REAL backend.
/// No fake data, no telemetry, no location.
class SmartAttendanceApp extends StatefulWidget {
  final AppDependencies deps;

  const SmartAttendanceApp({super.key, required this.deps});

  @override
  State<SmartAttendanceApp> createState() => _SmartAttendanceAppState();
}

class _SmartAttendanceAppState extends State<SmartAttendanceApp> {
  @override
  Widget build(BuildContext context) {
    final deps = widget.deps;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deps.settings),
        ChangeNotifierProvider.value(value: deps.sessions),
        Provider.value(value: deps.studentApi),
        Provider.value(value: deps.instructorApi),
        ChangeNotifierProvider.value(value: deps.auth),
        ChangeNotifierProvider(
          create: (_) => StudentHomeController(deps.studentApi),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryController(deps.studentApi),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanController(deps.studentApi),
        ),
        ChangeNotifierProvider(
          create: (_) => CorrectionController(deps.studentApi),
        ),
        ChangeNotifierProvider(
          create: (_) => InstructorController(deps.instructorApi),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionController(deps.instructorApi),
        ),
        ChangeNotifierProvider(
          create: (_) => RiskController(deps.instructorApi),
        ),
        ChangeNotifierProvider(
          create: (_) => CorrectionQueueController(deps.instructorApi),
        ),
      ],
      child: _SessionWatcher(
        child: Consumer2<AuthState, SettingsController>(
          builder: (context, auth, settings, _) {
            return MaterialApp(
              title: 'Smart Attendance',
              debugShowCheckedModeBanner: false,
              navigatorKey: deps.navigatorKey,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: settings.themeMode,
              locale: settings.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              // "/" resolves auth and redirects to the correct real screen.
              initialRoute: AppRoutes.root,
              onGenerateRoute: (routeSettings) {
                final guarded = AppRouter.guard(
                  isAuthenticated: auth.isAuthenticated,
                  role: auth.role,
                  target: routeSettings.name ?? AppRoutes.root,
                );
                if (guarded != routeSettings.name) {
                  return AppRouter.onGenerateRoute(
                    RouteSettings(
                      name: guarded,
                      arguments: routeSettings.arguments,
                    ),
                  );
                }
                return AppRouter.onGenerateRoute(routeSettings);
              },
              onUnknownRoute: (routeSettings) =>
                  AppRouter.onGenerateRoute(routeSettings),
            );
          },
        ),
      ),
    );
  }
}

/// Reactive auth → router bridge.
///
/// `onGenerateRoute` guards only run during navigation, so clearing the
/// session on a 401 (expired/invalid JWT mid-session) would otherwise leave
/// the user staring at an authed shell showing "Invalid or expired token".
/// This watcher listens to [AuthState]: on an authenticated → unauthenticated
/// transition it clears the stack to the real Login screen. It never fires
/// on first build (Splash owns initial routing) and never fabricates auth.
class _SessionWatcher extends StatefulWidget {
  final Widget child;
  const _SessionWatcher({required this.child});

  @override
  State<_SessionWatcher> createState() => _SessionWatcherState();
}

class _SessionWatcherState extends State<_SessionWatcher> {
  AuthState? _auth;
  late bool _wasAuthenticated;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _auth = context.read<AuthState>();
      _wasAuthenticated = _auth!.isAuthenticated;
      _auth!.addListener(_onAuthChanged);
    });
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final auth = _auth;
    if (auth == null || !mounted) return;
    final now = auth.isAuthenticated;
    final was = _wasAuthenticated;
    _wasAuthenticated = now;
    if (was && !now && !auth.isRestoring) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
