import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../settings/settings_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Appearance & language bottom sheet. Opened from existing profile/menu
/// areas (never a new settings screen). Persists choices on device.
abstract final class AppearanceSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AppearanceSheetBody(),
    );
  }
}

class _AppearanceSheetBody extends StatelessWidget {
  const _AppearanceSheetBody();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('appearance'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink(context),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _Choice(
                  label: context.tr('theme_system'),
                  selected: settings.themeChoice == 'system',
                  onTap: () => settings.setTheme('system'),
                ),
                _Choice(
                  label: context.tr('theme_light'),
                  selected: settings.themeChoice == 'light',
                  onTap: () => settings.setTheme('light'),
                ),
                _Choice(
                  label: context.tr('theme_dark'),
                  selected: settings.themeChoice == 'dark',
                  onTap: () => settings.setTheme('dark'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('language'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink(context),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _Choice(
                  label: 'English',
                  selected: settings.languageCode == 'en',
                  onTap: () => settings.setLanguage('en'),
                ),
                _Choice(
                  label: 'العربية',
                  selected: settings.languageCode == 'ar',
                  onTap: () => settings.setLanguage('ar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primaryBlue,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.ink(context),
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

/// Shared primary button matching the references (navy/blue pill).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outline;
  final bool danger;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outline = false,
    this.danger = false,
    this.height = AppDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ],
    );
    if (outline) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: danger
                ? (AppColors.isDark(context)
                    ? const Color(0xFFFF8A80)
                    : AppColors.danger)
                : AppColors.heading(context),
            side: BorderSide(
              color: danger
                  ? AppColors.danger.withValues(alpha: 0.3)
                  : AppColors.cardBorder(context),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: child,
        ),
      );
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: danger
              ? AppColors.danger
              : AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Shared white card matching the references.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? topBorderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppDimensions.cardRadius,
    this.topBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.cardBorder(context)),
        boxShadow: dark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF1A3A8A)
                      .withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (topBorderColor != null)
              Container(height: 4, color: topBorderColor),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// Section label row, e.g. `ATTENDANCE TOOLS` + trailing link.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'RobotoMono',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: AppColors.textFaint,
            ),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
      ],
    );
  }
}

/// Menu row tile used by both student and instructor menus.
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool highlighted;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: highlighted
                    ? AppColors.primaryBlue
                    : AppColors.iconTileBg(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: highlighted
                    ? Colors.white
                    : (AppColors.isDark(context)
                        ? const Color(0xFF9DB9FF)
                        : AppColors.primaryBlue),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: highlighted
                          ? AppColors.heading(context)
                          : AppColors.ink(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textFaint,
                ),
          ],
        ),
      ),
    );
  }
}
