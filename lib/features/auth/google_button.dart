import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme_extensions.dart';

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, this.isLoading = false});

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? c.surface3 : Colors.white,
          side: BorderSide(color: isDark ? c.neutral700 : c.neutral300, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? c.neutral300 : c.neutral600,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google logo — coloured "G" in a 20×20 box
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // coloured quadrant ring
                        CustomPaint(size: const Size(20, 20), painter: _GoogleRingPainter()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? c.neutral50 : c.neutral900,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final outerRect = Rect.fromCircle(center: center, radius: r);
    final innerR = r * 0.58;

    void arc(Color color, double startAngle, double sweepAngle) {
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(outerRect, startAngle, sweepAngle, false)
        ..close();
      canvas.drawPath(path, paint);
    }

    // Blue — top (right side, includes the G-bar area)
    arc(const Color(0xFF4285F4), -1.05, 2.10);
    // Red — upper left
    arc(const Color(0xFFEA4335), 1.05, 1.57);
    // Yellow — bottom left
    arc(const Color(0xFFFBBC05), 2.62, 1.57);
    // Green — bottom right
    arc(const Color(0xFF34A853), -2.62, 1.57);

    // Inner white circle to make it a ring
    canvas.drawCircle(center, innerR, Paint()..color = Colors.white);

    // Blue horizontal bar for G crossbar (right half of ring)
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    final barRect = RRect.fromLTRBR(
      center.dx, center.dy - r * 0.18,
      center.dx + r, center.dy + r * 0.18,
      const Radius.circular(2),
    );
    canvas.drawRRect(barRect, barPaint);

    // Redraw inner white circle to clip bar overflow
    canvas.drawCircle(center, innerR, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
