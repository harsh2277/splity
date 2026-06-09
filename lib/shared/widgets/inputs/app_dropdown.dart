import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';

class AppDropdownItem<T> {
  final T value;
  final String label;

  const AppDropdownItem({
    required this.value,
    required this.label,
  });
}

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.prefixIcon,
  });

  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final String? label;
  final String? hint;
  final List<List<dynamic>>? prefixIcon;

  void _showBottomSheet(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? c.surface2 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    label!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? c.neutral50 : c.neutral900,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
              ],
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.value == value;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      title: Text(
                        item.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? c.primary400 : c.primary600)
                              : (isDark ? c.neutral50 : c.neutral900),
                        ),
                      ),
                      trailing: isSelected
                          ? HugeIcon(
                              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                              color: isDark ? c.primary400 : c.primary600,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        onChanged(item.value);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;
    
    final selectedItem = items.firstWhere(
      (item) => item.value == value,
      orElse: () => items.first,
    );

    final displayLabel = value != null ? selectedItem.label : (hint ?? 'Select option');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? c.neutral300 : c.neutral700,
            ),
          ),
          const SizedBox(height: AppConstants.sp8),
        ],
        GestureDetector(
          onTap: () => _showBottomSheet(context),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              color: isDark ? c.surface3 : c.neutral200,
              border: Border.all(
                color: Colors.transparent,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  HugeIcon(
                    icon: prefixIcon!,
                    size: AppConstants.iconMd,
                    color: isDark ? c.neutral400 : c.neutral500,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    displayLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: value != null
                          ? (isDark ? c.neutral50 : c.neutral900)
                          : (isDark ? c.neutral600 : c.neutral400),
                    ),
                  ),
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color: isDark ? c.neutral400 : c.neutral500,
                  size: AppConstants.iconMd,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
