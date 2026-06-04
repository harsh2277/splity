import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/index.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final int nextPage = (_currentIndex + 1) % _slidesText.length;
        _pageController.animateToPage(
          nextPage,
          duration: AppConstants.durationNormal,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  final List<OnboardingTextData> _slidesText = [
    OnboardingTextData(
      title: 'Split Office Expenses',
      description: 'Easily track and split daily chai, group lunch, or tea outings with your colleagues. Split equally or by custom shares.',
    ),
    OnboardingTextData(
      title: 'Direct UPI Settlement',
      description: 'Settle dues instantly using direct UPI deep links via GPay, PhonePe, Paytm. Zero fees, direct bank-to-bank transfers.',
    ),
    OnboardingTextData(
      title: 'Reminders & Approvals',
      description: 'Send automated WhatsApp nudges to colleagues, configure manager approvals, and stay on top of personal budgets.',
    ),
  ];

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? c.background : c.neutral50,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Header Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? c.surface3 : c.neutral200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedWallet02,
                    color: isDark ? c.primary400 : c.primary600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Splity',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? c.neutral50 : c.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Infinite Scrolling Graphics (3 Rows) ──────────
            Expanded(
              child: ClipRect(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Row 1: Chai & Food items (Left to Right)
                    const InfiniteScrollRow(
                      speed: 0.8,
                      items: [
                        TickerCard(label: '☕ Chai Split', amount: '₹120', color: Color(0xFFF59E0B)),
                        TickerCard(label: '🍕 Team Pizza', amount: '₹1,450', color: Color(0xFFEF4444)),
                        TickerCard(label: '🥤 Cold Coffee', amount: '₹240', color: Color(0xFF3B82F6)),
                        TickerCard(label: '🥪 Snacks Split', amount: '₹350', color: Color(0xFF10B981)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Payments / Settlements (Right to Left / Opp direction)
                    const InfiniteScrollRow(
                      speed: -0.6,
                      items: [
                        TickerCard(label: '✓ Rahul Paid Amit', amount: '₹150', color: Color(0xFF10B981)),
                        TickerCard(label: '✓ Settle Up Dinner', amount: '₹480', color: Color(0xFF6366F1)),
                        TickerCard(label: '✓ Simran Settled', amount: '₹95', color: Color(0xFFEC4899)),
                        TickerCard(label: '✓ Cab Split Done', amount: '₹220', color: Color(0xFF14B8A6)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 3: Personal Budgets
                    const InfiniteScrollRow(
                      speed: 0.7,
                      items: [
                        TickerCard(label: '📈 Lunch Budget', amount: '80%', color: Color(0xFF6366F1)),
                        TickerCard(label: '📉 Daily Limit', amount: '₹500', color: Color(0xFFF59E0B)),
                        TickerCard(label: '📊 Travel Spent', amount: '₹1,200', color: Color(0xFF10B981)),
                        TickerCard(label: '💼 Monthly Saver', amount: '45%', color: Color(0xFF14B8A6)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Page indicators and Text slide details
            SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slidesText.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final textData = _slidesText[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textData.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? c.neutral50 : c.neutral900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          textData.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: isDark ? c.neutral400 : c.neutral600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slidesText.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentIndex == index
                        ? (isDark ? c.primary400 : c.primary600)
                        : (isDark ? c.surface3 : c.neutral300),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),

            // ── Sign-in Actions Layout (Reference Style) ────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Big Google Sign in Button
                  Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      color: isDark ? c.surface3 : c.neutral200,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        onTap: () => context.go('/profile-setup'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.gstatic.com/images/branding/product/2x/googleg_32dp.png',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? c.neutral50 : c.neutral900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Phone OTP login alternative
                  AppButton(
                    label: 'Continue with Phone & OTP',
                    variant: AppButtonVariant.ghost,
                    isFullWidth: true,
                    size: AppButtonSize.lg,
                    onPressed: () => context.go('/login'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingTextData {
  OnboardingTextData({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

// ── Ticker card item representer ───────────────────────────
class TickerCard extends StatelessWidget {
  const TickerCard({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final c = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? c.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? c.surface3 : c.neutral200,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 4,
            backgroundColor: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? c.neutral50 : c.neutral900,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              amount,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Infinite Horizontal Scroll Row Widget ───────────────────
class InfiniteScrollRow extends StatefulWidget {
  const InfiniteScrollRow({
    super.key,
    required this.items,
    required this.speed,
  });

  final List<Widget> items;
  final double speed; // Pos for left-to-right, neg for right-to-left

  @override
  State<InfiniteScrollRow> createState() => _InfiniteScrollRowState();
}

class _InfiniteScrollRowState extends State<InfiniteScrollRow> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final double currentScroll = _scrollController.offset;

        if (widget.speed > 0) {
          if (currentScroll >= maxScroll) {
            _scrollController.jumpTo(0);
          } else {
            _scrollController.jumpTo(currentScroll + widget.speed);
          }
        } else {
          if (currentScroll <= 0) {
            _scrollController.jumpTo(maxScroll);
          } else {
            _scrollController.jumpTo(currentScroll + widget.speed);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Duplicate items list to create seamless infinite wrap effect
    final duplicatedList = [...widget.items, ...widget.items, ...widget.items];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: duplicatedList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: duplicatedList[index],
          );
        },
      ),
    );
  }
}
