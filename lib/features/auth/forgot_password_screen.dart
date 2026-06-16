import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    setState(() => _emailError = null);

    final email = _emailController.text.trim();

    if (email.isEmpty || !RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,10}$').hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
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
          child: _emailSent ? _buildSuccessState(c, isDark) : _buildFormState(c, isDark),
        ),
      ),
    );
  }

  Widget _buildFormState(dynamic c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? c.surface3 : c.neutral200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedLockPassword,
              color: isDark ? c.primary400 : c.primary600,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Forgot Password?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? c.neutral50 : c.neutral900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your registered email address and we\'ll send you a link to reset your password.',
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
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          showCounter: false,
        ),
        const SizedBox(height: 24),

        AppButton(
          label: 'Send Reset Link',
          size: AppButtonSize.lg,
          hasShadow: false,
          isFullWidth: true,
          isLoading: _isLoading,
          onPressed: _sendResetLink,
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remember your password? ',
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
      ],
    );
  }

  Widget _buildSuccessState(dynamic c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? c.success500.withValues(alpha: 0.15) : c.success500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedMailSend01,
              color: c.success500,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Check Your Email',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? c.neutral50 : c.neutral900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: isDark ? c.neutral400 : c.neutral600,
            ),
            children: [
              const TextSpan(text: 'We\'ve sent a password reset link to '),
              TextSpan(
                text: _emailController.text.trim(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? c.neutral50 : c.neutral900,
                ),
              ),
              const TextSpan(text: '. Check your inbox and follow the instructions.'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Info box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? c.surface3 : c.neutral200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedInformationCircle,
                color: isDark ? c.neutral400 : c.neutral500,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Didn\'t receive the email? Check your spam folder or wait a few minutes before trying again.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? c.neutral400 : c.neutral600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        AppButton(
          label: 'Back to Sign In',
          size: AppButtonSize.lg,
          hasShadow: false,
          isFullWidth: true,
          onPressed: () => context.go('/login'),
        ),
        const SizedBox(height: 16),

        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _emailSent = false;
                _emailController.clear();
              });
            },
            child: Text(
              'Resend reset link',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? c.primary400 : c.primary600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
