import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';


class STextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? prefix;
  final int? maxLength;
  final bool enabled;
  final String? Function(String?)? validator;

  const STextField({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.maxLength,
    this.enabled = true,
    this.validator,
  });

  @override
  State<STextField> createState() => _STextFieldState();
}

class _STextFieldState extends State<STextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _isFocused = v),
      child: Container(
        decoration: BoxDecoration(
          color: ShiftleyTokens.paperWhite,
          border: _isFocused
              ? ShiftleyTokens.focusBorder
              : ShiftleyTokens.primaryBorder,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          validator: widget.validator,
          style: ShiftleyTokens.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: ShiftleyTokens.bodyMedium.copyWith(
              color: ShiftleyTokens.mutedText,
            ),
            prefixIcon: widget.prefix,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ShiftleyTokens.spaceM,
              vertical: ShiftleyTokens.spaceM,
            ),
          ),
        ),
      ),
    );
  }
}
