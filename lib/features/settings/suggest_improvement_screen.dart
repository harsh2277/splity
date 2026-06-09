import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';

class SuggestImprovementScreen extends StatefulWidget {
  const SuggestImprovementScreen({super.key});

  @override
  State<SuggestImprovementScreen> createState() => _SuggestImprovementScreenState();
}

class _SuggestImprovementScreenState extends State<SuggestImprovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Prem Parmar');
  final _emailController = TextEditingController(text: 'prem.parmar@officeshare.com');
  final _countryController = TextEditingController(text: 'India');
  final _titleController = TextEditingController();
  final _suggestionController = TextEditingController();

  void _submitSuggestion() {
    if (_countryController.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Please enter a country');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Please enter a title');
      return;
    }
    if (_suggestionController.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Please enter your suggestion or feedback');
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      AppSnackbar.success(
        context,
        'Feedback submitted! Thank you for helping us improve Splity.',
        showAtTop: true,
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _titleController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = context.appColors;

    return Scaffold(
      backgroundColor: isDark ? c.background : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Improve Splity',
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
                    'What should we build next?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? c.neutral50 : c.neutral900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We design Splity around your feedback. Let us know what features or improvements you\'d love to see.',
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
                    label: 'Name',
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

                  // Country
                  AppTextField(
                    controller: _countryController,
                    label: 'Country',
                    hint: 'Enter your country',
                    prefixIcon: HugeIcons.strokeRoundedGlobal,
                  ),
                  const SizedBox(height: 16),

                  // Feature Title
                  AppTextField(
                    controller: _titleController,
                    label: 'Feature Title',
                    hint: 'Enter a short title for your suggestion',
                    prefixIcon: HugeIcons.strokeRoundedNotebook,
                  ),
                  const SizedBox(height: 16),

                  // Suggestion Box
                  AppTextField(
                    controller: _suggestionController,
                    label: 'Suggestion / Feedback details',
                    hint: 'e.g. Add OCR scanner for bills, allow export to Excel...',
                    prefixIcon: HugeIcons.strokeRoundedInformationCircle,
                    isMultiline: true,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  AppButton(
                    label: 'Send Feedback',
                    variant: AppButtonVariant.primary,
                    hasShadow: false,
                    onPressed: _submitSuggestion,
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
