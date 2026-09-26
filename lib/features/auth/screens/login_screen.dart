import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../state/auth_state.dart';

/// PAGE 01 — Sign in. Matches `1-Sin in.jpeg`.
/// On success: student → `/student/home` (Student Home/Entry — student
/// chooses what to do; QR scan via Take Attendance), instructor → `/instructor`.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // Restored session (token + user persisted on a previous login):
    // skip the form and return to the role home. No UI change.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthState>();
      if (auth.isAuthenticated) _goHome(auth);
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Role home routing (single place): instructor/staff → instructor shell,
  /// student → student home/entry. Returns false for roles with no mobile UI.
  bool _goHome(AuthState authState) {
    if (authState.isInstructor || authState.isStaff) {
      Navigator.pushReplacementNamed(context, AppRoutes.instructor);
      return true;
    } else if (authState.isStudent) {
      // Requirement: student goes to Student Home/Entry first (chooses
      // what to do). QR scan lives under Take Attendance → Scan QR.
      // No ID screen between login and the student app.
      Navigator.pushReplacementNamed(context, AppRoutes.studentHome);
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    final ok = await auth.login(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted || !ok) return;
    final authState = context.read<AuthState>();
    if (_goHome(authState)) return;
    // admin/auditor or unknown role: no dedicated mobile UI — stay on
    // login with an honest message instead of inventing a screen.
    authState.clearError();
    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final msg =
          context.tr('no_mobile_role', {'role': '${authState.role}'});
      messenger.showSnackBar(SnackBar(content: Text(msg)));
      await authState.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              const Positioned(
                top: -40,
                left: -60,
                child: _DottedGlobe(size: 340),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 72),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _LogoGlobe(size: 110),
                          const SizedBox(width: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BUA',
                                style: AppFonts.serif(
                                  size: 60,
                                  weight: FontWeight.w900,
                                  color: Colors.white,
                                ).copyWith(height: 1),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'BADR UNIVERSITY IN ASSIUT',
                                style: AppFonts.mono(
                                  size: 9,
                                  weight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'جامعة بدر بأسيوط',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Text(
                        context.tr('sign_in'),
                        textAlign: TextAlign.center,
                        style: AppFonts.serif(
                          size: 34,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('sign_in_sub'),
                        textAlign: TextAlign.center,
                        style: AppFonts.serif(
                          size: 15,
                          weight: FontWeight.w400,
                          color: AppColors.loginLabel,
                        ),
                      ),
                      const SizedBox(height: 56),
                      if (auth.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.dangerBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            context.tr(auth.error!),
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        context.tr('your_email'),
                        style: AppFonts.mono(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.loginLabel,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _LoginField(
                        controller: _email,
                        hintText: context.tr('email_hint'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (!t.contains('@') || !t.contains('.')) {
                            return context.tr('invalid_email');
                          }
                          return null;
                        },
                        onChanged: (_) => auth.clearError(),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        context.tr('password'),
                        style: AppFonts.mono(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.loginLabel,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _LoginField(
                        controller: _password,
                        hintText: '••••••••',
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _submit,
                        validator: (v) {
                          if ((v ?? '').length < 6) {
                            return context.tr('short_password');
                          }
                          return null;
                        },
                        onChanged: (_) => auth.clearError(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.primaryDark,
                            size: 22,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 58,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: AppFonts.serif(
                              size: 18,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(context.tr('sign_in')),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final TextInputAction textInputAction;
  final void Function()? onEditingComplete;

  const _LoginField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      style: AppFonts.serif(
        size: 15,
        weight: FontWeight.w500,
        color: const Color(0xFF0F1F3A),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: AppFonts.serif(
          size: 14,
          weight: FontWeight.w400,
          color: AppColors.loginHint,
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF4D7CFE),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.dangerBright),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.dangerBright,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _LogoGlobe extends StatelessWidget {
  final double size;
  const _LogoGlobe({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GlobePainter()),
    );
  }
}

class _GlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = Colors.white;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    for (int i = 0; i <= 8; i++) {
      final lat = -60 + i * 15.0;
      final rad = lat * math.pi / 180;
      final rr = r * math.cos(rad);
      final y = c.dy + r * math.sin(rad);
      final steps = (rr * math.pi / 4).clamp(6, 64).toInt();
      for (int s = 0; s < steps; s++) {
        final a = s * 2 * math.pi / steps;
        canvas.drawCircle(
          Offset(c.dx + rr * math.cos(a), y),
          1.1,
          dot,
        );
      }
    }
    for (int m = 0; m < 6; m++) {
      final off = m * math.pi / 6;
      for (int s = 0; s <= 36; s++) {
        final a = s * 2 * math.pi / 36;
        final x = c.dx + r * math.cos(a) * math.cos(off);
        final y = c.dy + r * math.sin(a);
        if ((x - c.dx).abs() <= r) {
          canvas.drawCircle(Offset(x, y), 1.1, dot);
        }
      }
    }
    for (int s = 0; s < 72; s++) {
      final a = s * 2 * math.pi / 72;
      canvas.drawCircle(
        Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a)),
        1.4,
        dot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DottedGlobe extends StatelessWidget {
  final double size;
  const _DottedGlobe({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DottedGlobePainter()),
    );
  }
}

class _DottedGlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()
      ..color = const Color(0xFF2A4F9E).withValues(alpha: 0.55);
    final rand = math.Random(7);
    for (int i = 0; i < 420; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final d = math
          .sqrt(
            math.pow(x - size.width * 0.35, 2) +
                math.pow(y - size.height * 0.4, 2),
          )
          .clamp(0, size.width);
      if (d < size.width * 0.52) {
        canvas.drawCircle(
          Offset(x, y),
          1.2 + rand.nextDouble() * 2.2,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
