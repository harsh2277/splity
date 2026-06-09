import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import '../expenses/expenses_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final c = context.appColors;
    final activities = ref.watch(expensesProvider);

    // Filter activities - Fix 13: Exclude personal logs from Transaction History
    final filteredActivities = activities.where((act) {
      final matchesSearch = act.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          act.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'all' || act.category == _selectedCategory;
      // Personal logs go to Personal Tracker, not Transaction History
      return matchesSearch && matchesCategory && !act.isPersonal;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? c.background : c.neutral50,
      appBar: AppBar(
        title: Text(
          'Transaction History',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Search Bar
              AppSearchField(
                controller: _searchController,
                hint: 'Search transaction...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Category chips filter
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    AppChip(
                      label: 'All Spends',
                      isSelected: _selectedCategory == 'all',
                      onTap: () => setState(() => _selectedCategory = 'all'),
                    ),
                    const SizedBox(width: 8),
                    AppChip(
                      label: 'Food & Dining',
                      isSelected: _selectedCategory == 'food',
                      leadingIcon: HugeIcons.strokeRoundedRestaurant,
                      onTap: () => setState(() => _selectedCategory = 'food'),
                    ),
                    const SizedBox(width: 8),
                    AppChip(
                      label: 'Travel',
                      isSelected: _selectedCategory == 'travel',
                      leadingIcon: HugeIcons.strokeRoundedCar01,
                      onTap: () => setState(() => _selectedCategory = 'travel'),
                    ),
                    const SizedBox(width: 8),
                    AppChip(
                      label: 'Bills',
                      isSelected: _selectedCategory == 'bills',
                      leadingIcon: HugeIcons.strokeRoundedReceiptText,
                      onTap: () => setState(() => _selectedCategory = 'bills'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Recent Transactions',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? c.neutral400 : c.neutral700,
                ),
              ),
              const SizedBox(height: 12),

              // Transactions List
              Expanded(
                child: filteredActivities.isEmpty
                    ? Center(
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
                              'No transactions found',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                color: isDark ? c.neutral500 : c.neutral400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredActivities.length,
                        itemBuilder: (context, index) {
                          final item = filteredActivities[index];
                          final isPersonal = item.isPersonal;
                          final isOwed = item.isOwed;

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

                          return GestureDetector(
                            onTap: () => context.push('/transaction-details', extra: item),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
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
                                            color: isDark ? c.neutral50 : c.neutral900,
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
                                            color: isDark ? c.neutral500 : c.neutral500,
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
            ],
          ),
        ),
      ),
    );
  }
}
