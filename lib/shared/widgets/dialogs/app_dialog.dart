import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../buttons/app_button.dart';

// ══════════════════════════════════════════════════════════════
//  AppDialog — modal dialogs
//
//  Types:   confirm | info | custom
// ══════════════════════════════════════════════════════════════

enum AppDialogType { confirm, info, destructive, custom }

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.type = AppDialogType.info,
    this.icon,
    required this.title,
    this.message,
    this.content,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isLoading = false,
  });

  final AppDialogType type;
  final List<List<dynamic>>? icon;
  final String title;
  final String? message;
  final Widget? content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isLoading;

  /// Show a confirm dialog. Returns true if confirmed.
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppDialog(
        type: isDanger ? AppDialogType.destructive : AppDialogType.confirm,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  /// Show an informational dialog.
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    String? message,
    String dismissLabel = 'Got it',
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AppDialog(
        type: AppDialogType.info,
        title: title,
        message: message,
        confirmLabel: dismissLabel,
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show a custom content dialog.
  static Future<T?> showCustom<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    Widget? actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        child: AppDialog(
          type: AppDialogType.custom,
          title: title,
          content: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    // ── Icon & color ────────────────────────────────────────
    final List<List<dynamic>> resolvedIcon;
    final Color iconColor;
    final Color iconBg;

    switch (type) {
      case AppDialogType.confirm:
        resolvedIcon = icon ?? HugeIcons.strokeRoundedHelpCircle;
        iconColor = isDark ? c.primary400 : c.primary600;
        iconBg = isDark ? c.primary900.withValues(alpha: 0.5) : c.primary100;
      case AppDialogType.info:
        resolvedIcon = icon ?? HugeIcons.strokeRoundedInformationCircle;
        iconColor = isDark ? c.info400 : c.info600;
        iconBg = isDark ? c.info900.withValues(alpha: 0.5) : c.info100;
      case AppDialogType.destructive:
        resolvedIcon = icon ?? HugeIcons.strokeRoundedAlert01;
        iconColor = isDark ? c.error400 : c.error600;
        iconBg = isDark ? c.error900.withValues(alpha: 0.5) : c.error100;
      case AppDialogType.custom:
        resolvedIcon = icon ?? HugeIcons.strokeRoundedGrid;
        iconColor = isDark ? c.primary400 : c.primary600;
        iconBg = isDark ? c.primary900.withValues(alpha: 0.5) : c.primary100;
    }

    return Dialog(
      backgroundColor: isDark ? c.surface : Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Icon ─────────────────────────────────────────
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(icon: resolvedIcon, color: iconColor, size: 26),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Title ─────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: c.textPrimary,
              ),
            ),

            // ── Message ───────────────────────────────────────
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: c.textSecondary,
                  height: 1.5,
                ),
              ),
            ],

            // ── Custom content ────────────────────────────────
            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],

            const SizedBox(height: 24),

            // ── Actions ───────────────────────────────────────
            if (type != AppDialogType.custom) ...[
              if (onConfirm != null)
                AppButton(
                  label: confirmLabel,
                  onPressed: isLoading ? null : onConfirm,
                  isLoading: isLoading,
                  isFullWidth: true,
                  variant: type == AppDialogType.destructive
                      ? AppButtonVariant.danger
                      : AppButtonVariant.primary,
                ),
              if (onCancel != null) ...[
                const SizedBox(height: 10),
                AppButton(
                  label: cancelLabel,
                  onPressed: onCancel,
                  isFullWidth: true,
                  variant: AppButtonVariant.ghost,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
