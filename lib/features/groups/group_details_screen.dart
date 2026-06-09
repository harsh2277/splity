import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import 'groups_provider.dart';
import 'group_success_screen.dart';

class GroupDetailsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> {
  int _activeTab = 0; // 0: Timeline, 1: Standings

  final List<LinearGradient> _presetGradients = const [
    LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'office':
        return Iconsax.briefcase;
      case 'home':
        return Iconsax.home;
      case 'travel':
        return Iconsax.routing;
      default:
        return Iconsax.element_4;
    }
  }

  IconData _getPresetIconData(String name) {
    switch (name) {
      case 'briefcase':
        return Iconsax.briefcase;
      case 'home':
        return Iconsax.home;
      case 'routing':
        return Iconsax.routing;
      case 'coffee':
        return Iconsax.coffee;
      case 'shopping_bag':
        return Iconsax.shopping_bag;
      case 'car':
        return Iconsax.car;
      case 'game':
        return Iconsax.game;
      case 'wallet_3':
        return Iconsax.wallet_3;
      default:
        return Iconsax.element_4;
    }
  }

  void _showInviteQrSheet(BuildContext context, Group group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      showDragHandle: false,
      builder: (context) {
        return GroupSuccessSheet(
          groupName: group.name,
          inviteCode: group.inviteCode,
          onClose: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // Fix 5 & 6: Settle Up bottom sheet
  Future<void> _launchUPIPayment(BuildContext context, String payeeName, double amount) async {
    final upiUri = Uri.parse(
      'upi://pay?pa=splity@upi&pn=${Uri.encodeComponent(payeeName)}&am=${amount.toStringAsFixed(2)}&cu=INR'
    );
    try {
      if (await canLaunchUrl(upiUri)) {
        await launchUrl(upiUri, mode: LaunchMode.externalApplication);
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

  Widget _buildPaymentAppRow({
    required bool isDark,
    required dynamic c,
    required VoidCallback onClose,
  }) {
    final apps = [
      {'name': 'GPay', 'color': const Color(0xFF4285F4), 'emoji': '🔵'},
      {'name': 'PhonePe', 'color': const Color(0xFF5F259F), 'emoji': '🟣'},
      {'name': 'Paytm', 'color': const Color(0xFF002970), 'emoji': '🔷'},
      {'name': 'BHIM', 'color': const Color(0xFF1A237E), 'emoji': '🇮🇳'},
      {'name': 'Bank Transfer', 'color': const Color(0xFF0D9488), 'emoji': '🏦'},
    ];

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: apps.map((app) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                AppSnackbar.success(
                  context,
                  'Opening ${app['name']} to pay...',
                  showAtTop: true,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? c.surface2 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? c.surface3 : c.neutral200,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      app['emoji'] as String,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      app['name'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? c.neutral300 : c.neutral700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          hasShadow: false,
          onPressed: onClose,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    final groups = ref.watch(groupsProvider);
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(
        id: '0',
        name: 'Group Not Found',
        companyName: '',
        type: 'Other',
        inviteCode: '',
        approvalRequired: false,
        membersCount: 0,
        balance: '',
      ),
    );

    if (group.id == '0') {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Group does not exist.')),
      );
    }

    final hasFileImage = group.imageUrl != null && File(group.imageUrl!).existsSync();
    final gradientIndex = int.tryParse(group.id) != null
        ? (int.parse(group.id) % _presetGradients.length)
        : 0;

    // Balance Theme Calculations
    Color balanceColor = const Color(0xFF10B981); // emerald green
    String standingText = 'You are owed';
    if (group.balance == 'Settled') {
      balanceColor = isDark ? c.neutral400 : c.neutral600;
      standingText = 'Settled';
    } else if (group.balance.contains('Owe')) {
      balanceColor = const Color(0xFFEF4444); // rose red
      standingText = 'You owe';
    }

    final cleanAmount = group.balance == 'Settled'
        ? '₹0.00'
        : group.balance.replaceAll('Owe ', '').replaceAll('Owed ', '');

    final List<Map<String, String>> members = [
      {'name': 'Prem Parmar', 'role': 'Creator', 'avatar': '👨‍💻', 'standing': 'You are owed ₹450.00', 'status': 'owed', 'ratio': '0.7'},
      {'name': 'Aman Gupta', 'role': 'Member', 'avatar': '🦁', 'standing': 'Owes ₹120.00', 'status': 'owe', 'ratio': '0.2'},
      {'name': 'Rohit Sen', 'role': 'Admin', 'avatar': '🦊', 'standing': 'Owes ₹330.00', 'status': 'owe', 'ratio': '0.3'},
      {'name': 'Dev Patel', 'role': 'Member', 'avatar': '🐙', 'standing': 'Settled Up', 'status': 'settled', 'ratio': '1.0'},
    ];

    final List<Map<String, dynamic>> groupExpenses = [
      {
        'title': 'Chai & Samosas',
        'buyer': 'Aman Gupta',
        'amount': '₹120.00',
        'date': 'Today, 11:30 AM',
        'status': 'Pending Approval',
        'category': 'Food',
      },
      {
        'title': 'Team Lunch (Burger King)',
        'buyer': 'Prem Parmar',
        'amount': '₹850.00',
        'date': 'Yesterday, 2:00 PM',
        'status': 'Approved',
        'category': 'Dining',
      },
    ];

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
                  Iconsax.arrow_left_2_copy,
                  color: isDark ? c.neutral200 : c.neutral700,
                  size: 20,
                ),
                const SizedBox(width: 4),
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
          // ── HOME PAGE STYLE CARD FOR THE TOP SECTION ──
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
                      // Squircle Category Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: hasFileImage ? null : _presetGradients[gradientIndex],
                          image: hasFileImage
                              ? DecorationImage(
                                  image: FileImage(File(group.imageUrl!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: hasFileImage
                            ? null
                            : Center(
                                child: Icon(
                                  group.imageUrl != null && group.imageUrl!.startsWith('preset_icon:')
                                      ? _getPresetIconData(group.imageUrl!.replaceAll('preset_icon:', ''))
                                      : _getTypeIcon(group.type),
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                      ),
                      const SizedBox(width: 14),
                      // Name & Company Details Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              group.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 17.5,
                                color: isDark ? c.neutral50 : c.neutral900,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${group.companyName} • ${group.type}',
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
                      // Balance & Standing column
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
                              letterSpacing: 0.2,
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
                  // Divider
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: AppDivider(),
                  ),
                  // Detailed Group Info (Invite Code and Category)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: group.inviteCode));
                          AppSnackbar.success(
                            context,
                            'Invite code copied to clipboard!',
                            showAtTop: true,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.copy,
                              size: 14,
                              color: isDark ? c.neutral400 : c.neutral500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Code: ${group.inviteCode}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? c.neutral300 : c.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(group.type),
                            size: 14,
                            color: isDark ? c.neutral400 : c.neutral500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            group.type,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? c.neutral300 : c.neutral600,
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

          // ── BALANCED TRIPLE ACTION GRID ROW ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionGridBtn(
                    label: 'Add Expense',
                    icon: Iconsax.add,
                    // Fix 4: Navigate to add expense screen with groupId
                    onTap: () => context.push('/add-expense?groupId=${group.id}'),
                    isDark: isDark,
                    c: c,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionGridBtn(
                    label: 'Settle Up',
                    icon: Iconsax.card_send_copy,
                    // Fix 5/6: Launch native mobile default UPI apps chooser
                    onTap: () {
                      final double amountVal = double.tryParse(cleanAmount.replaceAll('₹', '').replaceAll(',', '').trim()) ?? 0.0;
                      _launchUPIPayment(context, group.name, amountVal);
                    },
                    isDark: isDark,
                    c: c,
                    isEnabled: group.balance != 'Settled',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionGridBtn(
                    label: 'Invite QR',
                    icon: Iconsax.user_add_copy,
                    onTap: () => _showInviteQrSheet(context, group),
                    isDark: isDark,
                    c: c,
                  ),
                ),
              ],
            ),
          ),

          // ── PREMIUM SLIDING SEGMENTED CONTROL ──
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
                  // Sliding indicator background
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
                  // Tab items
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 0),
                          behavior: HitTestBehavior.opaque,
                          child: _buildTabSegmentText('History', _activeTab == 0, groupExpenses.length, isDark, c),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 1),
                          behavior: HitTestBehavior.opaque,
                          child: _buildTabSegmentText('Members', _activeTab == 1, members.length, isDark, c),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── ANIMATED SWITCHABLE CONTENT TIMELINE & STANDINGS ──
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(0.06, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                );
              },
              child: _activeTab == 0
                  ? _buildTimelineView(groupExpenses, isDark, c, key: const ValueKey(0))
                  : _buildStandingsView(members, isDark, c, key: const ValueKey(1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView(List<Map<String, dynamic>> expenses, bool isDark, AppColorExtension c, {required Key key}) {
    return ListView.builder(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final exp = expenses[index];
        final isPending = exp['status'] == 'Pending Approval';
        final category = exp['category'] ?? 'Food';

        IconData categoryIcon = Iconsax.receipt_2;
        Color iconColor = isDark ? c.primary400 : c.primary600;
        if (category == 'Food') {
          categoryIcon = Iconsax.coffee;
          iconColor = const Color(0xFFF59E0B);
        } else if (category == 'Dining') {
          categoryIcon = Iconsax.shop;
          iconColor = const Color(0xFF3B82F6);
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
                color: Colors.black.withValues(alpha: isDark ? 0.06 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // Premium Squircle Category Icon with background gradient/color wash
              Container(
                width: 46,
                height: 46,
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
              // Transaction Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      exp['title'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: isDark ? c.neutral50 : c.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paid by ${exp['buyer']} • ${exp['date']}',
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
              // Amount and Status Badge Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exp['amount'],
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

  Widget _buildStandingsView(List<Map<String, String>> membersList, bool isDark, AppColorExtension c, {required Key key}) {
    return ListView.builder(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: membersList.length,
      itemBuilder: (context, index) {
        final m = membersList[index];
        final status = m['status'] ?? 'settled';

        final List<LinearGradient> avatarGradients = const [
          LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ];
        final hash = m['name']!.codeUnits.fold(0, (a, b) => a + b);
        final gradient = avatarGradients[hash % avatarGradients.length];

        Color themeColor = isDark ? c.neutral400 : c.neutral600;
        String balanceLabel = 'Settled';
        String cleanAmount = '₹0.00';
        if (status == 'owed') {
          themeColor = const Color(0xFF10B981);
          balanceLabel = 'Owed to you';
          final amount = m['standing']!.replaceAll(RegExp(r'[^0-9.]'), '');
          cleanAmount = amount.isNotEmpty ? '₹$amount' : '₹0.00';
        } else if (status == 'owe') {
          themeColor = const Color(0xFFEF4444);
          balanceLabel = 'You owe';
          final amount = m['standing']!.replaceAll(RegExp(r'[^0-9.]'), '');
          cleanAmount = amount.isNotEmpty ? '₹$amount' : '₹0.00';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? c.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? c.surface3 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Initials Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gradient,
                ),
                alignment: Alignment.center,
                child: Text(
                  _getInitials(m['name']!),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Member details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      m['name']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: isDark ? c.neutral50 : c.neutral900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      m['role'] == 'Creator' ? 'Owner' : 'Member',
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
              // Financial Balance Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    balanceLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? c.neutral500 : c.neutral500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cleanAmount,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionGridBtn({
    required String label,
    required IconData icon,
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
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderClr),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: isDark ? c.primary400 : c.primary600),
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

  Widget _buildTabSegmentText(String label, bool isActive, int count, bool isDark, AppColorExtension c) {
    final activeColor = isDark ? c.neutral50 : c.neutral900;
    final inactiveColor = isDark ? c.neutral500 : c.neutral400;

    return Center(
      child: AnimatedScale(
        scale: isActive ? 1.0 : 0.96,
        duration: const Duration(milliseconds: 200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark ? c.background : const Color(0xFFF1F5F9))
                    : (isDark ? c.surface3 : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0].substring(0, words[0].length.clamp(1, 2)).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
