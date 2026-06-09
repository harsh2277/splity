import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int _expandedIndex = -1;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How is split amount calculated in Splity?',
      'answer': 'Splity splits expenses evenly among all selected group members by default. You can also customize weights, exact shares, or percentages during creation.'
    },
    {
      'question': 'Can I track my personal budget separately?',
      'answer': 'Yes! Splity has a built-in Personal Tracker tool in the More tab where you can log personal spends, set monthly limits, and keep them secure and private.'
    },
    {
      'question': 'Is my financial data secure?',
      'answer': 'Absolutely. Splity uses client-side encryption and offers App Lock settings (biometric/PIN) to keep all personal data safe on your device.'
    },
    {
      'question': 'How do I settle balances with group members?',
      'answer': 'Open the group, tap "Settle", select who you paid and the amount. Splity automatically adjusts group balances and marks it settled.'
    },
  ];

  List<Map<String, String>> get _filteredFaqs => _faqs;


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Help & Support',
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? c.neutral400 : c.neutral700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (_filteredFaqs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          'No FAQs found matching your query.',
                          style: GoogleFonts.plusJakartaSans(
                            color: c.neutral500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_filteredFaqs.length, (index) {
                      final faq = _filteredFaqs[index];
                      final isExpanded = _expandedIndex == index;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface2 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkSurface3 : AppColors.neutral200.withValues(alpha: 0.8),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            key: ValueKey(index),
                            initiallyExpanded: isExpanded,
                            title: Text(
                              faq['question']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? c.neutral50 : c.neutral900,
                              ),
                            ),
                            trailing: Icon(
                              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: isDark ? c.neutral400 : c.neutral500,
                            ),
                            onExpansionChanged: (expanding) {
                              setState(() {
                                _expandedIndex = expanding ? index : -1;
                              });
                            },
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Text(
                                  faq['answer']!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: isDark ? c.neutral400 : c.neutral600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 28),

                  Text(
                    'Need More Help?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? c.neutral400 : c.neutral700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Contact support options grouped premium layout
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
                        _buildSupportItem(
                          icon: HugeIcons.strokeRoundedChat01,
                          iconColor: isDark ? AppColors.primary400 : AppColors.primary600,
                          title: 'Live Chat',
                          subtitle: 'Typical reply within 5m',
                          onTap: () => context.push('/live-chat'),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, c),
                        _buildSupportItem(
                          icon: HugeIcons.strokeRoundedMailSend02,
                          iconColor: isDark ? AppColors.info400 : AppColors.info600,
                          title: 'Email Support',
                          subtitle: 'Response within 24h',
                          onTap: () => context.push('/email-support'),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark, c),
                        _buildSupportItem(
                          icon: HugeIcons.strokeRoundedInformationCircle,
                          iconColor: isDark ? AppColors.warning400 : AppColors.warning600,
                          title: 'Suggest Improvements',
                          subtitle: 'Need to improve this application?',
                          onTap: () => context.push('/suggest-improvement'),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem({
    required List<List<dynamic>> icon,
    required Color iconColor,
    required String title,
    required String subtitle,
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
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
          ],
        ),
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
