import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'expenses_provider.dart';
import '../personal/personal_tracker_screen.dart';

// Budget state provider – null means no budget set
final personalBudgetProvider = StateProvider<double?>((ref) => null);

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _cardPageController = PageController();
  int _currentCardIndex = 0;

  @override
  void dispose() {
    _cardPageController.dispose();
    super.dispose();
  }

  List<List<dynamic>> _getCategoryIcon(String category) {
    switch (category) {
      case 'food':
        return HugeIcons.strokeRoundedRestaurant;
      case 'travel':
        return HugeIcons.strokeRoundedCar01;
      case 'bills':
        return HugeIcons.strokeRoundedReceiptText;
      default:
        return HugeIcons.strokeRoundedGrid;
    }
  }

  Color _getCategoryColor(String category, bool isDark) {
    switch (category) {
      case 'food':
        return isDark ? AppColors.warning900 : AppColors.warning100;
      case 'travel':
        return isDark ? AppColors.info900 : AppColors.info100;
      case 'bills':
        return isDark ? AppColors.primary900 : AppColors.primary100;
      default:
        return isDark ? AppColors.neutral800 : AppColors.neutral100;
    }
  }

  Color _getCategoryIconColor(String category, bool isDark) {
    switch (category) {
      case 'food':
        return isDark ? AppColors.warning300 : AppColors.warning700;
      case 'travel':
        return isDark ? AppColors.info300 : AppColors.info700;
      case 'bills':
        return isDark ? AppColors.primary300 : AppColors.primary700;
      default:
        return isDark ? AppColors.neutral300 : AppColors.neutral600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activities = ref.watch(expensesProvider);
    // Only show non-personal items in recent activity
    final sharedActivities = activities.where((a) => !a.isPersonal).toList();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── HEADER SECTION ───────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good evening, Prem 👋',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Wednesday, June 3',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/user-profile'),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.primary400 : AppColors.primary600,
                              width: 1.5,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── CARD SLIDER (DUAL MODE) ───────────────────────────
              SliverPadding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: PageView(
                          controller: _cardPageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentCardIndex = index;
                            });
                          },
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _buildSharedBalanceCard(isDark),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: _buildPersonalBudgetCard(isDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentCardIndex == index ? 18 : 6,
                            decoration: BoxDecoration(
                              color: _currentCardIndex == index
                                  ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                  : (isDark ? AppColors.darkSurface3 : AppColors.neutral300),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // ── ALL GROUPS ───────────────────────────────────────
              _buildSectionHeader(context, isDark, 'Active Groups'),
              _buildQuickGroupsSection(isDark),

              // ── RECENT ACTIVITY HEADER ───────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Recent Activity',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                    ),
                  ),
                ),
              ),

              // ── RECENT ACTIVITY LIST ─────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? AppColors.darkSurface2 : AppColors.neutral200.withValues(alpha: 0.8),
                        width: 1,
                      ),
                    ),
                    child: sharedActivities.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedReceiptText,
                                  size: 36,
                                  color: isDark ? AppColors.neutral600 : AppColors.neutral300,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No recent activity',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.neutral500 : AppColors.neutral400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(8),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sharedActivities.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 1,
                              color: isDark ? AppColors.darkSurface2 : AppColors.neutral100,
                            ),
                            itemBuilder: (context, index) {
                              final item = sharedActivities[index];
                              final isOwed = item.isOwed;

                              Color amountColor;
                              String prefix = '';
                              if (isOwed) {
                                amountColor = AppColors.error500;
                                prefix = '-';
                              } else {
                                amountColor = AppColors.success500;
                                prefix = '+';
                              }

                              // Fix 3: Tap recent activity → go to history
                              return GestureDetector(
                                onTap: () => context.push('/history'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(item.category, isDark),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                          child: Center(
                                            child: HugeIcon(
                                              icon: _getCategoryIcon(item.category),
                                              color: _getCategoryIconColor(item.category, isDark),
                                              size: 20,
                                            ),
                                          ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.subtitle,
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
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$prefix${item.amount}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: amountColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.date,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10,
                                              color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),

              // ── UPCOMING SETTLE UP ───────────────────────────────
              _buildSectionHeader(context, isDark, 'Upcoming Settle Up'),
              _buildUpcomingSettleUpSection(isDark),

              // Fix 18: more bottom padding so last card isn't cropped
              const SliverPadding(padding: EdgeInsets.only(bottom: 160)),
            ],
          ),
        ),
      );
  }

  Widget _buildSharedBalanceCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shared Office Spends',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.neutral300 : AppColors.neutral600,
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedUserGroup,
                color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                size: 20,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Balance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹1,085.00',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Owed to you: ₹1,250.00',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'You owe: ₹165.00',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBudgetCard(bool isDark) {
    final budget = ref.watch(personalBudgetProvider);
    final bool hasBudget = budget != null;

    // FIX 1: Show empty state if no budget set
    if (!hasBudget) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedWallet02,
              color: isDark ? AppColors.neutral500 : AppColors.neutral400,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              'No personal budget set',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.neutral300 : AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Set a monthly limit to track your spending',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.neutral500 : AppColors.neutral500,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalTrackerScreen(autoEditLimit: true),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary400 : AppColors.primary600,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Set Budget',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    const double limit = 10000.00;
    const double spent = 6240.00;
    const double progress = spent / limit;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Budget',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.neutral300 : AppColors.neutral600,
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedWallet02,
                color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                size: 20,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spent this month',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹6,240.00',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                    ),
                  ),
                  Text(
                    'Limit: ₹10k',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '62.4% Used',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                    ),
                  ),
                  Text(
                    '₹3,760.00 Left',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.primary400 : AppColors.primary600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper to build headers for sections — Fix 19: uniform padding
  Widget _buildSectionHeader(BuildContext context, bool isDark, String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.neutral50 : AppColors.neutral900,
          ),
        ),
      ),
    );
  }

  // Fix 2: Active Groups — clickable, navigate to group details
  Widget _buildQuickGroupsSection(bool isDark) {
    final List<Map<String, dynamic>> groups = [
      {'id': '1', 'name': 'Office Chai ☕', 'members': '8 Members', 'balance': 'Owe ₹40.00'},
      {'id': '2', 'name': 'Friday Lunch 🍔', 'members': '5 Members', 'balance': 'Owed ₹450.00'},
      {'id': '3', 'name': 'Flatmates 🏠', 'members': '3 Members', 'balance': 'Settled'},
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: groups.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == groups.length) {
                return InkWell(
                  onTap: () {
                    // Trigger Create/Join Group action
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkSurface3 : AppColors.neutral300,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedAddCircle,
                          color: isDark ? AppColors.primary400 : AppColors.primary600,
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create/Join Group',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final g = groups[index];
              return GestureDetector(
                // Fix 2: Navigate to group details on tap
                onTap: () => context.push('/group-details/${g['id']}'),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        g['name'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        g['members'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                        ),
                      ),
                      Text(
                        g['balance'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: g['balance'].contains('Owed')
                              ? AppColors.success500
                              : g['balance'].contains('Owe')
                                  ? AppColors.error500
                                  : AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Upcoming Settle Up Widget
  Widget _buildUpcomingSettleUpSection(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: () => context.push('/member-details/2'),
          child: Container(
            padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.primary900.withValues(alpha: 0.4) : AppColors.primary100,
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedAgreement01,
                  color: isDark ? AppColors.primary400 : AppColors.primary600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settle with Rohit (Office Admin)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Office Chai Group • Pending payment',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹165.00',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You owe',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
