import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../shared/widgets/index.dart';
import 'groups_provider.dart';

class GroupsListScreen extends ConsumerStatefulWidget {
  const GroupsListScreen({super.key});

  @override
  ConsumerState<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends ConsumerState<GroupsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<LinearGradient> _presetGradients = const [
    LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFDB2777)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'office':
        return Iconsax.briefcase;
      case 'home':
        return Iconsax.home;
      case 'travel':
        return Iconsax.routing;
      default:
        return Iconsax.element_4;
    }
  }

  IconData _getPresetIconData(String name) {
    switch (name) {
      case 'briefcase':
        return Iconsax.briefcase;
      case 'home':
        return Iconsax.home;
      case 'routing':
        return Iconsax.routing;
      case 'coffee':
        return Iconsax.coffee;
      case 'shopping_bag':
        return Iconsax.shopping_bag;
      case 'car':
        return Iconsax.car;
      case 'game':
        return Iconsax.game;
      case 'wallet_3':
        return Iconsax.wallet_3;
      default:
        return Iconsax.element_4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final c = context.appColors;
    final groups = ref.watch(groupsProvider);

    // Filter groups based on search query
    final filteredGroups = groups.where((g) {
      return g.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.companyName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Stats calculations
    int totalGroups = groups.length;
    double totalOwed = 0;
    double totalOwe = 0;
    for (var g in groups) {
      if (g.balance.contains('Owed')) {
        final val = double.tryParse(g.balance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        totalOwed += val;
      } else if (g.balance.contains('Owe')) {
        final val = double.tryParse(g.balance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        totalOwe += val;
      }
    }

    // Mock names list for member avatars preview
    final List<String> groupMembers = ['Prem', 'Aman', 'Rohit', 'Dev', 'Neha'];

    return Scaffold(
      backgroundColor: isDark ? c.background : c.neutral50,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── PREMIUM TOP TITLE & PROFILE BAR ──
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
                          'Office Groups',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            color: isDark ? c.neutral50 : c.neutral900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Split and track group expenses',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? c.neutral500 : c.neutral500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildHeaderActionButton(
                          icon: Iconsax.add_circle,
                          tooltip: 'Create Group',
                          onTap: () => context.push('/create-group'),
                          isDark: isDark,
                          c: c,
                        ),
                        const SizedBox(width: 8),
                        _buildHeaderActionButton(
                          icon: Iconsax.scan_barcode,
                          tooltip: 'Join Group',
                          onTap: () => context.push('/join-group'),
                          isDark: isDark,
                          c: c,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),



            // ── COMPACT BUT DETAIL-RICH SEPARATE APP CARDS ──
            filteredGroups.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, c, isDark),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final group = filteredGroups[index];
                          final gradientIndex = int.tryParse(group.id) != null
                              ? (int.parse(group.id) % _presetGradients.length)
                              : 0;
                          final hasFileImage = group.imageUrl != null && File(group.imageUrl!).existsSync();

                          Color balanceFg = isDark ? c.neutral300 : c.neutral700;
                          double progressVal = 0.7; // Settlement ratio
                          if (group.balance.contains('Owed')) {
                            balanceFg = c.success500;
                            progressVal = 0.45;
                          } else if (group.balance.contains('Owe')) {
                            balanceFg = c.error500;
                            progressVal = 0.2;
                          } else {
                            progressVal = 1.0;
                          }

                          // Beautifully extract the clean numeric amount from the balance string
                          final cleanAmount = group.balance == 'Settled'
                              ? '₹0'
                              : group.balance.replaceAll('Owe ', '').replaceAll('Owed ', '');

                          String balanceLabel = 'Settled';
                          if (group.balance.contains('Owed')) {
                            balanceLabel = 'You are owed';
                          } else if (group.balance.contains('Owe')) {
                            balanceLabel = 'You owe';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: AppCard(
                              variant: AppCardVariant.elevated,
                              onTap: () => context.push('/group-details/${group.id}'),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Top Row: Avatar, Info, and Balance ---
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Squircle Category Avatar
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          gradient: hasFileImage ? null : _presetGradients[gradientIndex],
                                          image: hasFileImage
                                              ? DecorationImage(
                                                  image: FileImage(File(group.imageUrl!)),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: hasFileImage
                                            ? null
                                            : Center(
                                                child: Icon(
                                                  group.imageUrl != null && group.imageUrl!.startsWith('preset_icon:')
                                                      ? _getPresetIconData(group.imageUrl!.replaceAll('preset_icon:', ''))
                                                      : _getTypeIcon(group.type),
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Main Column details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              group.name,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17.5,
                                                color: isDark ? c.neutral50 : c.neutral900,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${group.companyName} • ${group.type}',
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



                                  // --- Bottom Row: Member Avatars & Invite Code Badge ---
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppAvatarGroup(
                                            names: groupMembers.take(group.membersCount.clamp(1, 5)).toList(),
                                            size: AppAvatarSize.sm,
                                            maxVisible: 3,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            group.membersCount > 1
                                                ? '${group.membersCount} members'
                                                : '1 member',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? c.neutral400 : c.neutral500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      AppBadge(
                                        label: '#${group.inviteCode}',
                                        type: AppBadgeType.neutral,
                                        size: AppBadgeSize.sm,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: filteredGroups.length,
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

  Widget _buildSummaryStat({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required AppColorExtension c,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? c.neutral500 : c.neutral500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
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
            'No Matching Groups',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? c.neutral50 : c.neutral900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search keywords to find your office groups.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? c.neutral400 : c.neutral500,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Create New Group',
            isFullWidth: true,
            onPressed: () => context.push('/create-group'),
          ),
        ],
      ),
    );
  }
}
