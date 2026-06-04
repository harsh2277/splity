import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/index.dart';
import '../groups/groups_provider.dart';
import 'expenses_provider.dart';

class _Category {
  final String name;
  final String id;
  final List<List<dynamic>> icon;
  final Color color;

  const _Category({
    required this.name,
    required this.id,
    required this.icon,
    required this.color,
  });
}

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _amountError;
  String? _titleError;
  bool _isLoading = false;

  String _selectedCategory = 'food';
  String? _selectedGroupId;
  bool _isPersonal = true;
  bool _isPaidByMe = true;
  String? _selectedPayer;
  DateTime _selectedDate = DateTime.now();

  final List<String> _groupMembers = const [
    'Prem Parmar',
    'Aman Gupta',
    'Rohit Sen',
    'Dev Patel',
  ];

  final List<_Category> _categories = [
    _Category(name: 'Food', id: 'food', icon: HugeIcons.strokeRoundedRestaurant, color: const Color(0xFFF59E0B)),
    _Category(name: 'Travel', id: 'travel', icon: HugeIcons.strokeRoundedCar01, color: const Color(0xFF3B82F6)),
    _Category(name: 'Bills', id: 'bills', icon: HugeIcons.strokeRoundedReceiptText, color: const Color(0xFF8B5CF6)),
    _Category(name: 'Shopping', id: 'shopping', icon: HugeIcons.strokeRoundedShoppingBag01, color: const Color(0xFFEC4899)),
    _Category(name: 'Fun', id: 'entertainment', icon: HugeIcons.strokeRoundedPlay, color: const Color(0xFF10B981)),
    _Category(name: 'Other', id: 'other', icon: HugeIcons.strokeRoundedGrid, color: const Color(0xFF6B7280)),
  ];

  @override
  void initState() {
    super.initState();
    if (_groupMembers.isNotEmpty) {
      _selectedPayer = _groupMembers[0];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final amountText = _amountController.text.trim();
    final title = _titleController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    setState(() {
      _amountError = null;
      _titleError = null;
    });

    if (amountText.isEmpty || amount <= 0) {
      setState(() => _amountError = 'Enter a valid amount');
      return;
    }
    if (title.isEmpty) {
      setState(() => _titleError = 'Description is required');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate saving
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      String groupName = 'Personal Spend';
      if (!_isPersonal && _selectedGroupId != null) {
        final groups = ref.read(groupsProvider);
        final selectedGroup = groups.firstWhere(
          (g) => g.id == _selectedGroupId,
          orElse: () => groups.first,
        );
        groupName = selectedGroup.name;
      }

      ref.read(expensesProvider.notifier).addExpense(
            title: title,
            amount: amount,
            groupName: groupName,
            category: _selectedCategory,
            isPersonal: _isPersonal,
            isPaidByMe: _isPaidByMe,
            payerName: _isPaidByMe ? null : _selectedPayer,
          );

      setState(() => _isLoading = false);
      AppSnackbar.success(context, 'Expense added successfully!', showAtTop: true);
      context.pop();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary400,
                    onPrimary: AppColors.darkBackground,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.neutral50,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary600,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.neutral900,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final groups = ref.watch(groupsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: isDark ? AppColors.neutral50 : AppColors.neutral900,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Expense',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.neutral50 : AppColors.neutral900,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                color: isDark ? AppColors.primary400 : AppColors.primary600,
                size: 24,
              ),
              onPressed: _submit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AMOUNT INPUT BLOCK (PREMIUM LARGE VIEW) ──────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Enter Amount',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primary400 : AppColors.primary600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.neutral700 : AppColors.neutral300,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_amountError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _amountError!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.error500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── GENERAL DETAILS ──────────────────────────────────────────────
            AppTextField(
              controller: _titleController,
              label: 'Description',
              hint: 'What was this expense for?',
              prefixIcon: HugeIcons.strokeRoundedNote01,
              errorText: _titleError,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _notesController,
              label: 'Add Notes (Optional)',
              hint: 'Any extra details...',
              prefixIcon: HugeIcons.strokeRoundedDocumentAttachment,
            ),
            const SizedBox(height: 20),

            // ── CATEGORY PICKER ──────────────────────────────────────────────
            Text(
              'Select Category',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.neutral300 : AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat.id;
                      });
                    },
                    child: Container(
                      width: 76,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkSurface : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? cat.color
                              : (isDark ? AppColors.darkSurface2 : AppColors.neutral200),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: cat.icon,
                            color: isSelected ? cat.color : (isDark ? AppColors.neutral400 : AppColors.neutral500),
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? AppColors.neutral50 : AppColors.neutral900)
                                  : (isDark ? AppColors.neutral400 : AppColors.neutral600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // ── TYPE SELECTION (PERSONAL VS GROUP) ───────────────────────────
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.neutral100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPersonal = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isPersonal
                              ? (isDark ? AppColors.darkSurface3 : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isPersonal
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedUser,
                                color: _isPersonal
                                    ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                    : (isDark ? AppColors.neutral400 : AppColors.neutral500),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Personal Log',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: _isPersonal ? FontWeight.w700 : FontWeight.w500,
                                  color: _isPersonal
                                      ? (isDark ? AppColors.neutral50 : AppColors.neutral900)
                                      : (isDark ? AppColors.neutral500 : AppColors.neutral600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPersonal = false;
                          if (_selectedGroupId == null && groups.isNotEmpty) {
                            _selectedGroupId = groups.first.id;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isPersonal
                              ? (isDark ? AppColors.darkSurface3 : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !_isPersonal
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedUserGroup,
                                color: !_isPersonal
                                    ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                    : (isDark ? AppColors.neutral400 : AppColors.neutral500),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Group Expense',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: !_isPersonal ? FontWeight.w700 : FontWeight.w500,
                                  color: !_isPersonal
                                      ? (isDark ? AppColors.neutral50 : AppColors.neutral900)
                                      : (isDark ? AppColors.neutral500 : AppColors.neutral600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── GROUP EXPENSE SPLIT / PAYER OPTIONS ─────────────────────────
            if (!_isPersonal) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group dropdown selector
                    Text(
                      'Select Group',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface2 : AppColors.neutral100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGroupId,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedArrowDown01,
                            color: isDark ? AppColors.neutral400 : AppColors.neutral600,
                            size: 20,
                          ),
                          items: groups.map((g) {
                            return DropdownMenuItem<String>(
                              value: g.id,
                              child: Text(
                                g.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedGroupId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Paid by option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paid by',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.neutral300 : AppColors.neutral700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface2 : AppColors.neutral100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _isPaidByMe = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _isPaidByMe
                                        ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'You',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _isPaidByMe
                                          ? (isDark ? AppColors.darkBackground : Colors.white)
                                          : (isDark ? AppColors.neutral400 : AppColors.neutral600),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _isPaidByMe = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: !_isPaidByMe
                                        ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Someone else',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: !_isPaidByMe
                                          ? (isDark ? AppColors.darkBackground : Colors.white)
                                          : (isDark ? AppColors.neutral400 : AppColors.neutral600),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (!_isPaidByMe) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Select Payer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface2 : AppColors.neutral100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPayer,
                            isExpanded: true,
                            dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                            items: _groupMembers.map((m) {
                              return DropdownMenuItem<String>(
                                value: m,
                                child: Text(
                                  m,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedPayer = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── DATE SELECTOR ────────────────────────────────────────────────
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCalendar01,
                      color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                        ),
                      ),
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: isDark ? AppColors.neutral500 : AppColors.neutral400,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── SAVE BUTTON ──────────────────────────────────────────────────
            AppButton(
              label: 'Save Expense',
              onPressed: _submit,
              isLoading: _isLoading,
              leadingIcon: HugeIcons.strokeRoundedCheckmarkCircle01,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
