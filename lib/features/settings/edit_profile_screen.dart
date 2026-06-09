import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _upiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Prem Parmar');
    _emailController = TextEditingController(text: 'prem.parmar@officeshare.com');
    _phoneController = TextEditingController(text: '+91 98765 43210');
    _upiController = TextEditingController(text: 'premparmar@paytm');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      AppSnackbar.success(
        context,
        'Profile updated successfully!',
        showAtTop: true,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Edit Profile',
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Modify Account Info',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? c.neutral50 : c.neutral900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ensure details match your active banking accounts for smooth splitting.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: c.neutral500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  AppTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your name',
                    prefixIcon: HugeIcons.strokeRoundedUser,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  AppTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'Enter email address',
                    prefixIcon: HugeIcons.strokeRoundedMailAtSign01,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  AppTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter phone number',
                    prefixIcon: HugeIcons.strokeRoundedSmartPhone01,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // UPI ID
                  AppTextField(
                    controller: _upiController,
                    label: 'UPI Payment ID',
                    hint: 'Enter UPI ID',
                    prefixIcon: HugeIcons.strokeRoundedQrCode01,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  AppButton(
                    label: 'Save Profile',
                    variant: AppButtonVariant.primary,
                    hasShadow: false,
                    onPressed: _saveProfile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
