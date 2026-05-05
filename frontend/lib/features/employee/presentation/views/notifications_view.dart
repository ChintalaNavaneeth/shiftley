import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stay updated with your latest shift approvals and payments.',
          style: ShiftleyTokens.bodyMedium,
        ),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        Expanded(
          child: ListView(
            children: [
              _buildNotificationItem(
                'Shift Approved!',
                'Your application for "Housekeeping" at Taj Banjara has been approved.',
                '2 hours ago',
                Icons.check_circle_outline,
                ShiftleyTokens.secondaryCyan,
                isUnread: true,
              ),
              _buildNotificationItem(
                'Payment Received',
                '₹1,200 has been deposited into your bank account for the "Waiter Service" shift.',
                'Yesterday',
                Icons.account_balance_wallet_outlined,
                Colors.green,
              ),
              _buildNotificationItem(
                'New Gig Recommendation',
                'Based on your skills, you might like the "Event Manager" shift at Gachibowli.',
                '2 days ago',
                Icons.auto_awesome_outlined,
                ShiftleyTokens.primaryRed,
              ),
              _buildNotificationItem(
                'KYC Status Update',
                'Your documents have been successfully verified. You can now apply for premium shifts.',
                '3 days ago',
                Icons.verified_user_outlined,
                Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    String title,
    String body,
    String time,
    IconData icon,
    Color iconColor, {
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: isUnread ? iconColor.withValues(alpha: 0.05) : ShiftleyTokens.paperWhite,
        border: Border.all(
          color: isUnread ? iconColor : ShiftleyTokens.inkBlack,
          width: isUnread ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: ShiftleyTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: ShiftleyTokens.caption),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: ShiftleyTokens.caption.copyWith(
                    fontSize: 10,
                    color: ShiftleyTokens.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
