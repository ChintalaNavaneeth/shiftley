import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class FAQView extends StatelessWidget {
  const FAQView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Find quick answers to common questions for field verifiers.', style: ShiftleyTokens.bodyMedium),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildCategoryHeader('VERIFICATION PROCESS'),
          _buildFAQItem(context, 'What if GPS sync fails?', 'Ensure your device location is ON and you are within 100 meters of the target business location. Try moving to an open area.'),
          _buildFAQItem(context, 'What photos are mandatory?', 'Selfie with the contact person, business signage, and internal operational area are mandatory for every audit.'),
          
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildCategoryHeader('AUDIT GUIDELINES'),
          _buildFAQItem(context, 'How to handle uncooperative employers?', 'Do not argue. Note down the observation in the rejection reason and mark the audit as "Employer Non-Cooperative".'),
          _buildFAQItem(context, 'What documents to check?', 'Verify the physical copy of the GST certificate and FSSAI license against the data shown in your queue.'),
          
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildCategoryHeader('TECHNICAL SUPPORT'),
          _buildFAQItem(context, 'App crashing during photo upload?', 'Check your internet connection. If the issue persists, clear app cache or raise a high-priority support ticket.'),
          _buildFAQItem(context, 'Can I verify offline?', 'No, GPS sync and data submission require an active internet connection to prevent fraud.'),

          const SizedBox(height: 100),
        ],
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
