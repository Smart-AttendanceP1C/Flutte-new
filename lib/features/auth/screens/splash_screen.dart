import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/routing/route_guards.dart';
import '../state/auth_state.dart';

/// Application root ("/").
///
/// NOT a fake screen: it resolves the restored authentication state and
/// redirects to the correct real destination:
///   restoring  → loading spinner
///   unauth     → /login
///   student    → /student/home
///   instructor/staff → /instructor
///   other role → /login with an honest message (handled by LoginScreen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  void _resolve() {
    if (!mounted || _redirected) return;
    final auth = context.read<AuthState>();
    if (auth.isRestoring) {
      // Wait for restoration then retry next frame.
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _resolve();
      });
      return;
    }
    _redirected = true;
    final String dest;
    if (!auth.isAuthenticated) {
      dest = AppRoutes.login;
    } else {
      dest = RouteGuards.homeForRole(auth.role) ?? AppRoutes.login;
    }
    Navigator.pushReplacementNamed(context, dest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              context.tr('smart_attendance'),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
