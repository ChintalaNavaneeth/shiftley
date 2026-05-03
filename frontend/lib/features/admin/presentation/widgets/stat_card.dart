import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool isPositive;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.trend = '',
    this.isPositive = true,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(ShiftleyTokens.spaceS),
                decoration: BoxDecoration(
                  color: ShiftleyTokens.secondaryCyan,
                  borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                  border: ShiftleyTokens.thinBorder,
                ),
                child: Icon(icon, size: 20, color: ShiftleyTokens.inkBlack),
              ),
              if (trend.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ShiftleyTokens.spaceS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trend,
                    style: ShiftleyTokens.caption.copyWith(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Text(label, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText)),
          const SizedBox(height: ShiftleyTokens.spaceXS),
          Text(value, style: ShiftleyTokens.h1),
        ],
      ),
    );
  }
}
