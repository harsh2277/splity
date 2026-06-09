import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final String _userName = 'Prem Parmar';
  final String _userEmail = 'prem.parmar@officeshare.com';
  final String _userPhone = '+91 98765 43210';
  final String _upiId = 'premparmar@paytm';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? c.neutral50 : c.neutral900,
        leadingWidth: 90,
        leading: InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? c.neutral200 : c.neutral700,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Back',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? c.neutral200 : c.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ),

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Block
                Center(
                  child: Column(
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
                          radius: 50,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _userName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? c.neutral50 : c.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: c.neutral500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Personal Information',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? c.neutral400 : c.neutral700,
                  ),
                ),
                const SizedBox(height: 12),

                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Column(
                    children: [
                      _buildDetailRow('Full Name', _userName, HugeIcons.strokeRoundedUser, isDark, c),
                      _buildDivider(isDark, c),
                      _buildDetailRow('Email Address', _userEmail, HugeIcons.strokeRoundedMailAtSign01, isDark, c),
                      _buildDivider(isDark, c),
                      _buildDetailRow('Phone Number', _userPhone, HugeIcons.strokeRoundedSmartPhone01, isDark, c),
                      _buildDivider(isDark, c),
                      _buildDetailRow('UPI Payment ID', _upiId, HugeIcons.strokeRoundedQrCode01, isDark, c),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                AppButton(
                  label: 'Edit Profile Information',
                  variant: AppButtonVariant.primary,
                  hasShadow: false,
                  onPressed: () => context.push('/edit-profile'),
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    List<List<dynamic>> icon,
    bool isDark,
    AppColorExtension c,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? c.neutral800 : AppColors.neutral100).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: HugeIcon(
              icon: icon,
              color: isDark ? c.neutral300 : c.neutral600,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.neutral500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? c.neutral50 : c.neutral900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark, AppColorExtension c) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 58,
      endIndent: 16,
      color: isDark ? c.surface3 : AppColors.neutral100,
    );
  }
}
