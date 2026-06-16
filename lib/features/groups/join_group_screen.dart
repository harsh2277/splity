import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import 'groups_provider.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();
  
  String? _codeError;
  bool _isLoading = false;
  final bool _isPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _submitCode(String code) {
    if (code.trim().length < 4) {
      setState(() {
        _codeError = 'Invite Code must be at least 4 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _codeError = null;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final success = ref.read(groupsProvider.notifier).joinGroup(code);
      
      setState(() {
        _isLoading = false;
      });

      if (success) {
        AppSnackbar.success(
          context,
          'Successfully joined group!',
        );
        context.pop();
      } else {
        setState(() {
          _codeError = 'Already a member of this group or code is invalid.';
        });
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
        title: Text(
          'Join Group',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? c.neutral50 : c.neutral900,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? c.surface : c.neutral200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? c.primary500 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 4,
                  )
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: isDark ? Colors.white : c.neutral900,
              unselectedLabelColor: isDark ? c.neutral400 : c.neutral500,
              labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Invitation Code'),
                Tab(text: 'Scan QR Code'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // ── TAB 1: CODE INPUT ──
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? c.surface : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? c.surface3 : c.neutral200),
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedKey01,
                      size: 40,
                      color: isDark ? c.primary400 : c.primary600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enter Group Invite Code',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? c.neutral50 : c.neutral900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ask the group administrator for the 6-character code and enter it below to join the expense list.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? c.neutral400 : c.neutral600,
                    ),
                  ),
                  const SizedBox(height: 36),
                  AppTextField(
                    controller: _codeController,
                    label: 'Invite Code',
                    hint: 'e.g. CHAI24',
                    errorText: _codeError,
                    prefixIcon: HugeIcons.strokeRoundedLink01,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    onSubmitted: _submitCode,
                  ),
                  const SizedBox(height: 48),
                  AppButton(
                    label: 'Join Group',
                    size: AppButtonSize.lg,
                    isFullWidth: true,
                    isLoading: _isLoading,
                    onPressed: () => _submitCode(_codeController.text),
                  ),
                ],
              ),
            ),

            // ── TAB 2: QR SCANNER ──
            Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _isPermissionDenied
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'Camera permission is required to scan QR codes.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: isDark ? c.neutral300 : c.neutral700),
                                ),
                              ),
                            )
                          : MobileScanner(
                              controller: _scannerController,
                              onDetect: (capture) {
                                final List<Barcode> barcodes = capture.barcodes;
                                for (final barcode in barcodes) {
                                  if (barcode.rawValue != null) {
                                    final scannedCode = barcode.rawValue!;
                                    _scannerController.stop();
                                    _submitCode(scannedCode);
                                    break;
                                  }
                                }
                              },
                            ),
                      if (!_isPermissionDenied) ...[
                        // Semi-transparent background mask
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.5),
                            BlendMode.srcOut,
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 240,
                                  height: 240,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Corner neon lines
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark ? c.primary400 : c.primary600,
                              width: 3.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: isDark ? c.surface : Colors.white,
                    border: Border(
                      top: BorderSide(color: isDark ? c.surface3 : c.neutral200),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedQrCode, color: isDark ? c.primary400 : c.primary600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Align Group QR inside the Box',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? c.neutral50 : c.neutral900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Align the QR code from a colleague\'s device inside the box to join immediately.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? c.neutral500 : c.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
