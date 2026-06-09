import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import 'members_provider.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final c = context.appColors;
    final members = ref.watch(membersProvider);

    // Filter members based on search query
    final filteredMembers = members.where((m) {
      return m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? c.background : c.neutral50,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── PREMIUM TOP TITLE & ACTION BAR ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Office Friends',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            color: isDark ? c.neutral50 : c.neutral900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track balances with your friends',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? c.neutral500 : c.neutral500,
                          ),
                        ),
                      ],
                    ),
                    _buildHeaderActionButton(
                      icon: Iconsax.user_add_copy,
                      tooltip: 'Add Friend',
                      onTap: () => context.push('/add-member'),
                      isDark: isDark,
                      c: c,
                    ),
                  ],
                ),
              ),
            ),

            // ── SEARCH BAR SLIVER ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverToBoxAdapter(
                child: AppSearchField(
                  controller: _searchController,
                  hint: 'Search members or email...',
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
            ),

            // ── MEMBERS LIST SLIVER ──
            filteredMembers.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, c, isDark),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final member = filteredMembers[index];

                          Color balanceFg = isDark ? c.neutral300 : c.neutral700;
                          if (member.status == 'owed') {
                            balanceFg = c.success500;
                          } else if (member.status == 'owe') {
                            balanceFg = c.error500;
                          }

                          String balanceLabel = 'Settled';
                          if (member.status == 'owed') {
                            balanceLabel = 'Owes you';
                          } else if (member.status == 'owe') {
                            balanceLabel = 'You owe';
                          }

                          final cleanAmount = '₹${member.amount.toStringAsFixed(2)}';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: AppCard(
                              variant: AppCardVariant.elevated,
                              onTap: () => context.push('/member-details/${member.id}'),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Top Row: Avatar, Info, and Balance ---
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Squircle Avatar
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: isDark ? c.surface2 : c.neutral100,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isDark ? c.surface3 : c.neutral200,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            member.avatar,
                                            style: const TextStyle(fontSize: 26),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Member info column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              member.name,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17.5,
                                                color: isDark ? c.neutral50 : c.neutral900,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              member.email,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: isDark ? c.neutral500 : c.neutral500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Balance column
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            balanceLabel,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? c.neutral500 : c.neutral500,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            cleanAmount,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w800,
                                              color: balanceFg,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // --- Divider ---
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: AppDivider(),
                                  ),

                                  // --- Bottom Row: Member Status Info & Invite code representation ---
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        member.status == 'settled' ? 'No outstanding bills' : 'Pending balances',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? c.neutral400 : c.neutral500,
                                        ),
                                      ),
                                      AppBadge(
                                        label: member.status.toUpperCase(),
                                        type: member.status == 'owed'
                                            ? AppBadgeType.success
                                            : member.status == 'owe'
                                                ? AppBadgeType.error
                                                : AppBadgeType.neutral,
                                        size: AppBadgeSize.sm,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: filteredMembers.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
    required AppColorExtension c,
  }) {
    return Material(
      color: isDark ? c.surface : Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? c.surface3 : c.neutral200),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? c.neutral100 : c.neutral900,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppColorExtension c, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? c.surface : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 20,
                )
              ],
            ),
            child: Icon(
              Iconsax.profile_2user,
              size: 56,
              color: isDark ? c.primary400 : c.primary600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Matching Friends',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? c.neutral50 : c.neutral900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search query or add a new friend to your office split list.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? c.neutral400 : c.neutral500,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Add New Friend',
            isFullWidth: true,
            onPressed: () => context.push('/add-member'),
          ),
        ],
      ),
    );
  }
}
