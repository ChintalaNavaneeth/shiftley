import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable guidance wrapper that shows a SnackBar message (and vibrates)
/// when the user taps on a non-interactive or restricted component.
class ShiftleyGuidance extends StatefulWidget {
  final Widget child;
  final String message;
  final bool isActive;
  final bool isTranslucent;

  const ShiftleyGuidance({
    super.key,
    required this.child,
    required this.message,
    this.isActive = true,
    this.isTranslucent = false,
  });

  @override
  State<ShiftleyGuidance> createState() => _ShiftleyGuidanceState();
}

class _ShiftleyGuidanceState extends State<ShiftleyGuidance> {
  bool _isShowing = false;

  void _showGuidance() {
    if (_isShowing) return;

    setState(() => _isShowing = true);
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.message),
        duration: const Duration(seconds: 3),
        onVisible: () {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _isShowing = false);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return GestureDetector(
      onTap: _showGuidance,
      behavior: HitTestBehavior.opaque,
      child: widget.isTranslucent
          ? Opacity(
              opacity: 0.6,
              child: AbsorbPointer(child: widget.child),
            )
          : widget.child,
    );
  }
}
