import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/index.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _nameError;
  String? _upiError;
  String? _emailError;
  bool _isLoading = false;

  int _selectedAvatarIndex = 0;

  final List<String> _avatars = [
    '👨‍💻', '👩‍💻', '🦁', '🦊', '🦄', '🐼', '🐨', '🐙'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _upiController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitProfile() {
    setState(() {
      _nameError = null;
      _upiError = null;
      _emailError = null;
    });

    final name = _nameController.text.trim();
    final upi = _upiController.text.trim();
    final email = _emailController.text.trim();

    bool hasError = false;

    if (name.isEmpty) {
      setState(() {
        _nameError = 'Name is required';
      });
      hasError = true;
    }

    if (upi.isNotEmpty && !RegExp(r'^[\w\.\-_]{2,256}@[a-zA-Z]{2,64}$').hasMatch(upi)) {
      setState(() {
        _upiError = 'Please enter a valid UPI ID (e.g., john@oksbi)';
      });
      hasError = true;
    }

    if (email.isNotEmpty && !RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,10}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      hasError = true;
    }

    if (hasError) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.go('/dashboard-demo');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? c.background : c.neutral50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading
                        Text(
                          'Complete Profile',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isDark ? c.neutral50 : c.neutral900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subheading
                        Text(
                          'Set up your username and UPI details to split expenses with colleagues.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: isDark ? c.neutral400 : c.neutral600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Avatar Selection
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: isDark ? c.surface3 : c.neutral200,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? c.primary400 : c.primary600,
                                    width: 2.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _avatars[_selectedAvatarIndex],
                                    style: const TextStyle(fontSize: 44),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Choose Your Avatar',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? c.neutral400 : c.neutral600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: _avatars.length,
                                  itemBuilder: (context, index) {
                                    final isSelected = index == _selectedAvatarIndex;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedAvatarIndex = index;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: AppConstants.durationFast,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isDark ? c.surface3 : c.neutral200,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? (isDark ? c.primary400 : c.primary600)
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            _avatars[index],
                                            style: const TextStyle(fontSize: 20),
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

                        const SizedBox(height: 24),

                        AppTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'e.g. Prem Parmar',
                          errorText: _nameError,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          showCounter: false,
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          controller: _upiController,
                          label: 'UPI ID (Optional)',
                          hint: 'e.g. name@oksbi',
                          errorText: _upiError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          showCounter: false,
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'e.g. name@example.com',
                          errorText: _emailError,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          enabled: !_isLoading,
                          showCounter: false,
                        ),

                        const Spacer(),
                        const SizedBox(height: 32),

                        AppButton(
                          label: 'Complete Setup',
                          size: AppButtonSize.lg,
                          hasShadow: false,
                          isFullWidth: true,
                          isLoading: _isLoading,
                          onPressed: _submitProfile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
