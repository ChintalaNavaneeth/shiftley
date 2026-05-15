import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/shared/widgets/s_text_field.dart';
import 'package:shiftley_frontend/core/network/api_client.dart';
import 'package:shiftley_frontend/features/auth/presentation/providers/profile_provider.dart';
import 'package:shiftley_frontend/features/auth/data/auth_repository_provider.dart';
import 'package:shiftley_frontend/shared/widgets/s_refreshable.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  String _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    final base = ApiClient.baseUrl.replaceAll('/api/v1/', '');
    return '$base$url';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (profile) => SRefreshable(
        onRefresh: () => ref.refresh(userProfileProvider.future),
        child: Padding(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
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
                onAdd: () => _showAddSkillDialog(context, ref),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (profile['skills'] as List<dynamic>?)?.map((skill) {
                  final skillMap = skill as Map<String, dynamic>;
                  return _buildSkillChip(
                    skillMap['name'].toString(),
                    onDelete: () => _deleteSkill(context, ref, skillMap['id'].toString()),
                  );
                }).toList() ?? [
                  Text('No skills listed', style: ShiftleyTokens.caption),
                ],
              ),
              const SizedBox(height: ShiftleyTokens.spaceXL),

              // Certifications
              _buildSectionHeader(
                'Certifications',
                onAdd: () => _showAddCertificationDialog(context, ref),
              ),
              const SizedBox(height: ShiftleyTokens.spaceM),
              if ((profile['certifications'] as List<dynamic>?)?.isEmpty ?? true)
                Center(
                  child: Text(
                    'No certifications added yet.',
                    style: ShiftleyTokens.caption.copyWith(fontStyle: FontStyle.italic),
                  ),
                )
              else
                ...(profile['certifications'] as List<dynamic>).map((cert) {
                  final certMap = cert as Map<String, dynamic>;
                  return _buildCertificationItem(
                    certMap['name'].toString(),
                    '${certMap['issuing_authority']} • ${certMap['year']}',
                    onDelete: () => _deleteCertification(context, ref, certMap['id'].toString()),
                  );
                }),
              const SizedBox(height: ShiftleyTokens.spaceXL),

              // Bank Details
              _buildSectionHeader('Bank & Payment Details'),
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
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: ShiftleyTokens.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add New Skill', style: ShiftleyTokens.h2),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: ShiftleyTokens.spaceM),
            Expanded(
              child: ref.watch(taxonomyProvider).when(
                data: (categories) {
                  final allSkills = categories.expand((c) => c.skills).toList();
                  return ListView.builder(
                    itemCount: allSkills.length,
                    itemBuilder: (context, index) {
                      final skill = allSkills[index];
                      return ListTile(
                        title: Text(skill.name, style: ShiftleyTokens.bodyMedium),
                        trailing: const Icon(Icons.add, color: ShiftleyTokens.primaryRed),
                        onTap: () async {
                          try {
                            await ref.read(authRepositoryProvider).addSkill(skill.id);
                            ref.invalidate(userProfileProvider);
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add skill: $e')));
                            }
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading skills: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCertificationDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final authorityController = TextEditingController();
    final yearController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: ShiftleyTokens.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Certification', style: ShiftleyTokens.h2),
              const SizedBox(height: ShiftleyTokens.spaceM),
              STextField(hint: 'Certification Name', controller: nameController),
              const SizedBox(height: ShiftleyTokens.spaceM),
              STextField(hint: 'Issuing Authority', controller: authorityController),
              const SizedBox(height: ShiftleyTokens.spaceM),
              STextField(hint: 'Year', controller: yearController, keyboardType: TextInputType.number),
              const SizedBox(height: ShiftleyTokens.spaceL),
              ShiftleyButton(
                label: 'Save Certification',
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  try {
                    await ref.read(authRepositoryProvider).addCertification({
                      'name': nameController.text,
                      'issuing_authority': authorityController.text,
                      'year': yearController.text,
                    });
                    ref.invalidate(userProfileProvider);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add certification: $e')));
                    }
                  }
                },
                isFullWidth: true,
              ),
            ],
          ),
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

  Widget _buildSectionHeader(String title, {VoidCallback? onAdd}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: ShiftleyTokens.h2),
            if (onAdd != null)
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: ShiftleyTokens.secondaryCyan,
                    border: ShiftleyTokens.thinBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'ADD',
                        style: TextStyle(fontWeight: FontWeight.bold, color: ShiftleyTokens.inkBlack, fontSize: 10),
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

  Widget _buildSkillChip(String label, {VoidCallback? onDelete}) {
    return Chip(
      label: Text(label, style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.inkBlack)),
      backgroundColor: ShiftleyTokens.paperWhite,
      side: const BorderSide(color: ShiftleyTokens.inkBlack),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      deleteIcon: onDelete != null ? const Icon(Icons.close, size: 14, color: ShiftleyTokens.inkBlack) : null,
      onDeleted: onDelete,
    );
  }

  Widget _buildCertificationItem(String title, String subtitle, {VoidCallback? onDelete}) {
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
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: ShiftleyTokens.mutedText),
              onPressed: onDelete,
            ),
        ],
      ),
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

  void _deleteSkill(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(authRepositoryProvider).deleteSkill(id);
      ref.invalidate(userProfileProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill removed successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove skill: $e')),
        );
      }
    }
  }

  void _deleteCertification(BuildContext context, WidgetRef ref, String id) async {
    try {
      await ref.read(authRepositoryProvider).deleteCertification(id);
      ref.invalidate(userProfileProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Certification removed successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove certification: $e')),
        );
      }
    }
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
