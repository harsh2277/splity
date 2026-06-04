import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';

// ══════════════════════════════════════════════════════════════
//  AppSearchField — fully-rounded search input
// ══════════════════════════════════════════════════════════════

class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _ctrl;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    _ctrl.addListener(() => setState(() => _hasText = _ctrl.text.isNotEmpty));
  }

  @override
  void dispose() {
    if (widget.controller == null) _ctrl.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _ctrl.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    final Color borderColor = _isFocused
        ? (isDark ? c.primary400 : c.primary600)
        : (isDark ? c.surface3 : c.neutral200);

    return AnimatedContainer(
      duration: AppConstants.durationFast,
      decoration: BoxDecoration(
        color: isDark ? c.surface2 : c.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(
          color: borderColor,
          width: _isFocused ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            size: AppConstants.iconMd,
            color: _isFocused
                ? (isDark ? c.primary400 : c.primary600)
                : (isDark ? c.neutral400 : c.neutral400),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _ctrl,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              autofocus: widget.autofocus,
              textAlignVertical: TextAlignVertical.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: isDark ? c.neutral50 : c.neutral900,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: isDark ? c.neutral600 : c.neutral400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                isDense: true,
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: _clear,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? c.neutral600 : c.neutral300,
                  ),
                  child: Icon(
                    Iconsax.close_circle,
                    size: 14,
                    color: isDark ? c.neutral200 : c.neutral700,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}
