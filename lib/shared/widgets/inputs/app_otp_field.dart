import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme_extensions.dart';

// ══════════════════════════════════════════════════════════════
//  AppOtpField — premium shadowless OTP input component
// ══════════════════════════════════════════════════════════════

class AppOtpField extends StatefulWidget {
  const AppOtpField({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.label,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final String? label;
  final bool enabled;

  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<bool> _isFocusedList;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) {
      final node = FocusNode();
      node.addListener(() {
        setState(() {
          _isFocusedList[index] = node.hasFocus;
        });
      });
      return node;
    });
    _isFocusedList = List.generate(widget.length, (index) => false);
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onTextChanged(int index, String value) {
    if (value.isEmpty) {
      widget.onChanged?.call(_currentOtp);
      return;
    }

    // If pasted or typed multiple characters
    if (value.length > 1) {
      _handlePaste(value);
      return;
    }

    widget.onChanged?.call(_currentOtp);

    // Auto-focus next field
    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Check if fully entered
    if (_currentOtp.length == widget.length) {
      widget.onCompleted?.call(_currentOtp);
    }
  }

  void _handlePaste(String pasteVal) {
    final cleanVal = pasteVal.replaceAll(RegExp(r'\D'), '').substring(
      0,
      pasteVal.length > widget.length ? widget.length : pasteVal.length,
    );

    for (int i = 0; i < cleanVal.length; i++) {
      _controllers[i].text = cleanVal[i];
    }

    // Focus last or next unfilled
    final focusIdx = cleanVal.length < widget.length ? cleanVal.length : widget.length - 1;
    _focusNodes[focusIdx].requestFocus();

    widget.onChanged?.call(_currentOtp);
    if (_currentOtp.length == widget.length) {
      widget.onCompleted?.call(_currentOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? c.neutral300 : c.neutral700,
            ),
          ),
          const SizedBox(height: AppConstants.sp8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            final isFocused = _isFocusedList[index];
            final Color borderColor;
            if (!widget.enabled) {
              borderColor = isDark ? c.surface3 : c.neutral200;
            } else if (isFocused) {
              borderColor = isDark ? c.primary400 : c.primary600;
            } else {
              borderColor = Colors.transparent;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SizedBox(
                width: 64,
                height: 64,
              child: CallbackShortcuts(
                bindings: <ShortcutActivator, VoidCallback>{
                  const SingleActivator(LogicalKeyboardKey.backspace): () {
                    if (_controllers[index].text.isEmpty && index > 0) {
                      _controllers[index - 1].clear();
                      _focusNodes[index - 1].requestFocus();
                      widget.onChanged?.call(_currentOtp);
                    } else {
                      _controllers[index].clear();
                      widget.onChanged?.call(_currentOtp);
                    }
                  },
                },
                child: AnimatedContainer(
                  duration: AppConstants.durationFast,
                  margin: const EdgeInsets.all(2.0),
                  clipBehavior: Clip.none,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !widget.enabled
                        ? (isDark ? c.surface : Colors.white)
                        : (isDark ? c.surface : Colors.white),
                    border: Border.all(
                      color: borderColor,
                      width: isFocused ? 1.5 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      enabled: widget.enabled,
                      showCursor: false,
                      enableInteractiveSelection: false,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 2, // allows backspace logic to register more easily if typed fast
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.enabled
                            ? (isDark ? c.neutral50 : c.neutral900)
                            : c.textDisabled,
                      ),
                      onChanged: (val) {
                        if (val.length > 1) {
                          // Keep only the latest typed character, or paste value
                          final lastChar = val.substring(val.length - 1);
                          _controllers[index].text = lastChar;
                          _onTextChanged(index, lastChar);
                        } else {
                          _onTextChanged(index, val);
                        }
                      },
                      decoration: const InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ),);
          }),
        ),
      ],
    );
  }
}
