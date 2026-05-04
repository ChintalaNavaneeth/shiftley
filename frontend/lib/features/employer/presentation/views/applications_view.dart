import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class ApplicationsView extends StatelessWidget {
  const ApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review and manage professional applications.', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        // Filter Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All Shifts', true),
              const SizedBox(width: ShiftleyTokens.spaceS),
              _buildFilterChip('Housekeeping (Tomorrow)', false),
              const SizedBox(width: ShiftleyTokens.spaceS),
              _buildFilterChip('Waiter (May 06)', false),
            ],
          ),
        ),

        const SizedBox(height: ShiftleyTokens.spaceL),

        // Application List
        Expanded(
          child: ListView.builder(
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildApplicationCard(
                name: ['Rahul Sharma', 'Sneha Reddy', 'Vikram Singh', 'Ananya Das'][index],
                rating: ['4.8', '4.9', '4.5', '4.7'][index],
                shift: 'Housekeeping Staff',
                note: 'I have 2 years of experience in luxury hospitality.',
                status: index == 0 ? 'SHORTLISTED' : 'APPLIED',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? ShiftleyTokens.inkBlack : ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? ShiftleyTokens.paperWhite : ShiftleyTokens.inkBlack,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildApplicationCard({
    required String name,
    required String rating,
    required String shift,
    required String note,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
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
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ShiftleyTokens.secondaryCyan,
                  border: ShiftleyTokens.primaryBorder,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: ShiftleyTokens.bodyLarge),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(rating, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('• 12 Gigs Done', style: ShiftleyTokens.caption),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusTag(status),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          const Text('APPLYING FOR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: ShiftleyTokens.mutedText)),
          Text(shift, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ShiftleyTokens.background,
              borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
            ),
            child: Text(
              '"$note"',
              style: ShiftleyTokens.bodyMedium.copyWith(fontStyle: FontStyle.italic, fontSize: 13),
            ),
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          Row(
            children: [
              Expanded(
                child: ShiftleyButton(
                  label: 'Reject',
                  onPressed: () {},
                  size: ShiftleyButtonSize.small,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: ShiftleyButton(
                  label: 'Shortlist',
                  onPressed: () {},
                  size: ShiftleyButtonSize.small,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: ShiftleyButton(
                  label: 'Approve',
                  onPressed: () {},
                  size: ShiftleyButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: status == 'SHORTLISTED' ? Colors.blue[50] : ShiftleyTokens.secondaryCyan,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: status == 'SHORTLISTED' ? Colors.blue[900] : Colors.green[900],
        ),
      ),
    );
  }
}
