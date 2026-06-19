import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import 'auth_provider.dart';
import 'auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool hasError = false;

    if (email.isEmpty || !RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,10}$').hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      hasError = true;
    }

    if (password.length < 8) {
      setState(() => _passwordError = 'Password must be at least 8 characters');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signIn(
            email: email,
            password: password,
          );

      if (mounted) {
        context.go('/dashboard-demo');
      }
    } on AuthException catch (error) {
      if (mounted) {
        AppSnackbar.error(context, error.message);
      }
    } on AuthConfigException catch (error) {
      if (mounted) {
        AppSnackbar.error(context, error.toString());
      }
    } catch (e) {
      print('Sign-in error: $e');
      if (mounted) {
        AppSnackbar.error(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          onTap: () => context.go('/onboarding'),
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
                          'Welcome Back',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isDark ? c.neutral50 : c.neutral900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in with your email and password to continue.',
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
                          hint: 'Enter your password',
                          errorText: _passwordError,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          enabled: !_isLoading,
                          showCounter: false,
                        ),

                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => context.go('/forgot-password'),
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? c.primary400 : c.primary600,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        AppButton(
                          label: 'Sign In',
                          size: AppButtonSize.lg,
                          hasShadow: false,
                          isFullWidth: true,
                          isLoading: _isLoading,
                          onPressed: _login,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: isDark ? c.neutral400 : c.neutral600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/register'),
                              child: Text(
                                'Create Account',
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
