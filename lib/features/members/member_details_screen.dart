import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import 'members_provider.dart';

class MemberDetailsScreen extends ConsumerStatefulWidget {
  final String memberId;

  const MemberDetailsScreen({super.key, required this.memberId});

  @override
  ConsumerState<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends ConsumerState<MemberDetailsScreen> {
  int _activeTab = 0; // 0: History, 1: Details

  Future<void> _launchUPIPayment(BuildContext context, String payeeName, double amount) async {
    final upiUri = Uri.parse(
      'upi://pay?pa=splity@upi&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR'
    );
    try {
      if (await canLaunchUrl(upiUri)) {
        await launchUrl(upiUri, mode: LaunchMode.externalApplication);
        ref.read(membersProvider.notifier).settleMember(widget.memberId);
      } else {
        AppSnackbar.error(
          context,
          'No UPI apps installed on this device.',
          showAtTop: true,
        );
      }
    } catch (e) {
      AppSnackbar.error(
        context,
        'Could not launch UPI payment: $e',
        showAtTop: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    final members = ref.watch(membersProvider);
    final member = members.firstWhere(
      (m) => m.id == widget.memberId,
      orElse: () => Member(
        id: '0',
        name: 'Member Not Found',
        email: '',
        avatar: '👤',
        balance: 'Settled Up',
        status: 'settled',
        amount: 0.0,
        history: [],
      ),
    );

    if (member.id == '0') {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Member does not exist.')),
      );
    }

    Color balanceColor = const Color(0xFF10B981); // emerald green
    String standingText = 'Owes you';
    if (member.status == 'settled') {
      balanceColor = isDark ? c.neutral400 : c.neutral600;
      standingText = 'Settled';
    } else if (member.status == 'owe') {
      balanceColor = const Color(0xFFEF4444); // rose red
      standingText = 'You owe';
    }

    final cleanAmount = '₹${member.amount.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member Header Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar circle
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkSurface3 : AppColors.neutral100,
                        ),
                        child: Center(
                          child: Text(
                            member.avatar,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Name and Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              member.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: isDark ? c.neutral50 : c.neutral900,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              member.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? c.neutral500 : c.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Balance column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            standingText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? c.neutral500 : c.neutral500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            cleanAmount,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: balanceColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action buttons grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    label: 'Settle Up',
                    icon: HugeIcons.strokeRoundedMoneySend02,
                    // Fix 7 & Fix 8: Show payment apps if 'owe', disabled if 'owed' or 'settled'
                    onTap: () => _launchUPIPayment(context, member.name, member.amount),
                    isDark: isDark,
                    c: c,
                    // Fix 8: disable if owed to you (you don't need to pay) or settled
                    isEnabled: member.status == 'owe',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionBtn(
                    label: 'Remind',
                    icon: HugeIcons.strokeRoundedNotification01,
                    onTap: () {
                      AppSnackbar.success(
                        context,
                        'Sent request reminder to ${member.name}!',
                        showAtTop: true,
                      );
                    },
                    isDark: isDark,
                    c: c,
                    isEnabled: member.status == 'owed',
                  ),
                ),
              ],
            ),
          ),

          // Sliding Segmented Tab Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? c.surface : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                    alignment: _activeTab == 0 ? Alignment.centerLeft : Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? c.surface3 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 0),
                          behavior: HitTestBehavior.opaque,
                          child: _buildTabSegmentText('History', _activeTab == 0, isDark, c),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 1),
                          behavior: HitTestBehavior.opaque,
                          child: _buildTabSegmentText('Details', _activeTab == 1, isDark, c),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Screen Content View switcher
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _activeTab == 0
                  ? _buildHistoryView(member.history, isDark, c)
                  : Align(
                      alignment: Alignment.topCenter,
                      child: _buildDetailsView(member, isDark, c),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSegmentText(String label, bool isActive, bool isDark, AppColorExtension c) {
    return Center(
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive
              ? (isDark ? c.neutral50 : c.neutral900)
              : (isDark ? c.neutral500 : c.neutral500),
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required List<List<dynamic>> icon,
    required VoidCallback onTap,
    required bool isDark,
    required AppColorExtension c,
    bool isEnabled = true,
  }) {
    final borderClr = isDark ? c.surface3 : const Color(0xFFE2E8F0);
    final textClr = isDark ? c.neutral200 : c.neutral700;

    return Material(
      color: isDark ? c.surface : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.45,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderClr),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(icon: icon, size: 20, color: isDark ? c.primary400 : c.primary600),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textClr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryView(List<MemberTransaction> history, bool isDark, AppColorExtension c) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedReceiptText,
              size: 48,
              color: isDark ? AppColors.neutral600 : AppColors.neutral300,
            ),
            const SizedBox(height: 12),
            Text(
              'No shared history yet',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: isDark ? c.neutral500 : c.neutral400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final tx = history[index];
        final isPending = tx.status == 'Pending Approval';

        IconData categoryIcon = Icons.fastfood_rounded;
        Color iconColor = const Color(0xFFF59E0B);
        if (tx.category == 'Travel') {
          categoryIcon = Icons.directions_car_rounded;
          iconColor = const Color(0xFF3B82F6);
        } else if (tx.category == 'Dining') {
          categoryIcon = Icons.restaurant_rounded;
          iconColor = const Color(0xFFEC4899);
        } else if (tx.category == 'Others') {
          categoryIcon = Icons.category_rounded;
          iconColor = const Color(0xFF10B981);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? c.surface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? c.surface3 : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.01),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: iconColor.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Icon(
                    categoryIcon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tx.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: isDark ? c.neutral50 : c.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.youPaid ? 'You paid • ${tx.date}' : 'They paid • ${tx.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? c.neutral500 : c.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tx.amount,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? c.neutral50 : c.neutral900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppBadge(
                    label: isPending ? 'Pending' : 'Approved',
                    type: isPending ? AppBadgeType.warning : AppBadgeType.success,
                    size: AppBadgeSize.sm,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsView(Member member, bool isDark, AppColorExtension c) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? c.surface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? c.surface3 : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Details',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isDark ? c.neutral50 : c.neutral900,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: HugeIcons.strokeRoundedUser,
              label: 'Full Name',
              value: member.name,
              isDark: isDark,
              c: c,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: HugeIcons.strokeRoundedMailAtSign01,
              label: 'Email Address',
              value: member.email,
              isDark: isDark,
              c: c,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: HugeIcons.strokeRoundedShield01,
              label: 'Splity ID',
              value: 'SPLITY-${member.id}00${member.name.length}',
              isDark: isDark,
              c: c,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required List<List<dynamic>> icon,
    required String label,
    required String value,
    required bool isDark,
    required AppColorExtension c,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDark ? c.primary400 : c.primary600).withValues(alpha: 0.12),
          ),
          child: HugeIcon(
            icon: icon,
            color: isDark ? c.primary400 : c.primary600,
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
                  color: isDark ? c.neutral500 : c.neutral500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? c.neutral50 : c.neutral900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
