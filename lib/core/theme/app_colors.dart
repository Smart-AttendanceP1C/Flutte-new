import 'package:flutter/material.dart';

/// Central color tokens. Values match the P1C reference images.
/// Do not introduce per-screen hex values — reuse these.
abstract final class AppColors {
  // Brand
  static const deepNavy = Color(0xFF0A1445);
  static const primaryBlue = Color(0xFF2456E6);
  static const primaryDark = Color(0xFF1A3A8A);
  static const instructorSky = Color(0xFF2AA6E2);
  static const instructorSkyDark = Color(0xFF1E8FC7);

  // Surfaces
  static const lightBg = Color(0xFFF5F7FB);
  static const card = Colors.white;
  static const paleBlue = Color(0xFFEEF2FF);
  static const chipBg = Color(0xFFE6F0FF);
  static const borderLight = Color(0xFFE7ECF6);
  static const borderMid = Color(0xFFDDE3F0);

  // Text
  static const textDark = Color(0xFF152238);
  static const textMid = Color(0xFF6B7A90);
  static const textFaint = Color(0xFF8A9AB6);
  static const loginLabel = Color(0xFF8EA2D8);
  static const loginHint = Color(0xFF7C8DB0);

  // Status
  static const success = Color(0xFF0B7A45);
  static const successBg = Color(0xFFE0F7E9);
  static const successDot = Color(0xFF17C47A);
  static const warning = Color(0xFFB7791F);
  static const warningBg = Color(0xFFFFF3C2);
  static const danger = Color(0xFFB91C1C);
  static const dangerBg = Color(0xFFFFE4E6);
  static const dangerBright = Color(0xFFE0432A);
  static const infoAmber = Color(0xFFE0A72A);

  // Misc
  static const avatarNavy = Color(0xFF1A3A8A);
  static const logoutNavy = Color(0xFF0A2A7A);

  // ---- Brightness-aware helpers (same layout, adapted colors) ----
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Primary text on page/card surfaces.
  static Color ink(BuildContext context) =>
      isDark(context) ? const Color(0xFFE8EEFF) : textDark;

  /// Navy headings (#1A3A8A in light) → readable periwinkle in dark.
  static Color heading(BuildContext context) =>
      isDark(context) ? const Color(0xFFB9CCFF) : primaryDark;

  static Color cardBorder(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.10)
      : borderLight;

  static Color tileBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E2436) : lightBg;

  static Color iconTileBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF223052) : chipBg;
}
