import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Expense Added',
      'body': 'Rahul Parmar added "Office Lunch buffet" in Office Shares. Your share is ₹320.00.',
      'time': 'Just now',
      'icon': HugeIcons.strokeRoundedReceiptText,
      'color': Color(0xFF3B82F6),
      'isRead': false,
    },
    {
      'title': 'Group Settlement',
      'body': 'Amit Shah settled balance with you of ₹1,085.00.',
      'time': '2 hours ago',
      'icon': HugeIcons.strokeRoundedCheckmarkCircle01,
      'color': Color(0xFF10B981),
      'isRead': false,
    },
    {
      'title': 'Budget Limit Warning',
      'body': 'You have spent 82% of your monthly personal budget. Remaining balance is ₹1,760.00.',
      'time': 'Yesterday',
      'icon': HugeIcons.strokeRoundedAlertCircle,
      'color': Color(0xFFF59E0B),
      'isRead': true,
    },
    {
      'title': 'New Member Added',
      'body': 'Prem Parmar invited Nehal Patel to join Trip Buddies.',
      'time': '3 days ago',
      'icon': HugeIcons.strokeRoundedUserGroup,
      'color': Color(0xFFEC4899),
      'isRead': true,
    },
    {
      'title': 'Payment Reminder',
      'body': 'Reminder: settle your pending balance of ₹450.00 with Rahul in Office Shares.',
      'time': '4 days ago',
      'icon': HugeIcons.strokeRoundedAlarmClock,
      'color': Color(0xFF8B5CF6),
      'isRead': true,
    },
  ];

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
    AppSnackbar.success(context, 'Notification history cleared');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Notifications',
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
        actions: [
          if (_notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: _clearAll,
                child: Text(
                  'Clear All',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.error500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? c.surface2 : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? c.surface3 : AppColors.neutral200,
                        ),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedNotification01,
                        size: 40,
                        color: isDark ? c.neutral500 : c.neutral400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? c.neutral50 : c.neutral900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We\'ll notify you when split activities happen.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: c.neutral500,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _notifications.length,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  final iconColor = item['color'] as Color;
                  final isUnread = !(item['isRead'] as bool);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? c.surface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isUnread
                            ? (isDark ? AppColors.primary400 : AppColors.primary600).withValues(alpha: 0.3)
                            : (isDark ? c.surface3 : const Color(0xFFE2E8F0)),
                        width: isUnread ? 1.5 : 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _notifications[index]['isRead'] = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: HugeIcon(
                                icon: item['icon'] as List<List<dynamic>>,
                                color: iconColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['title'] as String,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? c.neutral50 : c.neutral900,
                                        ),
                                      ),
                                      Text(
                                        item['time'] as String,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: c.neutral500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['body'] as String,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: isDark ? c.neutral400 : c.neutral600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
