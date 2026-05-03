import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Alerts & Activity', style: ShiftleyTokens.h2),
        const SizedBox(height: ShiftleyTokens.spaceM),
        
        // Removed StatCards and the outer container card
        _ActivityItem(
          title: 'New Dispute Raised',
          subtitle: 'Professional #1234 reported payment issue with Gig #552',
          time: '2 mins ago',
          type: Icons.warning_amber_rounded,
          color: ShiftleyTokens.primaryRed,
        ),
        const Divider(color: ShiftleyTokens.background),
        _ActivityItem(
          title: 'Large Gig Posted',
          subtitle: 'Hotel Radisson posted a 50-person catering gig.',
          time: '15 mins ago',
          type: Icons.info_outline,
          color: ShiftleyTokens.inkBlack,
        ),
        const Divider(color: ShiftleyTokens.background),
        _ActivityItem(
          title: 'System Config Update',
          subtitle: 'Admin changed Razorpay fee to 2.5%',
          time: '1 hour ago',
          type: Icons.settings_outlined,
          color: ShiftleyTokens.utilityGrey,
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData type;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ShiftleyTokens.spaceS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(type, color: color, size: 20),
          ),
          const SizedBox(width: ShiftleyTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ShiftleyTokens.bodyLarge),
                Text(subtitle, style: ShiftleyTokens.caption),
              ],
            ),
          ),
          Text(time, style: ShiftleyTokens.caption),
        ],
      ),
    );
  }
}
