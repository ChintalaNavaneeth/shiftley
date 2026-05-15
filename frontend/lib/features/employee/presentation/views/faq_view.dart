import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_refreshable.dart';

class FAQView extends StatelessWidget {
  const FAQView({super.key});

  @override
  Widget build(BuildContext context) {
    return SRefreshable(
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Find quick answers to common questions for professionals.', style: ShiftleyTokens.bodyMedium),
            const SizedBox(height: ShiftleyTokens.spaceXL),

            _buildCategoryHeader('EARNINGS & PAYOUTS'),
            _buildFAQItem(context, 'When will I receive my payment?', 'Payments are processed within 24 hours of shift completion and QR code validation by the employer.'),
            _buildFAQItem(context, 'Is there a minimum payout amount?', 'No, you get paid for every shift you complete, regardless of the amount.'),
            
            const SizedBox(height: ShiftleyTokens.spaceXL),

            _buildCategoryHeader('SHIFTS & ATTENDANCE'),
            _buildFAQItem(context, 'How do I check-in for a shift?', 'Go to the "My Shifts" tab, select the active shift, and show your QR code to the employer for scanning.'),
            _buildFAQItem(context, 'What happens if I cancel a shift?', 'Cancellations within 6 hours of the shift start may result in a reliability score penalty.'),
            
            const SizedBox(height: ShiftleyTokens.spaceXL),

            _buildCategoryHeader('PROFILE & RELIABILITY'),
            _buildFAQItem(context, 'How to improve my reliability score?', 'Complete shifts on time, avoid late cancellations, and maintain professional behavior on-site.'),
            _buildFAQItem(context, 'How to update my skills?', 'You can update your skills and professional details in the "My Profile" tab.'),

            const SizedBox(height: 100),
          ],
        ),
      ),
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
