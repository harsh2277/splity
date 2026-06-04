import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class GroupSuccessSheet extends StatefulWidget {
  const GroupSuccessSheet({
    super.key,
    required this.groupName,
    required this.inviteCode,
    required this.onClose,
  });

  final String groupName;
  final String inviteCode;
  final VoidCallback onClose;

  @override
  State<GroupSuccessSheet> createState() => _GroupSuccessSheetState();
}

class _GroupSuccessSheetState extends State<GroupSuccessSheet> {
  final GlobalKey _repaintKey = GlobalKey();

  Future<void> _downloadQrImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      await Share.shareXFiles(
        [XFile.fromData(pngBytes, name: 'splity_group_qr.png', mimeType: 'image/png')],
        text: 'Join my group "${widget.groupName}" on Splity using this QR Code! Code: ${widget.inviteCode}',
      );
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Failed to export QR image: $e',
          showAtTop: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? c.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Drag Handle ---
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? c.neutral600 : c.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),


          // --- Centered Header ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Center(
              child: Text(
                'My QR Code',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? c.neutral50 : c.neutral900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- Central QR Code Container with Vibrant Gradient (RepaintBoundary for saving) ---
          RepaintBoundary(
            key: _repaintKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF22C55E), // Bright green
                    Color(0xFF0EA5E9), // Sky blue/teal
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // White QR container inside
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: QrImageView(
                      data: widget.inviteCode,
                      version: QrVersions.auto,
                      size: 170,
                      gapless: false,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Invite Code Label
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      widget.inviteCode,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- Description Text ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              'Show this QR Code to your friends to invite them to join the "${widget.groupName}" group together.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: isDark ? c.neutral400 : c.neutral500,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // --- Bottom Action Buttons ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildActionButton(
              context: context,
              label: 'Share',
              icon: Iconsax.share_copy,
              onTap: _downloadQrImage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Material(
      color: isDark ? c.surface3 : const Color(0xFFF1F5F9), // Light grey matching screenshot
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? c.neutral100 : c.neutral900,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? c.neutral100 : c.neutral900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
