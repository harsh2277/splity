import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _phoneError;
  int _timerSeconds = 30;
  Timer? _timer;

  @override
  void dispose() {
    _phoneController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() {
        _phoneError = 'Please enter a valid 10-digit phone number';
      });
      return;
    }

    setState(() {
      _phoneError = null;
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
        });
        _startTimer();
      }
    });
  }

  void _verifyOtp(String otp) {
    if (otp.length < 4) return;

    setState(() {
      _isVerifying = true;
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        context.go('/profile-setup');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? c.background : c.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            if (_isOtpSent) {
              setState(() {
                _isOtpSent = false;
              });
            } else {
              context.go('/onboarding');
            }
          },
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
                          _isOtpSent ? 'Verify OTP' : 'Let\'s Sign You In',
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
                          _isOtpSent
                              ? 'Enter the 4-digit verification code sent to +91 ${_phoneController.text}'
                              : 'Enter your phone number to receive a one-time verification code.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: isDark ? c.neutral400 : c.neutral600,
                          ),
                        ),
                        if (_isOtpSent) ...[
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isOtpSent = false;
                              });
                            },
                            child: Text(
                              'Wrong phone number?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? c.primary400 : c.primary600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),

                        // Inputs Section
                        if (!_isOtpSent)
                          AppTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: 'Enter 10-digit number',
                            errorText: _phoneError,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            enabled: !_isLoading,
                            showCounter: false,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          )
                        else
                          Center(
                            child: AppOtpField(
                              length: 4,
                              enabled: !_isVerifying,
                              onCompleted: _verifyOtp,
                            ),
                          ),

                        const Spacer(),

                        // Bottom Section: Buttons and Resend Timers
                        if (!_isOtpSent) ...[
                          AppButton(
                            label: 'Send OTP',
                            size: AppButtonSize.lg,
                            hasShadow: false,
                            isFullWidth: true,
                            isLoading: _isLoading,
                            onPressed: _sendOtp,
                          ),
                        ] else ...[
                          AppButton(
                            label: 'Verify & Continue',
                            size: AppButtonSize.lg,
                            hasShadow: false,
                            isFullWidth: true,
                            isLoading: _isVerifying,
                            onPressed: () => _verifyOtp('1234'),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _timerSeconds > 0
                                    ? 'Resend code in ${_timerSeconds}s'
                                    : 'Didn\'t receive the code? ',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: isDark ? c.neutral400 : c.neutral600,
                                ),
                              ),
                              if (_timerSeconds == 0)
                                GestureDetector(
                                  onTap: () {
                                    AppSnackbar.success(
                                      context,
                                      'Verification code resent successfully!',
                                      showAtTop: true,
                                    );
                                    _startTimer();
                                  },
                                  child: Text(
                                    'Resend OTP',
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
