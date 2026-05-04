import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class SubscriptionView extends StatelessWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage your subscription and usage limits.', style: ShiftleyTokens.bodyMedium),
          const SizedBox(height: ShiftleyTokens.spaceXL),
  
          // Current Plan Card
          _buildCurrentPlanCard(),
  
          const SizedBox(height: ShiftleyTokens.spaceXL),
  
          const Text('Plan Details', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          _buildDetailRow('Active Since', '24 April, 2026'),
          _buildDetailRow('Auto-renewal', 'Enabled (May 24, 2026)'),
          _buildDetailRow('Last Payment', '₹ 4,999 (Processed)'),
          
          const SizedBox(height: ShiftleyTokens.spaceXL),
  
          const Text('Plan Benefits', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          _buildBenefitItem('Up to 50 active shift postings per month'),
          _buildBenefitItem('Priority listing in Professional search results'),
          _buildBenefitItem('Detailed performance analytics'),
          _buildBenefitItem('Dedicated account manager support'),
  
          const SizedBox(height: ShiftleyTokens.spaceXXL),
  
          // Plan Options (Placeholders)
          const Text('Available Plans', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPlanOption('DAILY', '₹ 499', '5 Shifts', false),
                const SizedBox(width: ShiftleyTokens.spaceM),
                _buildPlanOption('WEEKLY', '₹ 1,999', '20 Shifts', false),
                const SizedBox(width: ShiftleyTokens.spaceM),
                _buildPlanOption('MONTHLY', '₹ 4,999', '50 Shifts', true),
              ],
            ),
          ),
          const SizedBox(height: 100), // Safety bottom padding
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: BoxDecoration(
        color: ShiftleyTokens.inkBlack,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CURRENT PLAN', style: TextStyle(color: ShiftleyTokens.secondaryCyan, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  const Text('Monthly Pro', style: TextStyle(color: ShiftleyTokens.paperWhite, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Figtree')),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          Row(
            children: [
              _buildLargeStat('12 / 50', 'POSTS REMAINING'),
              const SizedBox(width: ShiftleyTokens.spaceXXL),
              _buildLargeStat('14 Days', 'UNTIL EXPIRY'),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          const LinearProgressIndicator(
            value: 0.76, // 38/50 used
            backgroundColor: Color(0xFF333333),
            color: ShiftleyTokens.primaryRed,
            minHeight: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: ShiftleyTokens.paperWhite, fontSize: 24, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: ShiftleyTokens.utilityGrey, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText)),
          Text(value, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: ShiftleyTokens.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildPlanOption(String name, String price, String limit, bool isCurrent) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: isCurrent ? ShiftleyTokens.secondaryCyan : ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 8),
          Text(price, style: ShiftleyTokens.h2),
          Text(limit, style: ShiftleyTokens.caption),
          const SizedBox(height: ShiftleyTokens.spaceM),
          if (isCurrent)
            const Text('Current Plan', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
          else
            ShiftleyButton(
              label: 'Choose',
              onPressed: () {},
              size: ShiftleyButtonSize.small,
              isPrimary: false,
            ),
        ],
      ),
    );
  }
}
