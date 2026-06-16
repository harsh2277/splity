import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/index.dart';

// Country model
class _Country {
  const _Country({
    required this.flag,
    required this.name,
    required this.code,
    required this.hint,
  });
  final String flag;
  final String name;
  final String code;
  final String hint; // typical number format hint
}

const List<_Country> _allCountries = [
  _Country(flag: '🇮🇳', name: 'India', code: '+91', hint: '98765 43210'),
  _Country(flag: '🇺🇸', name: 'United States', code: '+1', hint: '(201) 555-0123'),
  _Country(flag: '🇬🇧', name: 'United Kingdom', code: '+44', hint: '07700 900123'),
  _Country(flag: '🇦🇺', name: 'Australia', code: '+61', hint: '0412 345 678'),
  _Country(flag: '🇦🇪', name: 'UAE', code: '+971', hint: '050 123 4567'),
  _Country(flag: '🇸🇬', name: 'Singapore', code: '+65', hint: '8123 4567'),
  _Country(flag: '🇨🇦', name: 'Canada', code: '+1', hint: '(416) 555-0123'),
  _Country(flag: '🇩🇪', name: 'Germany', code: '+49', hint: '0151 23456789'),
  _Country(flag: '🇫🇷', name: 'France', code: '+33', hint: '06 12 34 56 78'),
  _Country(flag: '🇮🇹', name: 'Italy', code: '+39', hint: '312 345 6789'),
  _Country(flag: '🇪🇸', name: 'Spain', code: '+34', hint: '612 34 56 78'),
  _Country(flag: '🇵🇹', name: 'Portugal', code: '+351', hint: '912 345 678'),
  _Country(flag: '🇳🇱', name: 'Netherlands', code: '+31', hint: '06 12345678'),
  _Country(flag: '🇧🇪', name: 'Belgium', code: '+32', hint: '0470 12 34 56'),
  _Country(flag: '🇨🇭', name: 'Switzerland', code: '+41', hint: '079 123 45 67'),
  _Country(flag: '🇦🇹', name: 'Austria', code: '+43', hint: '0664 1234567'),
  _Country(flag: '🇸🇪', name: 'Sweden', code: '+46', hint: '070 123 45 67'),
  _Country(flag: '🇳🇴', name: 'Norway', code: '+47', hint: '412 34 567'),
  _Country(flag: '🇩🇰', name: 'Denmark', code: '+45', hint: '20 12 34 56'),
  _Country(flag: '🇫🇮', name: 'Finland', code: '+358', hint: '050 1234567'),
  _Country(flag: '🇵🇱', name: 'Poland', code: '+48', hint: '512 345 678'),
  _Country(flag: '🇨🇿', name: 'Czech Republic', code: '+420', hint: '601 123 456'),
  _Country(flag: '🇭🇺', name: 'Hungary', code: '+36', hint: '20 123 4567'),
  _Country(flag: '🇷🇴', name: 'Romania', code: '+40', hint: '0712 345 678'),
  _Country(flag: '🇧🇬', name: 'Bulgaria', code: '+359', hint: '087 123 4567'),
  _Country(flag: '🇷🇺', name: 'Russia', code: '+7', hint: '912 345-67-89'),
  _Country(flag: '🇺🇦', name: 'Ukraine', code: '+380', hint: '067 123 4567'),
  _Country(flag: '🇹🇷', name: 'Turkey', code: '+90', hint: '0532 123 4567'),
  _Country(flag: '🇮🇱', name: 'Israel', code: '+972', hint: '050 123 4567'),
  _Country(flag: '🇸🇦', name: 'Saudi Arabia', code: '+966', hint: '050 123 4567'),
  _Country(flag: '🇶🇦', name: 'Qatar', code: '+974', hint: '3312 3456'),
  _Country(flag: '🇰🇼', name: 'Kuwait', code: '+965', hint: '5012 3456'),
  _Country(flag: '🇧🇭', name: 'Bahrain', code: '+973', hint: '3612 3456'),
  _Country(flag: '🇴🇲', name: 'Oman', code: '+968', hint: '9212 3456'),
  _Country(flag: '🇯🇴', name: 'Jordan', code: '+962', hint: '079 123 4567'),
  _Country(flag: '🇱🇧', name: 'Lebanon', code: '+961', hint: '70 123 456'),
  _Country(flag: '🇵🇰', name: 'Pakistan', code: '+92', hint: '0312 3456789'),
  _Country(flag: '🇧🇩', name: 'Bangladesh', code: '+880', hint: '01712 345678'),
  _Country(flag: '🇱🇰', name: 'Sri Lanka', code: '+94', hint: '071 234 5678'),
  _Country(flag: '🇳🇵', name: 'Nepal', code: '+977', hint: '984 1234567'),
  _Country(flag: '🇲🇾', name: 'Malaysia', code: '+60', hint: '012-345 6789'),
  _Country(flag: '🇮🇩', name: 'Indonesia', code: '+62', hint: '0812 3456 7890'),
  _Country(flag: '🇵🇭', name: 'Philippines', code: '+63', hint: '0917 123 4567'),
  _Country(flag: '🇹🇭', name: 'Thailand', code: '+66', hint: '081 234 5678'),
  _Country(flag: '🇻🇳', name: 'Vietnam', code: '+84', hint: '090 123 4567'),
  _Country(flag: '🇰🇷', name: 'South Korea', code: '+82', hint: '010-1234-5678'),
  _Country(flag: '🇯🇵', name: 'Japan', code: '+81', hint: '090-1234-5678'),
  _Country(flag: '🇨🇳', name: 'China', code: '+86', hint: '138 0013 8000'),
  _Country(flag: '🇭🇰', name: 'Hong Kong', code: '+852', hint: '5123 4567'),
  _Country(flag: '🇹🇼', name: 'Taiwan', code: '+886', hint: '0912 345 678'),
  _Country(flag: '🇳🇿', name: 'New Zealand', code: '+64', hint: '021 123 4567'),
  _Country(flag: '🇿🇦', name: 'South Africa', code: '+27', hint: '071 123 4567'),
  _Country(flag: '🇳🇬', name: 'Nigeria', code: '+234', hint: '0802 345 6789'),
  _Country(flag: '🇰🇪', name: 'Kenya', code: '+254', hint: '0712 345678'),
  _Country(flag: '🇬🇭', name: 'Ghana', code: '+233', hint: '024 123 4567'),
  _Country(flag: '🇪🇹', name: 'Ethiopia', code: '+251', hint: '091 123 4567'),
  _Country(flag: '🇺🇬', name: 'Uganda', code: '+256', hint: '0712 345678'),
  _Country(flag: '🇹🇿', name: 'Tanzania', code: '+255', hint: '0712 345678'),
  _Country(flag: '🇷🇼', name: 'Rwanda', code: '+250', hint: '0780 123 456'),
  _Country(flag: '🇲🇽', name: 'Mexico', code: '+52', hint: '1 234 567 8901'),
  _Country(flag: '🇧🇷', name: 'Brazil', code: '+55', hint: '(11) 91234-5678'),
  _Country(flag: '🇦🇷', name: 'Argentina', code: '+54', hint: '011 1234 5678'),
  _Country(flag: '🇨🇴', name: 'Colombia', code: '+57', hint: '312 345 6789'),
  _Country(flag: '🇨🇱', name: 'Chile', code: '+56', hint: '9 1234 5678'),
  _Country(flag: '🇵🇪', name: 'Peru', code: '+51', hint: '912 345 678'),
  _Country(flag: '🇻🇪', name: 'Venezuela', code: '+58', hint: '0412 345 6789'),
  _Country(flag: '🇪🇨', name: 'Ecuador', code: '+593', hint: '099 123 4567'),
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();

  bool _isLoading = false;
  bool _phoneFocused = false;
  String? _emailError;
  String? _passwordError;
  String? _phoneError;

  _Country _selected = _allCountries.first; // India default

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() => _phoneFocused = _phoneFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    AppBottomSheet.show(
      context,
      title: 'Select Country',
      maxHeightFraction: 0.88,
      child: _CountryPickerContent(
        selected: _selected,
        onSelect: (country) {
          setState(() => _selected = country);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _register() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _phoneError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();

    bool hasError = false;

    if (email.isEmpty || !RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,10}$').hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      hasError = true;
    }

    if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      hasError = true;
    }

    if (phone.isNotEmpty && phone.length < 7) {
      setState(() => _phoneError = 'Please enter a valid phone number');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/profile-setup');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark ? c.background : c.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.go('/login'),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: isDark ? c.neutral50 : c.neutral900,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  'Back',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? c.neutral50 : c.neutral900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? c.neutral50 : c.neutral900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign up with your email to start splitting expenses with colleagues.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: isDark ? c.neutral400 : c.neutral600,
                ),
              ),
              const SizedBox(height: 32),

              AppTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'e.g. name@example.com',
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
                showCounter: false,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Min. 6 characters',
                errorText: _passwordError,
                isPassword: true,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
                showCounter: false,
              ),
              const SizedBox(height: 16),

              // ── Phone field — same style as AppTextField ──────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mobile Number (Optional)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _phoneError != null
                          ? c.error500
                          : (_phoneFocused
                              ? (isDark ? c.primary400 : c.primary600)
                              : (isDark ? c.neutral300 : c.neutral700)),
                    ),
                  ),
                  const SizedBox(height: AppConstants.sp8),
                  AnimatedContainer(
                    duration: AppConstants.durationFast,
                    decoration: BoxDecoration(
                      color: isDark ? c.surface3 : c.neutral200,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      border: Border.all(
                        color: _phoneError != null
                            ? c.error500
                            : (_phoneFocused
                                ? (isDark ? c.primary400 : c.primary600)
                                : Colors.transparent),
                        width: (_phoneError != null || _phoneFocused) ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Country code button
                        GestureDetector(
                          onTap: _isLoading ? null : _showCountryPicker,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 14, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_selected.flag, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(
                                  _selected.code,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? c.neutral50 : c.neutral900,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowDown01,
                                  color: isDark ? c.neutral400 : c.neutral500,
                                  size: 13,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Divider
                        Container(
                          width: 1,
                          height: 18,
                          color: isDark ? c.neutral600 : c.neutral300,
                        ),
                        // Phone text input
                        Expanded(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: const InputDecorationTheme(filled: false),
                            ),
                            child: TextField(
                            controller: _phoneController,
                            focusNode: _phoneFocusNode,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? c.neutral50 : c.neutral900,
                            ),
                            decoration: InputDecoration(
                              hintText: '${_selected.code} ${_selected.hint}',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDark ? c.neutral600 : c.neutral400,
                              ),
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 18,
                              ),
                              counterText: '',
                            ),
                          ),
                        ),
                        ),
                      ],
                    ),
                  ),
                  if (_phoneError != null) ...[
                    const SizedBox(height: AppConstants.sp6),
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedInformationCircle,
                          size: 14,
                          color: c.error500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _phoneError!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: c.error500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              const Spacer(),

              AppButton(
                label: 'Create Account',
                size: AppButtonSize.lg,
                hasShadow: false,
                isFullWidth: true,
                isLoading: _isLoading,
                onPressed: _register,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: isDark ? c.neutral400 : c.neutral600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? c.primary400 : c.primary600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Country picker bottom sheet content ──────────────────────
class _CountryPickerContent extends StatefulWidget {
  const _CountryPickerContent({
    required this.selected,
    required this.onSelect,
  });

  final _Country selected;
  final void Function(_Country) onSelect;

  @override
  State<_CountryPickerContent> createState() => _CountryPickerContentState();
}

class _CountryPickerContentState extends State<_CountryPickerContent> {
  final _searchController = TextEditingController();
  List<_Country> _filtered = _allCountries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? _allCountries
          : _allCountries.where((c) {
              return c.name.toLowerCase().contains(q) ||
                  c.code.contains(q);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        AppTextField(
          controller: _searchController,
          hint: 'Search country or code...',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          showCounter: false,
          autofocus: true,
          onChanged: _onSearch,
        ),
        const SizedBox(height: 12),

        // Country list
        if (_filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No countries found',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: isDark ? c.neutral400 : c.neutral600,
                ),
              ),
            ),
          )
        else
          ...(_filtered.map((country) {
            final isSelected = country.code == widget.selected.code &&
                country.name == widget.selected.name;
            return GestureDetector(
              onTap: () => widget.onSelect(country),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: AppConstants.durationFast,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? c.primary600.withValues(alpha: 0.15) : c.primary50.withValues(alpha: 0.6))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(country.flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        country.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isDark ? c.neutral50 : c.neutral900,
                        ),
                      ),
                    ),
                    Text(
                      country.code,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? (isDark ? c.primary400 : c.primary600)
                            : (isDark ? c.neutral400 : c.neutral500),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                        size: 16,
                        color: isDark ? c.primary400 : c.primary600,
                      ),
                    ],
                  ],
                ),
              ),
            );
          })),
      ],
    );
  }
}
