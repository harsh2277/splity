import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../expenses/dashboard_screen.dart';
import '../groups/groups_list_screen.dart';
import '../personal/personal_tracker_screen.dart';
import '../settings/profile_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;
  bool _isAddPressed = false;

  final List<Widget> _screens = const [
    DashboardScreen(),
    GroupsListScreen(),
    PersonalTrackerScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.primary400 : AppColors.primary600;

    return Scaffold(
      extendBody: true, // Allows screen content to extend behind bottom app bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildCenterAddButton(activeColor, isDark),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        child: Builder(
          builder: (builderContext) {
            return CustomPaint(
              painter: NotchedBarPainter(
                geometryListenable: Scaffold.geometryOf(builderContext),
                isDark: isDark,
                notchMargin: 8,
              ),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 12), // Compresses spacing on sides
                decoration: const BoxDecoration(),
                child: Row(
                  children: [
                    _buildNavItem(0, HugeIcons.strokeRoundedHome01, HugeIcons.strokeRoundedHome01, 'Home', activeColor, isDark),
                    _buildNavItem(1, HugeIcons.strokeRoundedUserGroup, HugeIcons.strokeRoundedUserGroup, 'Groups', activeColor, isDark),
                    const SizedBox(width: 90), // Precise space reservation for 68px notched FAB
                    _buildNavItem(2, HugeIcons.strokeRoundedUser, HugeIcons.strokeRoundedUser, 'Member', activeColor, isDark),
                    _buildNavItem(3, HugeIcons.strokeRoundedMoreHorizontal, HugeIcons.strokeRoundedMoreHorizontal, 'More', activeColor, isDark),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, List<List<dynamic>> outlineIcon, List<List<dynamic>> solidIcon, String label, Color activeColor, bool isDark) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active background pill capsule highlight for the icon with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack, // Playful premium bounce effect
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 18 : 8,
                vertical: isSelected ? 6 : 4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: isSelected ? 1.15 : 1.0,
                curve: Curves.easeOutBack,
                child: HugeIcon(
                  icon: isSelected ? solidIcon : outlineIcon,
                  color: isSelected
                      ? activeColor
                      : (isDark ? AppColors.neutral500 : AppColors.neutral400),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSelected ? 10.5 : 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? activeColor
                    : (isDark ? AppColors.neutral500 : AppColors.neutral400),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(Color activeColor, bool isDark) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isAddPressed = true),
      onTapUp: (_) => setState(() => _isAddPressed = false),
      onTapCancel: () => setState(() => _isAddPressed = false),
      onTap: () {
        // Trigger Add Expense action
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _isAddPressed ? 0.90 : 1.0,
        curve: Curves.easeOut,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.primary400, AppColors.primary500]
                  : [AppColors.primary500, AppColors.primary600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class NotchedBarPainter extends CustomPainter {
  final ValueListenable<ScaffoldGeometry> geometryListenable;
  final bool isDark;
  final double notchMargin;

  NotchedBarPainter({
    required this.geometryListenable,
    required this.isDark,
    required this.notchMargin,
  }) : super(repaint: geometryListenable);

  @override
  void paint(Canvas canvas, Size size) {
    final ScaffoldGeometry geometry = geometryListenable.value;

    final borderPaint = Paint()
      ..color = isDark ? AppColors.darkSurface3 : AppColors.neutral200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    if (geometry.floatingActionButtonArea == null || geometry.bottomNavigationBarTop == null) {
      canvas.drawLine(Offset.zero, Offset(size.width, 0), borderPaint);
      return;
    }

    final Rect? button = geometry.floatingActionButtonArea?.shift(
      Offset(0.0, -geometry.bottomNavigationBarTop!),
    );

    final Path path = const CircularNotchedRectangle().getOuterPath(
      Offset.zero & size,
      button?.inflate(notchMargin),
    );

    canvas.save();
    // Clip the canvas to exclude the left, right, and bottom strokes of the path
    canvas.clipRect(Rect.fromLTRB(1.0, -10.0, size.width - 1.0, size.height - 1.0));
    canvas.drawPath(path, borderPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NotchedBarPainter oldDelegate) => true;
}
