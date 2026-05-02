import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';


enum SButtonType { primary, secondary, utility }

class SButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final SButtonType type;
  final bool isLoading;
  final double? width;

  const SButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = SButtonType.primary,
    this.isLoading = false,
    this.width,
  });

  @override
  State<SButton> createState() => _SButtonState();
}

class _SButtonState extends State<SButton> {
  bool _isPressed = false;

  Color get _bgColor {
    if (widget.onPressed == null) return ShiftleyTokens.utilityGrey;
    switch (widget.type) {
      case SButtonType.primary:   return ShiftleyTokens.primaryRed;
      case SButtonType.secondary: return ShiftleyTokens.secondaryCyan;
      case SButtonType.utility:   return ShiftleyTokens.utilityGrey;
    }
  }

  Color get _textColor =>
      widget.type == SButtonType.primary
          ? ShiftleyTokens.paperWhite
          : ShiftleyTokens.inkBlack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp:   (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        // Neo-brutalism "sinking" effect
        transform: Matrix4.translationValues(
          _isPressed ? 3 : 0,
          _isPressed ? 3 : 0,
          0,
        ),
        width: widget.width ?? double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _bgColor,
          border: ShiftleyTokens.primaryBorder,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _textColor,
                  ),
                )
              : Text(
                  widget.text,
                  style: ShiftleyTokens.buttonLabel.copyWith(color: _textColor),
                ),
        ),
      ),
    );
  }
}
