import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class FAQView extends StatelessWidget {
  const FAQView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Find quick answers to common questions about the platform.', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        _buildCategoryHeader('GIG MANAGEMENT'),
        _buildFAQItem(context, 'How do I cancel a GIG?', 'You can cancel a GIG from the Manage GIGS tab. Cancellation fees apply based on the time remaining before the shift starts.'),
        _buildFAQItem(context, 'Can I unhire a professional?', 'Yes, you can unhire a professional from the applicant list or their profile view before the shift starts.'),
        
        const SizedBox(height: ShiftleyTokens.spaceXL),

        _buildCategoryHeader('PAYMENTS & SUBSCRIPTIONS'),
        _buildFAQItem(context, 'When do professionals get paid?', 'Professionals are paid within 24 hours of successful QR attendance validation and shift completion.'),
        _buildFAQItem(context, 'How to change my plan?', 'Navigate to the Subscription tab to see available plans and upgrade your current subscription.'),
        
        const SizedBox(height: ShiftleyTokens.spaceXL),

        _buildCategoryHeader('ACCOUNT & PROFILE'),
        _buildFAQItem(context, 'How to change business address?', 'Navigate to Business Profile tab and click on the edit icon next to the operational address section.'),
        _buildFAQItem(context, 'Is my data secure?', 'Yes, Shiftley uses bank-grade encryption and secure authentication to protect all business and professional data.'),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.primaryRed, letterSpacing: 1.0)),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(question, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          iconColor: ShiftleyTokens.inkBlack,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(answer, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText)),
            ),
          ],
        ),
      ),
    );
  }
}
