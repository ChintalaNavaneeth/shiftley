import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome back, Rahul!', style: ShiftleyTokens.h1),
          const SizedBox(height: ShiftleyTokens.spaceXS),
          Text('You have 2 upcoming shifts this week.', style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText)),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Reliability',
                  '100%',
                  Icons.verified_user_outlined,
                  ShiftleyTokens.secondaryCyan,
                ),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: _buildStatCard(
                  'Total Earned',
                  '₹12,450',
                  Icons.account_balance_wallet_outlined,
                  ShiftleyTokens.paperWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Next Shift Section
          const Text('Next Shift', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          _buildNextShiftCard(
            context,
            'Housekeeping Professional',
            'Taj Banjara, Hyderabad',
            'Tomorrow, 09:00 AM - 05:00 PM',
            '₹800',
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Quick Actions
          const Text('Quick Actions', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Find Gigs',
                  Icons.search,
                  () {},
                ),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: _buildActionButton(
                  'My History',
                  Icons.history,
                  () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: color,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        boxShadow: const [
          BoxShadow(
            color: ShiftleyTokens.inkBlack,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: ShiftleyTokens.spaceS),
          Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: ShiftleyTokens.h2),
        ],
      ),
    );
  }

  Widget _buildNextShiftCard(BuildContext context, String title, String location, String time, String pay) {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
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
              Text(title, style: ShiftleyTokens.bodyLarge),
              Text(pay, style: ShiftleyTokens.h2.copyWith(color: Colors.green)),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceS),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text(location, style: ShiftleyTokens.caption),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text(time, style: ShiftleyTokens.caption),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          ShiftleyButton(
            label: 'Check-In Details',
            onPressed: () {},
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceL),
        decoration: BoxDecoration(
          color: ShiftleyTokens.paperWhite,
          border: ShiftleyTokens.primaryBorder,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: ShiftleyTokens.spaceS),
            Text(label, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
