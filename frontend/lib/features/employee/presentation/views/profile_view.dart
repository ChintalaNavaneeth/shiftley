import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:file_picker/file_picker.dart';


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
          _buildSectionHeader(
            'Skills & Specialties',
            actionLabel: 'Add Skill',
            onActionTap: () => _showAddSkillDialog(context),
          ),
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

          // Certifications
          _buildSectionHeader(
            'Certifications',
            actionLabel: 'Add Certification',
            onActionTap: () => _showAddCertificationDialog(context),
          ),
          _buildCertificationItem('Food Safety Level 1', 'FSSAI Certified • 2023'),
          _buildCertificationItem('Professional Driving', 'Regional Transport Office • 2022'),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Bank Details
          _buildSectionHeader(
            'Bank & Payment Details',
            actionLabel: 'Edit Details',
            onActionTap: () => _showEditBankDetailsDialog(context),
          ),
          Container(
            padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
            decoration: BoxDecoration(
              color: ShiftleyTokens.secondaryCyan.withValues(alpha: 0.1),
              border: ShiftleyTokens.primaryBorder,
              borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
            ),
            child: Column(
              children: [
                _buildPaymentInfoRow('Account Holder', 'Rahul Kumar'),
                _buildPaymentInfoRow('Bank Name', 'HDFC Bank'),
                _buildPaymentInfoRow('Account Number', '**** **** 5678'),
                _buildPaymentInfoRow('IFSC Code', 'HDFC0001234'),
                const Divider(color: ShiftleyTokens.inkBlack, thickness: 1),
                _buildPaymentInfoRow('UPI ID', 'rahulkumar@okaxis'),
                const SizedBox(height: ShiftleyTokens.spaceS),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: ShiftleyTokens.primaryRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All shift payouts will be automatically deposited into this account upon completion.',
                        style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Documents
          _buildSectionHeader('Verified Documents'),
          _buildDocumentItem('Aadhaar Card', 'Verified on Jan 12, 2024'),
          _buildDocumentItem('Driving License', 'Verified on Jan 15, 2024'),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
        ],
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMockFormSheet(
        context,
        title: 'Add New Skill',
        fields: [
          _buildMockTextField('Skill Name (e.g. Electrician)'),
          _buildMockTextField('Experience Level (e.g. 2 Years)'),
        ],
      ),
    );
  }

  void _showAddCertificationDialog(BuildContext context) {
    String? selectedFileName;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _buildMockFormSheet(
          context,
          title: 'Add Certification',
          fields: [
            _buildMockTextField('Certification Name'),
            _buildMockTextField('Issuing Authority'),
            _buildMockTextField('Year of Issue'),
            const SizedBox(height: ShiftleyTokens.spaceM),
            Text('DOCUMENT PROOF (PDF/PHOTO)', style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                FilePickerResult? result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
                );

                if (result != null) {
                  setModalState(() {
                    selectedFileName = result.files.single.name;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
                decoration: BoxDecoration(
                  color: ShiftleyTokens.paperWhite,
                  border: ShiftleyTokens.primaryBorder,
                  borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selectedFileName == null ? Icons.upload_file : Icons.check_circle,
                      color: selectedFileName == null ? ShiftleyTokens.mutedText : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFileName ?? 'Tap to upload PDF or Photo',
                        style: ShiftleyTokens.bodyMedium.copyWith(
                          color: selectedFileName == null ? ShiftleyTokens.mutedText : ShiftleyTokens.inkBlack,
                          fontWeight: selectedFileName == null ? FontWeight.normal : FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBankDetailsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMockFormSheet(
        context,
        title: 'Edit Payment Info',
        fields: [
          _buildMockTextField('Account Holder Name'),
          _buildMockTextField('Bank Name'),
          _buildMockTextField('Account Number'),
          _buildMockTextField('IFSC Code'),
          _buildMockTextField('UPI ID'),
        ],
      ),
    );
  }

  Widget _buildMockFormSheet(BuildContext context, {required String title, required List<Widget> fields}) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: ShiftleyTokens.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: ShiftleyTokens.primaryBorderSide),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ShiftleyTokens.h1),
              const SizedBox(height: ShiftleyTokens.spaceL),
              ...fields.expand((f) => [f, const SizedBox(height: ShiftleyTokens.spaceM)]),
              const SizedBox(height: ShiftleyTokens.spaceL),
              ShiftleyButton(
                label: 'Save Changes',
                onPressed: () => Navigator.pop(context),
                isFullWidth: true,
              ),
              const SizedBox(height: ShiftleyTokens.spaceM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMockTextField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: ShiftleyTokens.paperWhite,
            enabledBorder: ShiftleyTokens.primaryInputBorder,
            focusedBorder: ShiftleyTokens.focusInputBorder,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: ShiftleyTokens.caption),
          Text(value, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionLabel, VoidCallback? onActionTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: ShiftleyTokens.h2),
            if (actionLabel != null)
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: ShiftleyTokens.secondaryCyan,
                    border: ShiftleyTokens.thinBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        actionLabel.toUpperCase(),
                        style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold, color: ShiftleyTokens.inkBlack),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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

  Widget _buildCertificationItem(String title, String subtitle) {
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
          const Icon(Icons.workspace_premium_outlined, color: ShiftleyTokens.primaryRed),
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
          const Icon(Icons.edit_outlined, size: 16, color: ShiftleyTokens.mutedText),
        ],
      ),
    );
  }
}
