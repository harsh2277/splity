import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/index.dart';
import '../groups/groups_provider.dart';
import 'expenses_provider.dart';

// Fix 11: Indian number format with commas (e.g., 1,00,000) with 5,00,000 max
class _IndianCurrencyFormatter extends TextInputFormatter {
  static const int _maxValue = 500000;

  String _formatIndian(String digits) {
    if (digits.isEmpty) return '';
    // Split decimal if present
    final parts = digits.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (intPart.length <= 3) return '$intPart$decPart';
    final last3 = intPart.substring(intPart.length - 3);
    final rest = intPart.substring(0, intPart.length - 3);
    final groups = <String>[];
    for (int i = rest.length; i > 0; i -= 2) {
      groups.insert(0, rest.substring(i > 2 ? i - 2 : 0, i));
    }
    return '${groups.join(',')},$last3$decPart';
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Strip commas to get raw digits
    final rawText = newValue.text.replaceAll(',', '');
    // Allow only digits and one decimal point
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(rawText)) {
      return oldValue;
    }
    // Check max value
    final numericVal = double.tryParse(rawText) ?? 0;
    if (numericVal > _maxValue) return oldValue;

    final formatted = _formatIndian(rawText);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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
  final String? defaultGroupId;
  const AddExpenseScreen({super.key, this.defaultGroupId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _amountError;
  String? _titleError;
  String? _splitError;
  bool _isLoading = false;

  String _selectedCategory = 'food';
  String? _selectedGroupId;
  
  // _expenseMode: 0 = Personal, 1 = Group, 2 = 1-on-1 Member
  int _expenseMode = 0;
  
  bool get _isPersonal => _expenseMode == 0;
  bool _isPaidByMe = true;
  String? _selectedPayer;
  DateTime _selectedDate = DateTime.now();

  final List<String> _groupMembers = const [
    'Prem Parmar',
    'Aman Gupta',
    'Rohit Sen',
    'Dev Patel',
  ];

  final List<String> _allAppMembers = const [
    'Prem Parmar',
    'Aman Gupta',
    'Rohit Sen',
    'Dev Patel',
    'Neha Sharma',
    'Ishaan Verma',
  ];

  final List<String> _singleMembersList = const [
    'Aman Gupta',
    'Rohit Sen',
    'Dev Patel',
    'Neha Sharma',
    'Ishaan Verma',
  ];

  String? _selectedSingleMember = 'Aman Gupta';

  List<String> get _activeSplitMembers {
    if (_expenseMode == 0) {
      return const ['Prem Parmar'];
    } else if (_expenseMode == 1) {
      return _groupMembers;
    } else {
      return ['Prem Parmar', _selectedSingleMember ?? 'Aman Gupta'];
    }
  }

  String _splitType = 'equal';
  late Map<String, bool> _equalMembers;
  late Map<String, TextEditingController> _percentageControllers;
  late Map<String, TextEditingController> _customControllers;

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
    
    // Default Group setup if passed
    if (widget.defaultGroupId != null) {
      _selectedGroupId = widget.defaultGroupId;
      _expenseMode = 1; // Default to Group
    }

    if (_groupMembers.isNotEmpty) {
      _selectedPayer = _groupMembers[0];
    }
    
    _equalMembers = {for (var m in _allAppMembers) m: true};
    _percentageControllers = {
      for (var m in _allAppMembers)
        m: TextEditingController()
    };
    _customControllers = {
      for (var m in _allAppMembers)
        m: TextEditingController(text: '0.00')
    };

    _amountController.addListener(_resetSplitToEqual);
    _resetSplitToEqual();
  }

  void _resetSplitToEqual() {
    final active = _activeSplitMembers;
    final initialPercentage = active.isNotEmpty ? 100.0 / active.length : 0.0;
    final totalAmount = double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0.0;
    final perPersonCustom = active.isNotEmpty ? totalAmount / active.length : 0.0;

    setState(() {
      for (var m in _allAppMembers) {
        _equalMembers[m] = active.contains(m);
        _percentageControllers[m]!.text = active.contains(m)
            ? initialPercentage.toStringAsFixed(1)
            : '0.0';
        _customControllers[m]!.text = active.contains(m)
            ? perPersonCustom.toStringAsFixed(2)
            : '0.00';
      }
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_resetSplitToEqual);
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    for (var c in _percentageControllers.values) {
      c.dispose();
    }
    for (var c in _customControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    // Strip commas before parsing
    final amountText = _amountController.text.trim().replaceAll(',', '');
    final title = _titleController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    setState(() {
      _amountError = null;
      _titleError = null;
      _splitError = null;
    });

    if (amountText.isEmpty || amount <= 0) {
      setState(() => _amountError = 'Enter a valid amount');
      return;
    }
    if (title.isEmpty) {
      setState(() => _titleError = 'Description is required');
      return;
    }

    if (!_isPersonal) {
      if (_splitType == 'equal') {
        final selectedCount = _activeSplitMembers.where((m) => _equalMembers[m] ?? false).length;
        if (selectedCount == 0) {
          setState(() => _splitError = 'Select at least one member to split with');
          return;
        }
      } else if (_splitType == 'percentage') {
        double totalPct = 0;
        for (var m in _activeSplitMembers) {
          final pct = double.tryParse(_percentageControllers[m]!.text.trim()) ?? 0.0;
          totalPct += pct;
        }
        if ((totalPct - 100.0).abs() > 0.1) {
          setState(() => _splitError = 'Total percentage must equal 100% (Current: ${totalPct.toStringAsFixed(1)}%)');
          return;
        }
      } else if (_splitType == 'custom') {
        double totalCustom = 0;
        for (var m in _activeSplitMembers) {
          final val = double.tryParse(_customControllers[m]!.text.trim()) ?? 0.0;
          totalCustom += val;
        }
        if ((totalCustom - amount).abs() > 0.01) {
          setState(() => _splitError = 'Total custom shares (₹${totalCustom.toStringAsFixed(2)}) must equal the expense amount (₹${amount.toStringAsFixed(2)})');
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    // Simulate saving
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      String groupName = 'Personal Spend';
      String splitMethod = 'Split equally';

      if (_expenseMode == 1) { // Group mode
        if (_splitType == 'percentage') {
          splitMethod = 'Split by %';
        } else if (_splitType == 'custom') {
          splitMethod = 'Custom split';
        } else {
          final selectedCount = _activeSplitMembers.where((m) => _equalMembers[m] ?? false).length;
          if (selectedCount == _activeSplitMembers.length) {
            splitMethod = 'Split equally';
          } else {
            splitMethod = 'Split with $selectedCount members';
          }
        }

        if (_selectedGroupId != null) {
          final groups = ref.read(groupsProvider);
          final selectedGroup = groups.firstWhere(
            (g) => g.id == _selectedGroupId,
            orElse: () => groups.first,
          );
          groupName = selectedGroup.name;
        }
      } else if (_expenseMode == 2) { // 1-on-1 mode
        splitMethod = '1-on-1 split';
        groupName = '1-on-1 with $_selectedSingleMember';
      }

      ref.read(expensesProvider.notifier).addExpense(
            title: title,
            amount: amount,
            groupName: groupName,
            category: _selectedCategory,
            isPersonal: _isPersonal,
            isPaidByMe: _isPaidByMe,
            payerName: _isPaidByMe ? null : _selectedPayer,
            splitMethod: splitMethod,
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
        actions: const [],
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
                          // Fix 11: Indian currency format + max 5,00,000
                          inputFormatters: [_IndianCurrencyFormatter()],
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
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            filled: false,
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

            // ── TYPE SELECTION (PERSONAL, GROUP, 1-ON-1) ───────────────────────────
            Container(
              padding: const EdgeInsets.all(4),
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
                      onTap: () {
                        setState(() {
                          _expenseMode = 0;
                          _resetSplitToEqual();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _expenseMode == 0
                              ? (isDark ? AppColors.darkSurface3 : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _expenseMode == 0
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
                                color: _expenseMode == 0
                                    ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                    : (isDark ? AppColors.neutral400 : AppColors.neutral500),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Personal',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: _expenseMode == 0 ? FontWeight.w700 : FontWeight.w500,
                                  color: _expenseMode == 0
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
                          _expenseMode = 1;
                          if (_selectedGroupId == null && groups.isNotEmpty) {
                            _selectedGroupId = groups.first.id;
                          }
                          _resetSplitToEqual();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _expenseMode == 1
                              ? (isDark ? AppColors.darkSurface3 : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _expenseMode == 1
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
                                color: _expenseMode == 1
                                    ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                    : (isDark ? AppColors.neutral400 : AppColors.neutral500),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Group',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: _expenseMode == 1 ? FontWeight.w700 : FontWeight.w500,
                                  color: _expenseMode == 1
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
                          _expenseMode = 2;
                          _resetSplitToEqual();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _expenseMode == 2
                              ? (isDark ? AppColors.darkSurface3 : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _expenseMode == 2
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
                                color: _expenseMode == 2
                                    ? (isDark ? AppColors.primary400 : AppColors.primary600)
                                    : (isDark ? AppColors.neutral400 : AppColors.neutral500),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '1-on-1',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: _expenseMode == 2 ? FontWeight.w700 : FontWeight.w500,
                                  color: _expenseMode == 2
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
                    if (_expenseMode == 1) ...[
                      // Group dropdown selector
                      AppDropdown<String>(
                        value: _selectedGroupId,
                        label: 'Select Group',
                        prefixIcon: HugeIcons.strokeRoundedUserGroup,
                        items: groups.map((g) {
                          return AppDropdownItem<String>(
                            value: g.id,
                            label: g.name,
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedGroupId = val;
                            _resetSplitToEqual();
                          });
                        },
                      ),
                    ] else if (_expenseMode == 2) ...[
                      // Single Member dropdown selector
                      AppDropdown<String>(
                        value: _selectedSingleMember,
                        label: 'Select Member',
                        prefixIcon: HugeIcons.strokeRoundedUser,
                        items: _singleMembersList.map((m) {
                          return AppDropdownItem<String>(
                            value: m,
                            label: m,
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSingleMember = val;
                            _resetSplitToEqual();
                          });
                        },
                      ),
                    ],
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
                      const SizedBox(height: 16),
                      AppDropdown<String>(
                        value: _selectedPayer,
                        label: 'Select Payer',
                        prefixIcon: HugeIcons.strokeRoundedUser,
                        items: _activeSplitMembers.map((m) {
                          return AppDropdownItem<String>(
                            value: m,
                            label: m,
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedPayer = val;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Divide by',
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
                              _buildSplitTypeTab('equal', 'Equal', isDark),
                              _buildSplitTypeTab('percentage', '%', isDark),
                              _buildSplitTypeTab('custom', 'Custom', isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._buildSplitDetails(isDark),
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
              size: AppButtonSize.lg,
              hasShadow: false,
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

  Widget _buildSplitTypeTab(String type, String label, bool isDark) {
    final isSelected = _splitType == type;
    return GestureDetector(
      onTap: () => setState(() => _splitType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primary400 : AppColors.primary600)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? (isDark ? AppColors.darkBackground : Colors.white)
                : (isDark ? AppColors.neutral400 : AppColors.neutral600),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSplitDetails(bool isDark) {
    final totalAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final List<Widget> list = [];

    if (_splitType == 'equal') {
      final selectedCount = _equalMembers.values.where((v) => v).length;
      final perPerson = selectedCount > 0 ? totalAmount / selectedCount : 0.0;

      list.addAll([
        Text(
          'Split equally among members:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.neutral400 : AppColors.neutral500,
          ),
        ),
        const SizedBox(height: 8),
        ..._activeSplitMembers.map((member) {
          final isSelected = _equalMembers[member] ?? false;
          return CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              member,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.neutral50 : AppColors.neutral900,
              ),
            ),
            subtitle: isSelected
                ? Text(
                    'Share: ₹${perPerson.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? AppColors.primary400 : AppColors.primary600,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
            value: isSelected,
            activeColor: isDark ? AppColors.primary400 : AppColors.primary600,
            checkColor: isDark ? AppColors.darkBackground : Colors.white,
            onChanged: (val) {
              setState(() {
                _equalMembers[member] = val ?? false;
              });
            },
          );
        }),
      ]);
    } else if (_splitType == 'percentage') {
      list.addAll([
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Specify share percentage:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.neutral400 : AppColors.neutral500,
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, size: 16, color: isDark ? AppColors.neutral400 : AppColors.neutral500),
              tooltip: 'Reset to equal',
              onPressed: () {
                final initialPercentage = 100.0 / _activeSplitMembers.length;
                setState(() {
                  for (var m in _activeSplitMembers) {
                    _percentageControllers[m]!.text = initialPercentage.toStringAsFixed(1);
                  }
                });
              },
            )
          ],
        ),
        const SizedBox(height: 4),
        ..._activeSplitMembers.map((member) {
          final pct = double.tryParse(_percentageControllers[member]!.text.trim()) ?? 0.0;
          final amount = (totalAmount * pct) / 100.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    member,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                    ),
                  ),
                ),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 70,
                  height: 36,
                  child: TextField(
                    controller: _percentageControllers[member],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      suffixText: '%',
                      suffixStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ]);
    } else {
      list.addAll([
        Text(
          'Specify exact share amount:',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.neutral400 : AppColors.neutral500,
          ),
        ),
        const SizedBox(height: 8),
        ..._activeSplitMembers.map((member) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    member,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 36,
                  child: TextField(
                    controller: _customControllers[member],
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.neutral50 : AppColors.neutral900,
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      prefixText: '₹',
                      prefixStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkSurface2 : AppColors.neutral200,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ]);
    }

    if (_splitError != null) {
      list.add(
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            _splitError!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.error500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return list;
  }
}
