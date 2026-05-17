import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class STextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? prefix;
  final int? maxLength;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const STextField({
    super.key,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
    this.onSubmitted,
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
          color: widget.enabled ? ShiftleyTokens.paperWhite : ShiftleyTokens.background,
          border: _isFocused
              ? ShiftleyTokens.focusBorder
              : ShiftleyTokens.primaryBorder,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: ShiftleyTokens.bodyMedium,
          scrollPadding: const EdgeInsets.all(100), // Ensures field is visible above keyboard
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
