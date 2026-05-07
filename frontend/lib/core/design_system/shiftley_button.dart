import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

enum ShiftleyButtonSize { small, medium, large }

class ShiftleyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ShiftleyButtonSize size;
  final bool isFullWidth;
  final bool isPrimary;
  final bool isLoading;

  const ShiftleyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.size = ShiftleyButtonSize.medium,
    this.isFullWidth = false,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final double paddingH = _getPaddingH();
    final double paddingV = _getPaddingV();
    final double fontSize = _getFontSize();
    final double iconSize = _getIconSize();

    final Color bgColor = isPrimary ? ShiftleyTokens.inkBlack : ShiftleyTokens.paperWhite;
    final Color textColor = isPrimary ? ShiftleyTokens.paperWhite : ShiftleyTokens.inkBlack;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
            side: const BorderSide(
              color: ShiftleyTokens.inkBlack, 
              width: ShiftleyTokens.borderWidth,
            ),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: iconSize, color: textColor),
                    const SizedBox(width: ShiftleyTokens.spaceS),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label.toUpperCase(),
                        style: ShiftleyTokens.buttonLabel.copyWith(
                          color: textColor,
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  double _getPaddingH() {
    switch (size) {
      case ShiftleyButtonSize.small: return ShiftleyTokens.spaceM;
      case ShiftleyButtonSize.medium: return ShiftleyTokens.spaceL;
      case ShiftleyButtonSize.large: return ShiftleyTokens.spaceXL;
    }
  }

  double _getPaddingV() {
    switch (size) {
      case ShiftleyButtonSize.small: return 8.0;
      case ShiftleyButtonSize.medium: return 12.0;
      case ShiftleyButtonSize.large: return 16.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ShiftleyButtonSize.small: return 12;
      case ShiftleyButtonSize.medium: return 14;
      case ShiftleyButtonSize.large: return 16;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ShiftleyButtonSize.small: return 16;
      case ShiftleyButtonSize.medium: return 20;
      case ShiftleyButtonSize.large: return 24;
    }
  }
}
