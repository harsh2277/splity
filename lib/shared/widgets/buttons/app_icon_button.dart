import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';

// ══════════════════════════════════════════════════════════════
//  AppIconButton — Icon-only fully-rounded button
//
//  Variants:  filled | ghost | outlined
//  Sizes:     sm (36) | md (44) | lg (52)
//  States:    default | pressed | disabled
// ══════════════════════════════════════════════════════════════

enum AppIconButtonVariant { filled, ghost, outlined }

enum AppIconButtonSize { sm, md, lg }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppIconButtonVariant.filled,
    this.size = AppIconButtonSize.md,
    this.tooltip,
    this.isDanger = false,
  });

  final List<List<dynamic>> icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final AppIconButtonSize size;
  final String? tooltip;
  final bool isDanger;

  bool get _disabled => onPressed == null;

  double get _dimension => switch (size) {
        AppIconButtonSize.sm => AppConstants.buttonHeightSm,
        AppIconButtonSize.md => AppConstants.buttonHeightMd,
        AppIconButtonSize.lg => AppConstants.buttonHeightLg,
      };

  double get _iconSize => switch (size) {
        AppIconButtonSize.sm => 16,
        AppIconButtonSize.md => 20,
        AppIconButtonSize.lg => 24,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    late Color bg;
    late Color fg;
    Color? borderColor;

    if (isDanger) {
      switch (variant) {
        case AppIconButtonVariant.filled:
          bg = c.error600;
          fg = Colors.white;
        case AppIconButtonVariant.ghost:
          bg = Colors.transparent;
          fg = c.error500;
        case AppIconButtonVariant.outlined:
          bg = Colors.transparent;
          fg = c.error500;
          borderColor = c.error300;
      }
    } else {
      switch (variant) {
        case AppIconButtonVariant.filled:
          bg = isDark ? c.primary500 : c.primary600;
          fg = Colors.white;
        case AppIconButtonVariant.ghost:
          bg = isDark ? c.surface2 : c.neutral100;
          fg = isDark ? c.neutral200 : c.neutral700;
        case AppIconButtonVariant.outlined:
          bg = Colors.transparent;
          fg = isDark ? c.primary400 : c.primary600;
          borderColor = isDark ? c.primary700 : c.primary200;
      }
    }

    if (_disabled) {
      bg = isDark ? c.surface3 : c.neutral200;
      fg = c.textDisabled;
      borderColor = null;
    }

    Widget btn = Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      child: InkWell(
        onTap: _disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        splashColor: fg.withValues(alpha: 0.12),
        highlightColor: fg.withValues(alpha: 0.06),
        child: Container(
          width: _dimension,
          height: _dimension,
          decoration: borderColor != null
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.5),
                )
              : null,
          alignment: Alignment.center,
          child: HugeIcon(icon: icon, size: _iconSize, color: fg),
        ),
      ),
    );

    if (_disabled) btn = Opacity(opacity: 0.5, child: btn);
    if (tooltip != null) btn = Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}
