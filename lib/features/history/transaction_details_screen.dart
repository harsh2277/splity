import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import '../expenses/expenses_provider.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Expense expense;

  const TransactionDetailsScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;

    IconData categoryIcon = Icons.category_rounded;
    Color iconColor = const Color(0xFF10B981);
    String categoryName = 'Others';

    if (expense.category == 'food') {
      categoryIcon = Icons.restaurant_rounded;
      iconColor = const Color(0xFFF59E0B);
      categoryName = 'Food & Dining';
    } else if (expense.category == 'travel') {
      categoryIcon = Icons.directions_car_rounded;
      iconColor = const Color(0xFF3B82F6);
      categoryName = 'Travel';
    } else if (expense.category == 'bills') {
      categoryIcon = Icons.receipt_long_rounded;
      iconColor = const Color(0xFFEC4899);
      categoryName = 'Bills';
    }

    // Custom Mock Details based on transaction title
    final String location = expense.isPersonal
        ? 'Personal Location'
        : (expense.title.contains('Lunch') || expense.title.contains('Pizza')
            ? 'Pizza Hut, Sector 18, Noida'
            : expense.title.contains('Chai')
                ? 'Tapri Chai, Sector 62, Noida'
                : 'Office HQ, Noida');

    final String paymentMethod = expense.isPersonal
        ? 'Visa Debit Card'
        : (expense.isOwed ? 'UPI Transfer (BHIM)' : 'Paid via PhonePe');

    final String transactionId = 'UPI${expense.title.length}98765${expense.amount.length}4210';
    
    final splitMethod = expense.subtitle.contains('•') 
        ? expense.subtitle.split('•').last.trim() 
        : 'Split Equally';

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Transaction Details',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Card
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          categoryIcon,
                          color: iconColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        expense.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? c.neutral50 : c.neutral900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        expense.amount,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: expense.isOwed ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppBadge(
                        label: expense.isPersonal ? 'PERSONAL' : 'GROUP EXPENSE',
                        type: expense.isPersonal ? AppBadgeType.neutral : AppBadgeType.success,
                        size: AppBadgeSize.sm,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // General Information Section
                Text(
                  'General Info',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? c.neutral400 : c.neutral700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? c.surface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? c.surface3 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailItem(context, 'Category', categoryName),
                      const Divider(height: 24),
                      _buildDetailItem(context, 'Date & Time', expense.date),
                      const Divider(height: 24),
                      _buildDetailItem(context, 'Location', location),
                      const Divider(height: 24),
                      _buildDetailItem(context, 'Payment Method', paymentMethod),
                      const Divider(height: 24),
                      _buildDetailItem(context, 'Transaction ID', transactionId),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Split details (If not personal)
                if (!expense.isPersonal) ...[
                  Text(
                    'Split Breakdown',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? c.neutral400 : c.neutral700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                        _buildDetailItem(context, 'Split Method', splitMethod),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        _buildSplitMemberRow(context, 'Aman Gupta', 'Owes ₹15.00', true),
                        const SizedBox(height: 12),
                        _buildSplitMemberRow(context, 'Rohit Sen', 'Owes ₹15.00', true),
                        const SizedBox(height: 12),
                        _buildSplitMemberRow(context, 'You', 'Paid remainder', false),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: c.neutral500,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? c.neutral50 : c.neutral900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSplitMemberRow(BuildContext context, String name, String share, bool owes) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isDark ? c.surface3 : c.neutral100,
              child: Text(
                name.substring(0, 1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? c.neutral200 : c.neutral700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? c.neutral50 : c.neutral900,
              ),
            ),
          ],
        ),
        Text(
          share,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: owes ? const Color(0xFFEF4444) : const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }
}
