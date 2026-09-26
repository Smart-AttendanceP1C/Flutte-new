import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Font families matching the reference images:
/// - Serif (Source Serif 4) for headings, names, buttons.
/// - Mono (Roboto Mono) for section labels, IDs, pills, timestamps, meta.
abstract final class AppFonts {
  static TextStyle serif({
    double size = 14,
    FontWeight weight = FontWeight.w700,
    Color color = const Color(0xFF1A3A8A),
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.sourceSerif4(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono({
    double size = 10,
    FontWeight weight = FontWeight.w600,
    Color color = const Color(0xFF8A9AB6),
    double letterSpacing = 0.4,
  }) =>
      GoogleFonts.robotoMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle sans({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color color = const Color(0xFF6B7A90),
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}
