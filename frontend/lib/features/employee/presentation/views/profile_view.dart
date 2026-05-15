import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shiftley_frontend/core/network/api_client.dart';
import 'package:shiftley_frontend/features/auth/presentation/providers/profile_provider.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  String _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    // ApiClient.baseUrl is 'http://.../api/v1/'
    final base = ApiClient.baseUrl.replaceAll('/api/v1/', '');
    return '$base$url';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (profile) => SingleChildScrollView(
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
                    image: profile['profile_photo_url'] != null
                        ? DecorationImage(
                            image: NetworkImage(_resolveUrl(profile['profile_photo_url'])),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profile['profile_photo_url'] == null
                      ? const Icon(Icons.person, size: 40, color: ShiftleyTokens.inkBlack)
                      : null,
                ),
                const SizedBox(width: ShiftleyTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile['full_name'] ?? 'Professional', style: ShiftleyTokens.h1),
                      Text('Professional Member', style: ShiftleyTokens.caption),
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
            _buildInfoRow('Phone', profile['phone_number'] ?? 'Not provided'),
            _buildInfoRow('Email', profile['email'] ?? 'Not provided'),
            _buildInfoRow('Location', profile['location'] ?? 'Hyderabad, India'),
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
            children: (profile['skills'] as List<dynamic>?)?.map((skill) => _buildSkillChip(skill.toString())).toList() ?? [
              Text('No skills listed', style: ShiftleyTokens.caption),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Certifications
          _buildSectionHeader(
            'Certifications',
            actionLabel: 'Add Certification',
            onActionTap: () => _showAddCertificationDialog(context),
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Center(
            child: Text(
              'No certifications added yet.',
              style: ShiftleyTokens.caption.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Bank Details
          _buildSectionHeader(
            'Bank & Payment Details',
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
                _buildPaymentInfoRow('Account Holder', profile['full_name'] ?? 'Not Linked'),
                _buildPaymentInfoRow('Bank Name', 'Verification Required'),
                _buildPaymentInfoRow('Account Number', '**** **** ****'),
                const SizedBox(height: ShiftleyTokens.spaceM),
                ShiftleyButton(
                  label: 'FETCH BANK DETAILS',
                  onPressed: () => _showRazorpayMock(context),
                  isFullWidth: true,
                ),
                const SizedBox(height: ShiftleyTokens.spaceS),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: ShiftleyTokens.primaryRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'We will perform a ₹1 penny-drop to verify your account.',
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
          _buildDocumentItem('KYC Verification', profile['kyc_status'] == true ? 'Completed' : 'Pending'),
          _buildDocumentItem('Profile Details', 'Verified'),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
        ],
      ),
    ),
  );
}

  void _showRazorpayMock(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RazorpayMockModal(
        onSuccess: (paymentId) {
          Navigator.pop(context);
          _showSuccessScreen(context);
        },
      ),
    );
  }

  void _showSuccessScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PaymentSuccessScreen(
          onDone: () => Navigator.pop(context),
        ),
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

class _RazorpayMockModal extends StatelessWidget {
  final Function(String) onSuccess;

  const _RazorpayMockModal({required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF02042B),
            child: Row(
              children: [
                const Icon(Icons.payment, color: Colors.blue, size: 32),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RAZORPAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'Bank Account Verification',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Penny-Drop Verification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We will deduct ₹1 to verify your bank account details. This amount will be automatically refunded within 24 hours.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Preferred Payment Methods',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildMethod(Icons.qr_code, 'UPI - Google Pay, PhonePe, etc.'),
                _buildMethod(
                  Icons.credit_card,
                  'Card - Visa, Mastercard, RuPay',
                ),
                _buildMethod(Icons.account_balance, 'Netbanking'),
                _buildMethod(Icons.wallet, 'Wallet'),
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    'TEST MODE',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ShiftleyButton(
              label: 'PAY ₹1 & VERIFY',
              onPressed: () => onSuccess(
                'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
              ),
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethod(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: () {},
    );
  }
}

class _PaymentSuccessScreen extends StatelessWidget {
  final VoidCallback onDone;

  const _PaymentSuccessScreen({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              const Text(
                'Verification Started!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'We have received your ₹1 payment. Your bank details are being verified and will be updated in your profile shortly. The verification amount will be refunded within 24 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              ShiftleyButton(
                label: 'BACK TO PROFILE',
                onPressed: onDone,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
