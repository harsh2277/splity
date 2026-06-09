import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../personal/personal_tracker_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.neutral50,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── TITLE ───────────────────────────────────────────
                Text(
                  'More',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 20),

                // ── STATS ROW ───────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Shared Spends',
                        value: '₹1,085.00',
                        color: const Color(0xFF10B981),
                        icon: HugeIcons.strokeRoundedUserGroup,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Personal Spent',
                        value: '₹6,240.00',
                        color: isDark ? AppColors.neutral200 : AppColors.neutral800,
                        icon: HugeIcons.strokeRoundedWallet02,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── SPLITY FEATURES SECTION ─────────────────────────
                Text(
                  'Splity Features',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.neutral400 : AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 10),
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
                        icon: HugeIcons.strokeRoundedReceiptText,
                        iconColor: isDark ? AppColors.primary400 : AppColors.primary600,
                        title: 'Transaction History',
                        subtitle: 'Consolidated list of all spends',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () => context.push('/history'),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingItem(
                        icon: HugeIcons.strokeRoundedWallet02,
                        iconColor: isDark ? AppColors.info400 : AppColors.info600,
                        title: 'Personal Tracker',
                        subtitle: 'Manage your personal budget & tracker',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PersonalTrackerScreen(),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── PREFERENCES & SUPPORT ─────────────────────────
                Text(
                  'Preferences & Support',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.neutral400 : AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 10),
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
                        subtitle: 'Notification log & alerts history',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () => context.push('/notifications'),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingItem(
                        icon: HugeIcons.strokeRoundedSettings01,
                        iconColor: isDark ? AppColors.primary400 : AppColors.primary600,
                        title: 'Settings',
                        subtitle: 'Theme preference & notification preferences',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () => context.push('/settings'),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingItem(
                        icon: HugeIcons.strokeRoundedHelpCircle,
                        iconColor: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        title: 'Help & Support',
                        subtitle: 'FAQs, contact us, guidebooks',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () => context.push('/help-support'),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _buildSettingItem(
                        icon: HugeIcons.strokeRoundedLogout01,
                        iconColor: AppColors.error500,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
                        onTap: () {
                          // Mock logout
                        },
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required List<List<dynamic>> icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkSurface3 : AppColors.neutral200.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                ),
              ),
              HugeIcon(
                icon: icon,
                color: isDark ? AppColors.neutral500 : AppColors.neutral400,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
