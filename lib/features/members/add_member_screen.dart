import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import 'members_provider.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;
  bool _inviteSent = false;
  String _generatedLink = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendInvite() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email Address is required';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    // Simulate sending invite link
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final name = email.split('@').first;
      final capitalizedName = name[0].toUpperCase() + name.substring(1);
      final randomId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
      
      // Add member to local provider state
      ref.read(membersProvider.notifier).addMember(
            name: capitalizedName,
            email: email,
            avatar: '✉️',
          );

      setState(() {
        _isLoading = false;
        _inviteSent = true;
        _generatedLink = 'https://splity.app/invite/friend-$randomId';
      });

      AppSnackbar.success(
        context,
        'Invitation link sent to $email!',
        showAtTop: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? c.background : c.neutral50,
      appBar: AppBar(
        title: Text(
          'Invite Friend',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? c.neutral50 : c.neutral900,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const BouncingScrollPhysics(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !_inviteSent
                ? Column(
                    key: const ValueKey('invite_form'),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: isDark ? c.surface : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? c.surface3 : c.neutral200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMailSend02,
                          size: 44,
                          color: isDark ? c.primary400 : c.primary600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Invite via Email Address',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? c.neutral50 : c.neutral900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Type your friend\'s email address below. We will generate and send them a unique join link to start splitting bills.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          height: 1.5,
                          color: isDark ? c.neutral400 : c.neutral600,
                        ),
                      ),
                      const SizedBox(height: 36),

                      AppTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'e.g. friend@office.com',
                        errorText: _emailError,
                        prefixIcon: HugeIcons.strokeRoundedMailAtSign01,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                        onSubmitted: (_) => _sendInvite(),
                      ),

                      const SizedBox(height: 48),

                      AppButton(
                        label: 'Send Invite Link',
                        size: AppButtonSize.lg,
                        isFullWidth: true,
                        isLoading: _isLoading,
                        onPressed: _sendInvite,
                      ),
                    ],
                  )
                : Column(
                    key: const ValueKey('invite_success'),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: isDark ? c.success900.withValues(alpha: 0.15) : c.success100,
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                          size: 48,
                          color: c.success500,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Invitation Sent!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark ? c.neutral50 : c.neutral900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'An email invitation has been sent to ${_emailController.text}. You can also copy and share the invite link manually below.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          height: 1.5,
                          color: isDark ? c.neutral400 : c.neutral600,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Generated Link Card
                      AppCard(
                        variant: AppCardVariant.elevated,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shareable Link',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? c.neutral500 : c.neutral500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _generatedLink,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? c.neutral200 : c.neutral800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Material(
                                  color: isDark ? c.surface3 : c.neutral100,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: _generatedLink));
                                      AppSnackbar.success(
                                        context,
                                        'Link copied to clipboard!',
                                        showAtTop: true,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Text(
                                        'Copy',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? c.primary400 : c.primary600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      AppButton(
                        label: 'Done',
                        size: AppButtonSize.lg,
                        isFullWidth: true,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
