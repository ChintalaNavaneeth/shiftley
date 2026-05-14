import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/features/employer/data/employer_repository.dart';
import 'package:shiftley_frontend/features/employer/domain/models/employer_models.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(employerDashboardProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed)),
      error: (err, stack) => Center(child: Text('Error loading profile: $err')),
      data: (data) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage your business profile and account details.', style: ShiftleyTokens.bodyMedium),
            const SizedBox(height: ShiftleyTokens.spaceXL),

            _buildProfileHeader(data.profile),
            const SizedBox(height: ShiftleyTokens.spaceXL),

            _buildDetailSection('Business Information', [
              _buildDetailItem('Legal Business Name', data.profile.businessName),
              _buildDetailItem('Business Type', data.profile.businessType),
              _buildDetailItem('GST Number', data.profile.gstNumber ?? 'N/A'),
              _buildDetailItem('Aadhaar Number', '********${data.profile.aadhaarLast4 ?? "----"}'),
            ]),
            
            const SizedBox(height: ShiftleyTokens.spaceXL),

            _buildDetailSection('Contact Information', [
              _buildDetailItem('Email', data.profile.email),
              _buildDetailItem('Phone', data.profile.phoneNumber),
              _buildDetailItem('Verification Status', data.profile.verificationStatus),
            ]),

            const SizedBox(height: ShiftleyTokens.spaceXL),

            _buildDetailSection('Operational Address', [
              _buildDetailItem('Full Address', data.profile.businessAddress),
              _buildDetailItem('Latitude', data.profile.lat.toStringAsFixed(6)),
              _buildDetailItem('Longitude', data.profile.lng.toStringAsFixed(6)),
            ]),

            const SizedBox(height: ShiftleyTokens.spaceXL),

            _buildDetailSection('Uploaded Documents', [
              if (data.profile.aadhaarUrl != null)
                _buildDocumentItem('Aadhaar Document', 'aadhaar_proof.pdf'),
              ...data.profile.photoUrls.asMap().entries.map((entry) {
                return _buildDocumentItem('Business Photo ${entry.key + 1}', 'photo_${entry.key + 1}.jpg');
              }),
            ]),

            const SizedBox(height: ShiftleyTokens.spaceXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(EmployerProfile profile) {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ShiftleyTokens.secondaryCyan,
              border: ShiftleyTokens.primaryBorder,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.business, size: 40, color: ShiftleyTokens.inkBlack),
          ),
          const SizedBox(width: ShiftleyTokens.spaceL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.businessName, style: ShiftleyTokens.h1, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(
                  profile.verificationStatus == 'VERIFIED' ? 'Verified Employer' : 'Verification Pending', 
                  style: ShiftleyTokens.caption.copyWith(
                    color: profile.verificationStatus == 'VERIFIED' ? Colors.green : Colors.orange, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ShiftleyTokens.h2.copyWith(color: ShiftleyTokens.primaryRed)),
        const SizedBox(height: ShiftleyTokens.spaceM),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: ShiftleyTokens.paperWhite,
            border: ShiftleyTokens.primaryBorder,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value, style: ShiftleyTokens.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String label, String fileName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 20, color: ShiftleyTokens.mutedText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(fileName, style: ShiftleyTokens.caption),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
