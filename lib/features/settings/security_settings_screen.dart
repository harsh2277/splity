import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _appLockEnabled = true;
  bool _biometricsEnabled = false;
  String _pinCode = '1234';

  void _showChangePinDialog() {
    final formKey = GlobalKey<FormState>();
    String newPin = '';
    String confirmPin = '';

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface2 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Change App PIN',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: isDark ? AppColors.neutral50 : AppColors.neutral900,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'New 4-digit PIN',
                    labelStyle: GoogleFonts.plusJakartaSans(),
                    hintText: 'e.g. 5678',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value == null || value.length != 4 || int.tryParse(value) == null) {
                      return 'Enter a valid 4-digit PIN';
                    }
                    newPin = value;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm PIN',
                    labelStyle: GoogleFonts.plusJakartaSans(),
                    hintText: 'Re-enter PIN',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  validator: (value) {
                    if (value != newPin) {
                      return 'PINs do not match';
                    }
                    confirmPin = value ?? '';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primary400 : AppColors.primary600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  setState(() {
                    _pinCode = newPin;
                  });
                  Navigator.pop(context);
                  AppSnackbar.success(
                    context,
                    'Security PIN updated successfully!',
                    showAtTop: true,
                  );
                }
              },
              child: Text(
                'Update PIN',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'App Lock & Security',
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage PIN, authentication, and security preferences to protect your transactions.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isDark ? c.neutral400 : c.neutral600,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Device authentication section
                _buildSectionHeader('Authentication', isDark, c),
                const SizedBox(height: 10),
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Column(
                    children: [
                      _buildToggleItem(
                        icon: HugeIcons.strokeRoundedShield01,
                        iconColor: isDark ? AppColors.primary400 : AppColors.primary600,
                        title: 'App Lock',
                        subtitle: 'Require PIN to open the Splity app',
                        value: _appLockEnabled,
                        onChanged: (val) => setState(() => _appLockEnabled = val),
                        isDark: isDark,
                      ),
                      if (_appLockEnabled) ...[
                        _buildDivider(isDark, c),
                        InkWell(
                          onTap: _showChangePinDialog,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppColors.info400 : AppColors.info600).withValues(alpha: isDark ? 0.2 : 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedSecurity,
                                    color: isDark ? AppColors.info400 : AppColors.info600,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Change App PIN',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Current PIN configured: ****',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.neutral500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: isDark ? c.neutral400 : c.neutral500,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      _buildDivider(isDark, c),
                      _buildToggleItem(
                        icon: HugeIcons.strokeRoundedSecurity,
                        iconColor: isDark ? AppColors.success400 : AppColors.success600,
                        title: 'Biometric Access',
                        subtitle: 'Use Face ID / Touch ID instead of PIN',
                        value: _biometricsEnabled,
                        onChanged: (val) => setState(() => _biometricsEnabled = val),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Connected devices Mock History (feels premium!)
                _buildSectionHeader('Authorized Devices', isDark, c),
                const SizedBox(height: 10),
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDeviceItem(
                          deviceName: 'iPhone 15 Pro Max (This device)',
                          location: 'Mumbai, India • Active now',
                          isCurrent: true,
                          isDark: isDark,
                          c: c,
                        ),
                        const SizedBox(height: 14),
                        _buildDeviceItem(
                          deviceName: 'MacBook Pro 16"',
                          location: 'Pune, India • Last login: Yesterday',
                          isCurrent: false,
                          isDark: isDark,
                          c: c,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, AppColorExtension c) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? c.neutral400 : c.neutral700,
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required List<List<dynamic>> icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
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
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: isDark ? AppColors.primary400 : AppColors.primary600,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem({
    required String deviceName,
    required String location,
    required bool isCurrent,
    required bool isDark,
    required AppColorExtension c,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? c.surface3 : AppColors.neutral100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedSmartPhone01,
            color: isDark ? c.neutral400 : c.neutral600,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success500.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Current',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.success500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDivider(bool isDark, AppColorExtension c) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: isDark ? c.surface3 : AppColors.neutral100,
    );
  }
}
