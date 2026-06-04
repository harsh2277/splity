import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';

// ══════════════════════════════════════════════════════════════
//  AppChip — filter / tag / removable chip
//
//  Types:   filter | tag | input (removable)
//  Sizes:   sm | md
//  States:  selected | unselected | disabled
// ══════════════════════════════════════════════════════════════

enum AppChipType { filter, tag, input }

enum AppChipSize { sm, md }

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.type = AppChipType.filter,
    this.size = AppChipSize.md,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
    this.onRemove,
    this.leadingIcon,
    this.avatar,
  });

  final String label;
  final AppChipType type;
  final AppChipSize size;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;
  /// Called when the remove ✕ is tapped (input type only)
  final VoidCallback? onRemove;
  final List<List<dynamic>>? leadingIcon;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    // ── Colors ────────────────────────────────────────────
    final Color bg;
    final Color fg;
    final Color? border;

    if (isDisabled) {
      bg = isDark ? c.surface3 : c.neutral100;
      fg = c.textDisabled;
      border = null;
    } else if (isSelected) {
      bg = isDark ? c.primary900.withValues(alpha: 0.6) : c.primary100;
      fg = isDark ? c.primary300 : c.primary700;
      border = isDark ? c.primary700 : c.primary300;
    } else {
      switch (type) {
        case AppChipType.filter:
          bg = isDark ? c.surface2 : c.neutral100;
          fg = isDark ? c.neutral200 : c.neutral700;
          border = isDark ? c.surface3 : c.neutral200;
        case AppChipType.tag:
          bg = isDark ? c.surface2 : c.neutral100;
          fg = isDark ? c.neutral300 : c.neutral600;
          border = null;
        case AppChipType.input:
          bg = isDark ? c.primary900.withValues(alpha: 0.4) : c.primary50;
          fg = isDark ? c.primary300 : c.primary700;
          border = isDark ? c.primary800 : c.primary200;
      }
    }

    // ── Sizing ────────────────────────────────────────────
    final padding = size == AppChipSize.sm
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 7);
    final fontSize = size == AppChipSize.sm ? 12.0 : 13.0;
    final iconSize = size == AppChipSize.sm ? 13.0 : 15.0;

    Widget chip = GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: border != null
              ? Border.all(color: border, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (avatar != null) ...[
              SizedBox(
                width: size == AppChipSize.sm ? 18 : 20,
                height: size == AppChipSize.sm ? 18 : 20,
                child: avatar,
              ),
              const SizedBox(width: 6),
            ] else if (leadingIcon != null) ...[
              HugeIcon(icon: leadingIcon!, size: iconSize, color: fg),
              const SizedBox(width: 4),
            ] else if (isSelected && type == AppChipType.filter) ...[
              HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle02, size: iconSize, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: fg,
              ),
            ),
            if (type == AppChipType.input && onRemove != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: isDisabled ? null : onRemove,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: iconSize,
                  color: fg.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (isDisabled) chip = Opacity(opacity: 0.5, child: chip);
    return chip;
  }
}
