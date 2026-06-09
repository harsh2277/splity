import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import '../../main.dart'; // import themeModeProvider

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _expenseAdded = true;
  bool _billSettled = true;
  bool _budgetAlerts = true;
  bool _reminders = true;
  String _selectedCurrency = 'INR (₹)';
  String _selectedLanguage = 'English (US)';

  void _showCustomDropdown<T>({
    required String title,
    required T currentValue,
    required List<AppDropdownItem<T>> items,
    required ValueChanged<T> onChanged,
  }) {
    final c = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? c.surface2 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? c.neutral50 : c.neutral900,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.value == currentValue;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      title: Text(
                        item.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? AppColors.primary400 : AppColors.primary600)
                              : (isDark ? c.neutral50 : c.neutral900),
                        ),
                      ),
                      trailing: isSelected
                          ? HugeIcon(
                              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                              color: isDark ? AppColors.primary400 : AppColors.primary600,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        onChanged(item.value);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true, // Fix 15
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
                // Theme preferences section
                _buildSectionHeader('Appearance', isDark, c),
                const SizedBox(height: 10),
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.info400 : AppColors.info600).withValues(alpha: isDark ? 0.2 : 0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: HugeIcon(
                            icon: isDark ? HugeIcons.strokeRoundedMoon02 : HugeIcons.strokeRoundedSun01,
                            color: isDark ? AppColors.info400 : AppColors.warning500,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Mode',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isDark ? 'Dark theme active' : 'Light theme active',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, fontWeight: FontWeight.w500,
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Fix 16: Animated segmented toggle
                        GestureDetector(
                          onTap: () {
                            ref.read(themeModeProvider.notifier).state =
                                isDark ? ThemeMode.light : ThemeMode.dark;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 60,
                            height: 32,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.primary900 : AppColors.neutral200,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? AppColors.primary400 : AppColors.neutral300,
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubic,
                                  alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.primary400 : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                      size: 14,
                                      color: isDark ? Colors.white : AppColors.warning500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Localization preferences
                _buildSectionHeader('Preferences', isDark, c),
                const SizedBox(height: 10),
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showCustomDropdown<String>(
                            title: 'Select Currency',
                            currentValue: _selectedCurrency,
                            items: const [
                              AppDropdownItem(value: 'INR (₹)', label: 'INR (₹)'),
                              AppDropdownItem(value: 'USD (\$)', label: 'USD (\$)'),
                              AppDropdownItem(value: 'EUR (€)', label: 'EUR (€)'),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedCurrency = val);
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isDark ? AppColors.primary400 : AppColors.primary600).withValues(alpha: isDark ? 0.2 : 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCoins01,
                                  color: isDark ? AppColors.primary400 : AppColors.primary600,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Default Currency',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Configure preferred billing symbol',
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedCurrency,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? c.neutral100 : c.neutral800,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isDark ? c.neutral400 : c.neutral600,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildDivider(isDark, c),
                      GestureDetector(
                        onTap: () {
                          _showCustomDropdown<String>(
                            title: 'Select Language',
                            currentValue: _selectedLanguage,
                            items: const [
                              AppDropdownItem(value: 'English (US)', label: 'English (US)'),
                              AppDropdownItem(value: 'Hindi (IN)', label: 'Hindi (IN)'),
                              AppDropdownItem(value: 'Gujarati (IN)', label: 'Gujarati (IN)'),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedLanguage = val);
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isDark ? AppColors.warning400 : AppColors.warning600).withValues(alpha: isDark ? 0.2 : 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedGlobal,
                                  color: isDark ? AppColors.warning400 : AppColors.warning600,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Language',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Change UI language',
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedLanguage,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? c.neutral100 : c.neutral800,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isDark ? c.neutral400 : c.neutral600,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Notification preferences section
                _buildSectionHeader('Notification Preferences', isDark, c),
                const SizedBox(height: 10),
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Column(
                    children: [
                      _buildToggleItem(
                        icon: HugeIcons.strokeRoundedReceiptText,
                        iconColor: isDark ? AppColors.primary400 : AppColors.primary600,
                        title: 'New Split Spends',
                        subtitle: 'When someone logs a split spend',
                        value: _expenseAdded,
                        onChanged: (val) => setState(() => _expenseAdded = val),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark, c),
                      _buildToggleItem(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                        iconColor: isDark ? AppColors.success400 : AppColors.success600,
                        title: 'Settlement Updates',
                        subtitle: 'When balances are marked settled',
                        value: _billSettled,
                        onChanged: (val) => setState(() => _billSettled = val),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark, c),
                      _buildToggleItem(
                        icon: HugeIcons.strokeRoundedAlertCircle,
                        iconColor: isDark ? AppColors.warning400 : AppColors.warning600,
                        title: 'Budget Limits',
                        subtitle: 'Approaching or exceeding personal limits',
                        value: _budgetAlerts,
                        onChanged: (val) => setState(() => _budgetAlerts = val),
                        isDark: isDark,
                      ),
                      _buildDivider(isDark, c),
                      _buildToggleItem(
                        icon: HugeIcons.strokeRoundedAlarmClock,
                        iconColor: isDark ? AppColors.neutral400 : AppColors.neutral600,
                        title: 'Reminders',
                        subtitle: 'Reminders to settle pending balances',
                        value: _reminders,
                        onChanged: (val) => setState(() => _reminders = val),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Save banner
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.success500 : AppColors.success600).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isDark ? AppColors.success400 : AppColors.success600).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: isDark ? AppColors.success400 : AppColors.success600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'All changes auto-saved',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.success400 : AppColors.success600,
                          ),
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
