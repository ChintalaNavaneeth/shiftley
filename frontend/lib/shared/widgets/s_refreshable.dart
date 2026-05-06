import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class SRefreshable extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const SRefreshable({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: ShiftleyTokens.primaryRed,
      backgroundColor: ShiftleyTokens.paperWhite,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // physics: AlwaysScrollableScrollPhysics() ensures the pull-to-refresh
            // gesture works even if the content doesn't fill the screen.
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
