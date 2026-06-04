import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String _userName = 'Prem Parmar';
  final String _userEmail = 'prem.parmar@officeshare.com';
  final String _userPhone = '+91 98765 43210';
  String _upiId = 'premparmar@paytm';
  bool _isEditingUpi = false;
  late TextEditingController _upiController;

  @override
  void initState() {
    super.initState();
    _upiController = TextEditingController(text: _upiId);
  }

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.neutral50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TITLE ───────────────────────────────────────────
                Text(
                  'Profile',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 24),

                // ── AVATAR CARD ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface3 : AppColors.neutral200.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.primary400 : AppColors.primary600,
                                width: 3,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 48,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primary400 : AppColors.primary600,
                                shape: BoxShape.circle,
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedCamera01,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _userName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userPhone,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── UPI ID CARD ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface3 : AppColors.neutral200.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.success900.withValues(alpha: 0.4) : AppColors.success100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedQrCode,
                          color: isDark ? AppColors.success400 : AppColors.success600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your UPI ID',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _isEditingUpi
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _upiController,
                                          autofocus: true,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                                          ),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                                            border: UnderlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle02, color: AppColors.success500, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _upiId = _upiController.text;
                                            _isEditingUpi = false;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : Text(
                                    _upiId,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      if (!_isEditingUpi)
                        IconButton(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedPencilEdit01,
                            color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isEditingUpi = true;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── SETTINGS & MORE SECTION ─────────────────────────
                Text(
                  'Settings & Preferences',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.neutral400 : AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface3 : AppColors.neutral200.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: HugeIcons.strokeRoundedNotification01,
                        iconColor: isDark ? AppColors.primary400 : AppColors.primary600,
                        title: 'Notifications',
                        subtitle: 'Push notifications & reminders',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () {},
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingItem(
                        icon: HugeIcons.strokeRoundedMoon02,
                        iconColor: isDark ? AppColors.info400 : AppColors.info600,
                        title: 'Dark Mode',
                        subtitle: 'Toggle app theme',
                        trailing: Switch(
                          value: isDark,
                          onChanged: (value) {
                            // Handled by user toggling theme via system setting or config
                          },
                          activeColor: AppColors.primary400,
                        ),
                        onTap: () {},
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingItem(
                        icon: HugeIcons.strokeRoundedShield01,
                        iconColor: isDark ? AppColors.warning400 : AppColors.warning600,
                        title: 'App Lock & Security',
                        subtitle: 'Biometric authorization',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () {},
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingItem(
                        icon: HugeIcons.strokeRoundedHelpCircle,
                        iconColor: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        title: 'Help & Support',
                        subtitle: 'FAQs, contact us, guidebooks',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () {},
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingItem(
                        icon: HugeIcons.strokeRoundedLogout01,
                        iconColor: AppColors.error500,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required List<List<dynamic>> icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: HugeIcon(icon: icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: isDark ? AppColors.darkSurface3 : AppColors.neutral100,
    );
  }
}
