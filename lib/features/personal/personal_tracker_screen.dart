import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class PersonalTrackerScreen extends StatefulWidget {
  const PersonalTrackerScreen({super.key});

  @override
  State<PersonalTrackerScreen> createState() => _PersonalTrackerScreenState();
}

class _PersonalTrackerScreenState extends State<PersonalTrackerScreen> {
  double _limit = 10000.00;
  final List<Map<String, dynamic>> _spends = [
    {
      'title': 'Office Lunch (Salad & Juice)',
      'category': 'Food',
      'amount': 320.00,
      'date': 'Today, 1:15 PM'
    },
    {
      'title': 'Metro Card Recharge',
      'category': 'Travel',
      'amount': 500.00,
      'date': 'Yesterday, 9:00 AM'
    },
    {
      'title': 'Internet Broadband Bill',
      'category': 'Bills',
      'amount': 850.00,
      'date': 'June 1, 2026'
    },
    {
      'title': 'Noise Cancelling Headset',
      'category': 'Shopping',
      'amount': 4570.00,
      'date': 'May 28, 2026'
    },
  ];

  double get _totalSpent {
    return _spends.fold(0.0, (sum, item) => sum + (item['amount'] as double));
  }

  void _addSpend() {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Food';

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final c = context.appColors;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? c.surface : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add Personal Expense',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: isDark ? c.neutral50 : c.neutral900,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: titleController,
                          label: 'Title / Description',
                          hint: 'e.g. Groceries, Coffee',
                          prefixIcon: HugeIcons.strokeRoundedNote01,
                          // Simple validation is done manually inside onPressed to keep it clean
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: amountController,
                          label: 'Amount (₹)',
                          hint: 'e.g. 250.00',
                          prefixIcon: HugeIcons.strokeRoundedWallet02,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 16),
                        AppDropdown<String>(
                          label: 'Category',
                          value: category,
                          prefixIcon: HugeIcons.strokeRoundedGrid,
                          items: const [
                            AppDropdownItem(value: 'Food', label: 'Food'),
                            AppDropdownItem(value: 'Travel', label: 'Travel'),
                            AppDropdownItem(value: 'Bills', label: 'Bills'),
                            AppDropdownItem(value: 'Shopping', label: 'Shopping'),
                            AppDropdownItem(value: 'Others', label: 'Others'),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              category = value;
                            });
                          },
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Cancel',
                                variant: AppButtonVariant.ghost,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppButton(
                                label: 'Add Spend',
                                variant: AppButtonVariant.primary,
                                hasShadow: false,
                                onPressed: () {
                                  final title = titleController.text.trim();
                                  final amountStr = amountController.text.trim();
                                  final amount = double.tryParse(amountStr) ?? 0.0;

                                  if (title.isEmpty) {
                                    AppSnackbar.error(context, 'Please enter a description');
                                    return;
                                  }
                                  if (amount <= 0.0) {
                                    AppSnackbar.error(context, 'Please enter a valid amount');
                                    return;
                                  }

                                  setState(() {
                                    _spends.insert(0, {
                                      'title': title,
                                      'amount': amount,
                                      'category': category,
                                      'date': 'Just now',
                                    });
                                  });
                                  Navigator.pop(context);
                                  AppSnackbar.success(
                                    context,
                                    'Added spend of ₹${amount.toStringAsFixed(2)}!',
                                    showAtTop: true,
                                  );
                                },
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
          },
        );
      },
    );
  }

  void _editLimit() {
    final formKey = GlobalKey<FormState>();
    final limitController = TextEditingController(text: _limit.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final c = context.appColors;
        return Dialog(
          backgroundColor: isDark ? c.surface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Monthly Limit',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: isDark ? c.neutral50 : c.neutral900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: limitController,
                    label: 'Limit (₹)',
                    hint: 'e.g. 10000',
                    prefixIcon: HugeIcons.strokeRoundedWallet02,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Cancel',
                          variant: AppButtonVariant.ghost,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Save',
                          variant: AppButtonVariant.primary,
                          hasShadow: false,
                          onPressed: () {
                            final limitStr = limitController.text.trim();
                            final limit = double.tryParse(limitStr) ?? 0.0;

                            if (limit <= 0.0) {
                              AppSnackbar.error(context, 'Please enter a valid limit');
                              return;
                            }

                            setState(() {
                              _limit = limit;
                            });
                            Navigator.pop(context);
                            AppSnackbar.success(
                              context,
                              'Budget limit updated to ₹${_limit.toStringAsFixed(0)}!',
                              showAtTop: true,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood_rounded;
      case 'travel':
        return Icons.directions_car_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFF59E0B);
      case 'travel':
        return const Color(0xFF3B82F6);
      case 'bills':
        return const Color(0xFF10B981);
      case 'shopping':
        return const Color(0xFFEC4899);
      default:
        return AppColors.neutral400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;
    final progress = (_totalSpent / _limit).clamp(0.0, 1.0);
    final isLimitExceeded = _totalSpent > _limit;

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Personal Tracker',
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.edit_note_rounded,
                color: isDark ? AppColors.primary400 : AppColors.primary600,
                size: 26,
              ),
              onPressed: _editLimit,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Budget card
              AppCard(
                variant: AppCardVariant.elevated,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent this month',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                          ),
                        ),
                        Text(
                          'Limit: ₹${_limit.toStringAsFixed(0)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primary400 : AppColors.primary600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${_totalSpent.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: isLimitExceeded ? AppColors.error500 : (isDark ? AppColors.neutral50 : AppColors.neutral900),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: isDark ? AppColors.darkSurface3 : AppColors.neutral200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLimitExceeded ? AppColors.error500 : (isDark ? AppColors.primary400 : AppColors.primary600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toStringAsFixed(1)}% Used',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.neutral500 : AppColors.neutral500,
                          ),
                        ),
                        Text(
                          isLimitExceeded
                              ? '₹${(_totalSpent - _limit).toStringAsFixed(0)} Over Limit'
                              : '₹${(_limit - _totalSpent).toStringAsFixed(0)} Remaining',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isLimitExceeded ? AppColors.error500 : AppColors.success500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Personal Expenses',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? c.neutral400 : c.neutral700,
                ),
              ),
              const SizedBox(height: 12),

              // Spends List
              Expanded(
                child: _spends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedWallet02,
                              size: 48,
                              color: isDark ? AppColors.neutral600 : AppColors.neutral300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No personal spends logged yet',
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
                        itemCount: _spends.length,
                        itemBuilder: (context, index) {
                          final item = _spends[index];
                          final category = item['category'] ?? 'Others';
                          final iconColor = _getCategoryColor(category);

                          return Container(
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
                                    color: iconColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getCategoryIcon(category),
                                      color: iconColor,
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
                                        item['title'],
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
                                        '${item['category']} • ${item['date']}',
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
                                Text(
                                  '₹${(item['amount'] as double).toStringAsFixed(2)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? c.neutral50 : c.neutral900,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? AppColors.primary400 : AppColors.primary600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _addSpend,
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
