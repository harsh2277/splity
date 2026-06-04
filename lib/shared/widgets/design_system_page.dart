import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:splity/core/theme/index.dart';
import 'package:splity/core/constants/app_constants.dart';
import 'package:splity/shared/widgets/index.dart';

class DesignSystemPage extends StatefulWidget {
  const DesignSystemPage({super.key});

  @override
  State<DesignSystemPage> createState() => _DesignSystemPageState();
}

class _DesignSystemPageState extends State<DesignSystemPage> {
  final _demoController1 = TextEditingController(text: 'Pizza Party split');
  final _demoController2 = TextEditingController(text: '120.00');
  final _searchController = TextEditingController();
  final _richController = TextEditingController(
    text: 'Hello @harsh! Checkout this new #splity design system at www.splity.app'
  );
  
  bool _selectedChip1 = true;
  bool _selectedChip2 = false;
  String _activeSection = 'All';

  final List<String> _sections = [
    'All',
    'Tokens',
    'Buttons',
    'Input Layouts',
    'Pill Tags & Avatars',
    'Modals & Alerts',
  ];

  final List<String> _shadeLabels = ['50', '100', '200', '300', '400', '500', '600', '700', '800', '900'];

  @override
  void dispose() {
    _demoController1.dispose();
    _demoController2.dispose();
    _searchController.dispose();
    _richController.dispose();
    super.dispose();
  }

  List<List<dynamic>> _getSectionIcon(String section) {
    switch (section) {
      case 'All':
        return HugeIcons.strokeRoundedGrid;
      case 'Tokens':
        return HugeIcons.strokeRoundedColors;
      case 'Buttons':
        return HugeIcons.strokeRoundedDashboardSquare01;
      case 'Input Layouts':
        return HugeIcons.strokeRoundedTextAlignLeft;
      case 'Pill Tags & Avatars':
        return HugeIcons.strokeRoundedUserGroup;
      case 'Modals & Alerts':
        return HugeIcons.strokeRoundedNotification01;
      default:
        return HugeIcons.strokeRoundedGrid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    final catalogList = [
      // ── Brand Hero Header ────────────────────────
      if (_activeSection == 'All' || _activeSection == 'Tokens') ...[
        _buildBrandHero(c, isDark),
        const SizedBox(height: 24),
      ],

      // ── Color Swatches Section ────────────────────
      if (_activeSection == 'All' || _activeSection == 'Tokens') ...[
        _buildSectionHeader('01', 'Colors & Palette Scales'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorRow('Primary Brand (Royal Blue)', [
                  AppColors.primary50, AppColors.primary100, AppColors.primary200,
                  AppColors.primary300, AppColors.primary400, AppColors.primary500,
                  AppColors.primary600, AppColors.primary700, AppColors.primary800,
                  AppColors.primary900,
                ], _shadeLabels),
                const SizedBox(height: 24),
                _buildColorRow('Success Status (Emerald)', [
                  AppColors.success50, AppColors.success100, AppColors.success200,
                  AppColors.success300, AppColors.success400, AppColors.success500,
                  AppColors.success600, AppColors.success700, AppColors.success800,
                  AppColors.success900,
                ], _shadeLabels),
                const SizedBox(height: 24),
                _buildColorRow('Warning Status (Amber)', [
                  AppColors.warning50, AppColors.warning100, AppColors.warning200,
                  AppColors.warning300, AppColors.warning400, AppColors.warning500,
                  AppColors.warning600, AppColors.warning700, AppColors.warning800,
                  AppColors.warning900,
                ], _shadeLabels),
                const SizedBox(height: 24),
                _buildColorRow('Error Status (Rose)', [
                  AppColors.error50, AppColors.error100, AppColors.error200,
                  AppColors.error300, AppColors.error400, AppColors.error500,
                  AppColors.error600, AppColors.error700, AppColors.error800,
                  AppColors.error900,
                ], _shadeLabels),
                const SizedBox(height: 24),
                _buildColorRow('Neutral Gray (Slate)', [
                  AppColors.neutral50, AppColors.neutral100, AppColors.neutral200,
                  AppColors.neutral300, AppColors.neutral400, AppColors.neutral500,
                  AppColors.neutral600, AppColors.neutral700, AppColors.neutral800,
                  AppColors.neutral900,
                ], _shadeLabels),
                if (isDark) ...[
                  const SizedBox(height: 24),
                  _buildColorRow('Blue-Tinted Surfaces (Dark Mode)', [
                    AppColors.darkBackground, AppColors.darkSurface,
                    AppColors.darkSurface2, AppColors.darkSurface3,
                    AppColors.darkSurface4,
                  ], ['BG', 'Surf1', 'Surf2', 'Surf3', 'Surf4']),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],

      // ── Typography Section ────────────────────────
      if (_activeSection == 'All' || _activeSection == 'Tokens') ...[
        _buildSectionHeader('02', 'Typography System'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeRow(context, 'Headline Large', '32px / Bold', AppTypography.textTheme.headlineLarge),
                _buildTypeRow(context, 'Headline Medium', '28px / Bold', AppTypography.textTheme.headlineMedium),
                _buildTypeRow(context, 'Title Large', '20px / Semi-Bold', AppTypography.textTheme.titleLarge),
                _buildTypeRow(context, 'Title Medium', '16px / Semi-Bold', AppTypography.textTheme.titleMedium),
                _buildTypeRow(context, 'Body Large', '16px / Regular', AppTypography.textTheme.bodyLarge),
                _buildTypeRow(context, 'Body Medium', '14px / Regular', AppTypography.textTheme.bodyMedium),
                _buildTypeRow(context, 'Label Large', '14px / Medium', AppTypography.textTheme.labelLarge),
                _buildTypeRow(context, 'Label Small', '11px / Medium', AppTypography.textTheme.labelSmall, isLast: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],

      // ── Buttons Section ───────────────────────────
      if (_activeSection == 'All' || _activeSection == 'Buttons') ...[
        _buildSectionHeader('03', 'Action & Button Elements'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubSectionTitle('Component Sizing scales'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppButton(label: 'Large Button', size: AppButtonSize.lg, onPressed: () {}),
                    AppButton(label: 'Medium Button', size: AppButtonSize.md, onPressed: () {}),
                    AppButton(label: 'Small Button', size: AppButtonSize.sm, onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSubSectionTitle('Variant Theme Styles'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(label: 'Primary brand', variant: AppButtonVariant.primary, onPressed: () {}),
                    AppButton(label: 'Secondary soft', variant: AppButtonVariant.secondary, onPressed: () {}),
                    AppButton(label: 'Ghost border', variant: AppButtonVariant.ghost, onPressed: () {}),
                    AppButton(label: 'Danger alert', variant: AppButtonVariant.danger, onPressed: () {}),
                    AppButton(label: 'Link style', variant: AppButtonVariant.link, onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSubSectionTitle('State & Icon Prefix/Suffix'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(label: 'Saving Ledger...', isLoading: true, onPressed: () {}),
                    AppButton(label: 'Disabled state', onPressed: null),
                    AppButton(label: 'Add Expense', leadingIcon: HugeIcons.strokeRoundedAdd01, onPressed: () {}),
                    AppButton(label: 'Next screen', trailingIcon: HugeIcons.strokeRoundedArrowRight01, onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSubSectionTitle('Vuesax Icon Buttons'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppIconButton(icon: HugeIcons.strokeRoundedNotification01, onPressed: () {}),
                    AppIconButton(icon: HugeIcons.strokeRoundedEdit02, variant: AppIconButtonVariant.outlined, onPressed: () {}),
                    AppIconButton(icon: HugeIcons.strokeRoundedDelete02, variant: AppIconButtonVariant.ghost, isDanger: true, onPressed: () {}),
                    AppIconButton(icon: HugeIcons.strokeRoundedShare01, size: AppIconButtonSize.sm, onPressed: () {}),
                    AppIconButton(icon: HugeIcons.strokeRoundedSent, size: AppIconButtonSize.lg, onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],

      // ── Inputs Section (Redesigned Layouts & State Grid) ──
      if (_activeSection == 'All' || _activeSection == 'Input Layouts') ...[
        _buildSectionHeader('04', 'Form Inputs & Interactive Fields'),
        
        // Responsive State Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ROW 1: Standard & Suffix-Clear Fields
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildInputDemoCard(c, 'DEFAULT EMPTY STATE', AppTextField(label: 'Merchant Name', hint: 'e.g. Starbucks, Uber, Walmart', prefixIcon: HugeIcons.strokeRoundedStore01))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildInputDemoCard(c, 'INPUT SUFFIX CLEAR (TYPE TO CLEAR)', AppTextField(controller: _demoController1, label: 'Ledger Description', hint: 'Enter description', prefixIcon: HugeIcons.strokeRoundedNote01))),
                        ],
                      )
                    : Column(
                        children: [
                          _buildInputDemoCard(c, 'DEFAULT EMPTY STATE', AppTextField(label: 'Merchant Name', hint: 'e.g. Starbucks, Uber, Walmart', prefixIcon: HugeIcons.strokeRoundedStore01)),
                          const SizedBox(height: 16),
                          _buildInputDemoCard(c, 'INPUT SUFFIX CLEAR (TYPE TO CLEAR)', AppTextField(controller: _demoController1, label: 'Ledger Description', hint: 'Enter description', prefixIcon: HugeIcons.strokeRoundedNote01)),
                        ],
                      ),
                const SizedBox(height: 16),

                // ROW 2: Password Secure Input & Validation Error States
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildInputDemoCard(c, 'SECURE PIN INPUT (EYE TOGGLE)', AppTextField(label: 'Security Transaction PIN', hint: 'Enter 6-digit PIN', prefixIcon: HugeIcons.strokeRoundedSecurity, isPassword: true))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildInputDemoCard(c, 'VALIDATION ERROR & FOCUS OUTLINE', AppTextField(label: 'Split Ratio Percentage', hint: 'e.g. 50%', prefixIcon: HugeIcons.strokeRoundedInformationCircle, errorText: 'Value must not exceed 100%'))),
                        ],
                      )
                    : Column(
                        children: [
                          _buildInputDemoCard(c, 'SECURE PIN INPUT (EYE TOGGLE)', AppTextField(label: 'Security Transaction PIN', hint: 'Enter 6-digit PIN', prefixIcon: HugeIcons.strokeRoundedSecurity, isPassword: true)),
                          const SizedBox(height: 16),
                          _buildInputDemoCard(c, 'VALIDATION ERROR & FOCUS OUTLINE', AppTextField(label: 'Split Ratio Percentage', hint: 'e.g. 50%', prefixIcon: HugeIcons.strokeRoundedInformationCircle, errorText: 'Value must not exceed 100%')),
                        ],
                      ),
                const SizedBox(height: 16),

                // ROW 3: Pill Search & Character Counter
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildInputDemoCard(c, 'Pill Search Field', AppSearchField(controller: _searchController, hint: 'Search transaction categories...'))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildInputDemoCard(c, 'CHARACTER COUNTER (FOCUSED)', AppTextField(label: 'Group Tagline Memo', hint: 'Brief statement', prefixIcon: HugeIcons.strokeRoundedMessage01, maxLength: 30))),
                        ],
                      )
                    : Column(
                        children: [
                          _buildInputDemoCard(c, 'Pill Search Field', AppSearchField(controller: _searchController, hint: 'Search transaction categories...')),
                          const SizedBox(height: 16),
                          _buildInputDemoCard(c, 'CHARACTER COUNTER (FOCUSED)', AppTextField(label: 'Group Tagline Memo', hint: 'Brief statement', prefixIcon: HugeIcons.strokeRoundedMessage01, maxLength: 30)),
                        ],
                      ),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
      ],

      // Rich Text Editor Section
      if (_activeSection == 'All' || _activeSection == 'Input Layouts') ...[
        _buildSectionHeader('05', 'Rich Markdown Highlight Editor'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubSectionTitle('Rich editor controller (shadow-free)'),
                const SizedBox(height: 6),
                Text('Dynamic styling controller parses mentions, hash-tags, and URLs live.', style: AppTypography.textTheme.bodySmall?.copyWith(color: c.textSecondary)),
                const SizedBox(height: 16),
                AppRichTextField(
                  controller: _richController,
                  label: 'Split Description & Notes',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],

      // ── Avatars & Tags Section ────────────────────
      if (_activeSection == 'All' || _activeSection == 'Pill Tags & Avatars') ...[
        _buildSectionHeader('06', 'Avatars, Badges & Chips'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pill Badges (Status Indicators)', style: AppTypography.textTheme.titleSmall?.copyWith(color: c.textSecondary)),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppBadge(label: 'Primary brand', type: AppBadgeType.primary),
                    AppBadge(label: 'Owes you \$45', type: AppBadgeType.success, leadingDot: true),
                    AppBadge(label: 'Pending settlement', type: AppBadgeType.warning, leadingDot: true),
                    AppBadge(label: 'Overdue 12d', type: AppBadgeType.error),
                    AppBadge(label: 'Info updates', type: AppBadgeType.info),
                    AppBadge(label: 'Settled group', type: AppBadgeType.neutral),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Pill Chips & Removables', style: AppTypography.textTheme.titleSmall?.copyWith(color: c.textSecondary)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppChip(
                      label: 'Active Trip Filter',
                      isSelected: _selectedChip1,
                      onTap: () => setState(() => _selectedChip1 = !_selectedChip1),
                    ),
                    AppChip(
                      label: 'Draft Bill',
                      isSelected: _selectedChip2,
                      onTap: () => setState(() => _selectedChip2 = !_selectedChip2),
                    ),
                    AppChip(
                      label: 'Harsh Patel',
                      type: AppChipType.input,
                      onRemove: () {
                        AppSnackbar.info(context, 'Removed Harsh from split list.');
                      },
                    ),
                    const AppChip(
                      label: 'Disabled chip',
                      isDisabled: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Avatars & Avatar Group Stack', style: AppTypography.textTheme.titleSmall?.copyWith(color: c.textSecondary)),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    AppAvatar(name: 'Harsh Patel', size: AppAvatarSize.md, imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200'),
                    SizedBox(width: 12),
                    AppAvatar(name: 'Prem Parmar', size: AppAvatarSize.md),
                    SizedBox(width: 12),
                    AppAvatar(name: 'Sarah Connor', size: AppAvatarSize.lg, imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                    SizedBox(width: 24),
                    Expanded(
                      child: AppAvatarGroup(
                        names: ['Harsh', 'Prem', 'John', 'Sarah'],
                        imageUrls: [
                          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200',
                          null,
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
                          null,
                        ],
                        maxVisible: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],

      // ── Dialogs & Feedback Section ────────────────
      if (_activeSection == 'All' || _activeSection == 'Modals & Alerts') ...[
        _buildSectionHeader('07', 'Modals, Bottom Sheets & Action Overlays'),
        AppCard(
          borderRadius: 28,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trigger Snackbars / Toasts', style: AppTypography.textTheme.titleSmall?.copyWith(color: c.textSecondary)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      label: 'Success Toast',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => AppSnackbar.success(context, 'Group expense split successfully!'),
                    ),
                    AppButton(
                      label: 'Error Toast',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => AppSnackbar.error(context, 'Transaction declined. Check bank credentials.'),
                    ),
                    AppButton(
                      label: 'Warning Toast',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => AppSnackbar.warning(context, 'Session will time out in 5 minutes.'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Trigger Modals & Confirmations', style: AppTypography.textTheme.titleSmall?.copyWith(color: c.textSecondary)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      label: 'Confirm Modal',
                      onPressed: () => AppDialog.showConfirm(
                        context,
                        title: 'Settle All Expenses?',
                        message: 'This will automatically send payout requests to 4 members. You owe \$12.30.',
                        confirmLabel: 'Confirm Payouts',
                        cancelLabel: 'Go Back',
                      ).then((confirmed) {
                        if (!context.mounted) return;
                        if (confirmed == true) {
                          AppSnackbar.success(context, 'Payout request sent!');
                        }
                      }),
                    ),
                    AppButton(
                      label: 'Destructive Action',
                      variant: AppButtonVariant.danger,
                      onPressed: () => AppDialog.showConfirm(
                        context,
                        title: 'Delete Splity Group?',
                        message: 'Are you sure you want to delete "Apartment 204 B"? All past balance receipts will be lost.',
                        confirmLabel: 'Delete Group',
                        isDanger: true,
                      ).then((confirmed) {
                        if (!context.mounted) return;
                        if (confirmed == true) {
                          AppSnackbar.error(context, 'Splity Group has been deleted.');
                        }
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text('Trigger Drawer Bottom Sheets', style: AppTypography.textTheme.titleSmall?.copyWith(color: c.textSecondary)),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Open Categories Drawer',
                  isFullWidth: true,
                  onPressed: () => AppBottomSheet.show(
                    context,
                    title: 'Select Payment Category',
                    subtitle: 'Choose category to distribute the bill ledger correctly.',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          _buildCategoryItem(HugeIcons.strokeRoundedActivity01, 'Restaurants & Meals', 'Group lunches, cafes, dinner tickets'),
                          _buildCategoryItem(HugeIcons.strokeRoundedBus01, 'Flights & Transit', 'Taxis, buses, trains, fuel split'),
                          _buildCategoryItem(HugeIcons.strokeRoundedHome01, 'Rents & Utilities', 'Apartment rental bill, electricity, fiber wifi'),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Save & Close Selection',
                            isFullWidth: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],

      // ── Dividers Section ──────────────────────────
      if (_activeSection == 'All' || _activeSection == 'Tokens') ...[
        _buildSectionHeader('08', 'Dividers & Segmentations'),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppDivider(),
                const SizedBox(height: 16),
                const AppDivider(label: 'OR SIGN IN USING PARTNERS'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Google Log', style: TextStyle(color: c.textSecondary, fontSize: 13)),
                      const VerticalDivider(width: 32, thickness: 1.5),
                      Text('Apple Log', style: TextStyle(color: c.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ];

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: HugeIcons.strokeRoundedReceiptText, color: c.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'splity design system',
              style: GoogleFonts.plusJakartaSans(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: c.surface,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: isDark ? HugeIcons.strokeRoundedSun01 : HugeIcons.strokeRoundedMoon,
              color: c.textPrimary,
            ),
            onPressed: () {
              AppSnackbar.info(
                context,
                'Theme follows your device\'s system theme automatically!',
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            if (isWide) {
              // ── DUAL PANE DASHBOARD VIEW (WIDE VIEWPORTS) ──────────────────
              return Row(
                children: [
                  // Sidebar navigation
                  Container(
                    width: 260,
                    color: c.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LIBRARY DIRECTORY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: c.textSecondary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Responsive Showcase',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: c.textDisabled,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const AppDivider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _sections.length,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemBuilder: (context, index) {
                              final section = _sections[index];
                              final isSelected = _activeSection == section;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: InkWell(
                                  onTap: () => setState(() => _activeSection = section),
                                  borderRadius: BorderRadius.circular(14),
                                  child: AnimatedContainer(
                                    duration: AppConstants.durationFast,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? c.primary50.withValues(alpha: isDark ? 0.15 : 0.85)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? c.primary500.withValues(alpha: 0.15)
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        HugeIcon(
                                          icon: _getSectionIcon(section),
                                          size: 18,
                                          color: isSelected ? c.primary : c.textSecondary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            section,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.5,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              color: isSelected ? c.primary : c.textPrimary,
                                            ),
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
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  // Details/Showcase viewport
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: catalogList,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // ── SCROLLABLE LIST VIEW WITH FILTER CHIPS (MOBILE VIEWPORTS) ──
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: c.surface,
                    child: SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _sections.length,
                        itemBuilder: (context, index) {
                          final section = _sections[index];
                          final isSelected = _activeSection == section;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: AppChip(
                              label: section,
                              isSelected: isSelected,
                              onTap: () => setState(() => _activeSection = section),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: catalogList,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String index, String title) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0, top: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              index,
              style: GoogleFonts.plusJakartaSans(
                color: c.primary,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: c.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    final c = context.appColors;
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        color: c.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildInputDemoCard(AppColorExtension c, String stateLabel, Widget inputField) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.primary50,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                stateLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: c.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 14),
            inputField,
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHero(AppColorExtension c, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: c.border,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedReceiptText,
              color: c.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SPLITY DESIGN SYSTEM',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: c.textPrimary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A premium shadowless collection of custom user interface tokens, interactive inputs, and action overlays.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: c.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(String groupLabel, List<Color> colors, List<String> shadeNames) {
    final c = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            groupLabel.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              color: c.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.1,
          ),
          itemCount: colors.length,
          itemBuilder: (context, idx) {
            final color = colors[idx];
            final shade = shadeNames[idx];
            final isLightColor = ThemeData.estimateBrightnessForColor(color) == Brightness.light;
            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color == Colors.transparent || color == c.background ? c.border : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shade,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isLightColor ? Colors.black87 : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTypeRow(BuildContext context, String styleName, String spec, TextStyle? style, {bool isLast = false}) {
    final c = context.appColors;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                styleName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              Text(
                spec,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: c.textDisabled,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The quick brown fox jumps over the lazy dog',
            style: style?.copyWith(color: c.textPrimary),
          ),
          if (!isLast) ...[
            const SizedBox(height: 20),
            const AppDivider(),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryItem(List<List<dynamic>> icon, String name, String subtitle) {
    final c = context.appColors;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.primary50,
                shape: BoxShape.circle,
              ),
              child: HugeIcon(icon: icon, color: c.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: c.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: c.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
