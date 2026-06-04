import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';

// ══════════════════════════════════════════════════════════════
//  AppSnackbar — themed toast-style notifications
//
//  Types:   success | error | warning | info
// ══════════════════════════════════════════════════════════════

enum AppSnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    bool showAtTop = false,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Colors ─────────────────────────────────────────────
    final Color bg;
    final Color fg;
    final Color iconColor;
    final List<List<dynamic>> icon;

    switch (type) {
      case AppSnackbarType.success:
        bg = isDark ? colors.success900 : colors.success600;
        fg = Colors.white;
        iconColor = Colors.white;
        icon = HugeIcons.strokeRoundedCheckmarkCircle02;
      case AppSnackbarType.error:
        bg = isDark ? colors.error800 : colors.error600;
        fg = Colors.white;
        iconColor = Colors.white;
        icon = HugeIcons.strokeRoundedAlertCircle;
      case AppSnackbarType.warning:
        bg = isDark ? colors.warning800 : colors.warning500;
        fg = Colors.white;
        iconColor = Colors.white;
        icon = HugeIcons.strokeRoundedAlert01;
      case AppSnackbarType.info:
        bg = isDark ? colors.neutral800 : colors.neutral900;
        fg = colors.neutral50;
        iconColor = colors.primary400;
        icon = HugeIcons.strokeRoundedInformationCircle;
    }

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topMargin = statusBarHeight > 0 ? statusBarHeight + 12 : 24;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          margin: showAtTop
              ? EdgeInsets.only(
                  top: topMargin,
                  bottom: MediaQuery.of(context).size.height - topMargin - 80,
                  left: AppConstants.sp16,
                  right: AppConstants.sp16,
                )
              : const EdgeInsets.all(AppConstants.sp16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          content: Row(
            children: [
              HugeIcon(icon: icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: isDark ? colors.primary400 : colors.primary200,
                  onPressed: onAction ?? () {},
                )
              : null,
        ),
      );
  }

  // ── Convenience shortcuts ─────────────────────────────────

  static void success(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction, bool showAtTop = false}) =>
      show(context, message: message, type: AppSnackbarType.success, actionLabel: actionLabel, onAction: onAction, showAtTop: showAtTop);

  static void error(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction, bool showAtTop = false}) =>
      show(context, message: message, type: AppSnackbarType.error, actionLabel: actionLabel, onAction: onAction, showAtTop: showAtTop);

  static void warning(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction, bool showAtTop = false}) =>
      show(context, message: message, type: AppSnackbarType.warning, actionLabel: actionLabel, onAction: onAction, showAtTop: showAtTop);

  static void info(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction, bool showAtTop = false}) =>
      show(context, message: message, type: AppSnackbarType.info, actionLabel: actionLabel, onAction: onAction, showAtTop: showAtTop);
}
