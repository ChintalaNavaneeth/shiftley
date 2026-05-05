import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ShiftleyTokens.secondaryCyan,
                  border: ShiftleyTokens.primaryBorder,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 40, color: ShiftleyTokens.inkBlack),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rahul Kumar', style: ShiftleyTokens.h1),
                    Text('Professional Member since 2024', style: ShiftleyTokens.caption),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.green, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text('KYC VERIFIED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Basic Info
          _buildSectionHeader('Basic Information'),
          _buildInfoRow('Phone', '+91 98765 43210'),
          _buildInfoRow('Email', 'rahul.k@example.com'),
          _buildInfoRow('Location', 'Jubilee Hills, Hyderabad'),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Skills
          _buildSectionHeader('Skills & Specialties'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSkillChip('Housekeeping'),
              _buildSkillChip('Cooking (North Indian)'),
              _buildSkillChip('Driving (LMW)'),
              _buildSkillChip('Waiter Service'),
              _buildSkillChip('Cleaning'),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Documents
          _buildSectionHeader('Verified Documents'),
          _buildDocumentItem('Aadhaar Card', 'Verified on Jan 12, 2024'),
          _buildDocumentItem('Driving License', 'Verified on Jan 15, 2024'),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          ShiftleyButton(
            label: 'Edit Profile',
            onPressed: () {},
            isFullWidth: true,
            isPrimary: false,
          ),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ShiftleyTokens.h2),
        const SizedBox(height: ShiftleyTokens.spaceS),
        const Divider(color: ShiftleyTokens.inkBlack, thickness: 1),
        const SizedBox(height: ShiftleyTokens.spaceM),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText)),
          Text(value, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDocumentItem(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: ShiftleyTokens.mutedText),
          const SizedBox(width: ShiftleyTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: ShiftleyTokens.caption),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}
