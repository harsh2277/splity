import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';

// ══════════════════════════════════════════════════════════════
//  AppButton — Splity's primary interactive element
//
//  Variants:  primary | secondary | ghost | danger | link
//  Sizes:     sm (36h) | md (44h) | lg (52h)
//  States:    default | loading | disabled
// ══════════════════════════════════════════════════════════════

enum AppButtonVariant { primary, secondary, ghost, danger, link }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.hasShadow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final List<List<dynamic>>? leadingIcon;
  final List<List<dynamic>>? trailingIcon;
  final bool hasShadow;

  bool get _disabled => onPressed == null && !isLoading;

  double get _height => switch (size) {
        AppButtonSize.sm => AppConstants.buttonHeightSm,
        AppButtonSize.md => AppConstants.buttonHeightMd,
        AppButtonSize.lg => AppConstants.buttonHeightLg,
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 16),
        AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 20),
        AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 24),
      };

  double get _fontSize => switch (size) {
        AppButtonSize.sm => 13,
        AppButtonSize.md => 15,
        AppButtonSize.lg => 16,
      };

  double get _iconSize => switch (size) {
        AppButtonSize.sm => 15,
        AppButtonSize.md => 17,
        AppButtonSize.lg => 19,
      };

  double get _loaderSize => switch (size) {
        AppButtonSize.sm => 14,
        AppButtonSize.md => 16,
        AppButtonSize.lg => 18,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    // ── Resolve variant colors ────────────────────────────────
    late Color bg;
    late Color fg;
    Color? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = isDark ? c.primary500 : c.primary600;
        fg = c.textOnPrimary;
      case AppButtonVariant.secondary:
        bg = isDark ? c.primary900.withValues(alpha: 0.5) : c.primary50;
        fg = isDark ? c.primary300 : c.primary600;
        border = isDark ? c.primary800 : c.primary200;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isDark ? c.primary400 : c.primary600;
        border = c.border;
      case AppButtonVariant.danger:
        bg = isDark ? c.error600 : c.error600;
        fg = Colors.white;
      case AppButtonVariant.link:
        bg = Colors.transparent;
        fg = isDark ? c.primary400 : c.primary600;
    }

    if (_disabled) {
      bg = isDark ? c.surface3 : c.neutral200;
      fg = c.textDisabled;
      border = null;
    }

    // ── Label row ────────────────────────────────────────────
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox.square(
            dimension: _loaderSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (leadingIcon != null) ...[
          HugeIcon(icon: leadingIcon!, size: _iconSize, color: fg),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            color: fg,
            letterSpacing: -0.1,
            height: 1,
          ),
        ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 6),
          HugeIcon(icon: trailingIcon!, size: _iconSize, color: fg),
        ],
      ],
    );

    // ── Link variant (no Material ink) ───────────────────────
    if (variant == AppButtonVariant.link) {
      return GestureDetector(
        onTap: (_disabled || isLoading) ? null : onPressed,
        child: Opacity(
          opacity: _disabled ? 0.4 : 1.0,
          child: Padding(padding: _padding, child: content),
        ),
      );
    }

    // ── All other variants ────────────────────────────────────
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
    );

    final isPrimary = variant == AppButtonVariant.primary && !_disabled;

    Widget btn = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        gradient: isPrimary
            ? LinearGradient(
                colors: isDark
                    ? [c.primary400, c.primary600]
                    : [const Color(0xFF3897FF), const Color(0xFF0055FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        boxShadow: isPrimary && hasShadow
            ? [
                BoxShadow(
                  color: (isDark ? c.primary500 : const Color(0xFF0055FF))
                      .withValues(alpha: 0.35),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: isPrimary ? Colors.transparent : bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        child: InkWell(
          onTap: (_disabled || isLoading) ? null : onPressed,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          customBorder: shape,
          splashColor: fg.withValues(alpha: 0.15),
          highlightColor: fg.withValues(alpha: 0.08),
          child: Container(
            height: _height,
            padding: _padding,
            decoration: border != null
                ? BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusFull),
                    border: Border.all(color: border, width: 1.5),
                  )
                : null,
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );

    if (_disabled) btn = Opacity(opacity: 0.55, child: btn);
    return isFullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
