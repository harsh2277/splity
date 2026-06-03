import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _cardPageController = PageController();
  int _currentCardIndex = 0;

  // Mock data for recent activities
  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Chai & Samosa',
      'subtitle': 'Office Chai Group • Paid by Aman',
      'amount': '₹45.00',
      'isOwed': true,
      'isPersonal': false,
      'category': 'food',
      'date': 'Today, 4:30 PM',
    },
    {
      'title': 'Uber ride to Client Office',
      'subtitle': 'Personal Log',
      'amount': '₹240.00',
      'isOwed': false,
      'isPersonal': true,
      'category': 'travel',
      'date': 'Today, 2:15 PM',
    },
    {
      'title': 'Team Lunch (Pizza)',
      'subtitle': 'Paid by You • Split equally',
      'amount': '₹1,250.00',
      'isOwed': false,
      'isPersonal': false,
      'category': 'food',
      'date': 'Yesterday, 1:10 PM',
    },
    {
      'title': 'Monthly Internet subscription',
      'subtitle': 'Personal Log',
      'amount': '₹799.00',
      'isOwed': false,
      'isPersonal': true,
      'category': 'bills',
      'date': '1 Jun 2026',
    },
    {
      'title': 'Printouts & Stationery',
      'subtitle': 'Office Admin • Paid by Rohit',
      'amount': '₹120.00',
      'isOwed': true,
      'isPersonal': false,
      'category': 'other',
      'date': '30 May 2026',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardPageController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.directions_car;
      case 'bills':
        return Icons.receipt_long;
      default:
        return Icons.category;
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

    return Scaffold(
      body: SafeArea(
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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: isDark ? AppColors.neutral50 : AppColors.neutral900,
                          unselectedLabelColor: isDark ? AppColors.neutral500 : AppColors.neutral600,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: isDark ? AppColors.darkSurface3 : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          tabs: const [
                            Tab(text: 'All'),
                            Tab(text: 'Shared'),
                            Tab(text: 'Personal'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── RECENT ACTIVITY LIST ─────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      // Filter list based on selected tab index
                      final filteredList = _activities.where((activity) {
                        if (_tabController.index == 1) return !activity['isPersonal'];
                        if (_tabController.index == 2) return activity['isPersonal'];
                        return true;
                      }).toList();

                      if (filteredList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'No transactions found',
                              style: TextStyle(
                                color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
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
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: isDark ? AppColors.darkSurface2 : AppColors.neutral100,
                          ),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final isPersonal = item['isPersonal'];
                            final isOwed = item['isOwed'];
                            
                            Color amountColor;
                            String prefix = '';
                            if (isPersonal) {
                              amountColor = isDark ? AppColors.neutral300 : AppColors.neutral800;
                            } else if (isOwed) {
                              amountColor = AppColors.error500;
                              prefix = '-';
                            } else {
                              amountColor = AppColors.success500;
                              prefix = '+';
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(item['category'], isDark),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(item['category']),
                                      color: _getCategoryIconColor(item['category'], isDark),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'],
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
                                          item['subtitle'],
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
                                        '$prefix${item['amount']}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: amountColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['date'],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          color: isDark ? AppColors.neutral600 : AppColors.neutral400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── UPCOMING BILLS ───────────────────────────────────
              _buildSectionHeader(context, isDark, 'Upcoming Bills'),
              _buildUpcomingRecurringSection(isDark),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
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
              Icon(
                Icons.people_alt_rounded,
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
              Icon(
                Icons.wallet_rounded,
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

  // Helper to build headers for sections
  Widget _buildSectionHeader(BuildContext context, bool isDark, String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.neutral50 : AppColors.neutral900,
          ),
        ),
      ),
    );
  }

  // Quick Groups Section Widget
  Widget _buildQuickGroupsSection(bool isDark) {
    final List<Map<String, dynamic>> groups = [
      {'name': 'Office Chai ☕', 'members': '8 Members', 'balance': 'Owe ₹40.00'},
      {'name': 'Friday Lunch 🍔', 'members': '5 Members', 'balance': 'Owed ₹450.00'},
      {'name': 'Flatmates 🏠', 'members': '3 Members', 'balance': 'Settled'},
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: groups.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final g = groups[index];
              return Container(
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
              );
            },
          ),
        ),
      ),
    );
  }

  // Upcoming Recurring Bills Widget
  Widget _buildUpcomingRecurringSection(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
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
              Icon(Icons.wifi, color: isDark ? AppColors.primary400 : AppColors.primary600, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Office Broadband Wifi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Due in 3 Days • Split equally',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹799.00',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
