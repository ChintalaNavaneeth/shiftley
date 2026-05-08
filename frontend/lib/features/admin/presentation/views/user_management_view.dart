import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import '../../domain/admin_models.dart';
import '../providers/admin_providers.dart';

class UserManagementView extends ConsumerWidget {
  const UserManagementView({super.key});

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'Verifier';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ShiftleyTokens.paperWhite,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 2),
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          title: const Text('Invite New Staff', style: ShiftleyTokens.h2),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField('Full Name', 'e.g. John Doe', nameController),
                  const SizedBox(height: ShiftleyTokens.spaceM),
                  _buildDialogField('Email Address', 'e.g. john@example.com', emailController),
                  const SizedBox(height: ShiftleyTokens.spaceM),
                  _buildDialogField('Phone Number', 'e.g. 9876543210', phoneController),
                  const SizedBox(height: ShiftleyTokens.spaceM),
                  _buildDialogDropdown(
                    'Assign Role',
                    ['Verifier', 'Business Admin', 'Customer Support', 'Insights'],
                    (v) => setState(() => selectedRole = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ShiftleyButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              isPrimary: false,
              size: ShiftleyButtonSize.small,
            ),
            const SizedBox(width: ShiftleyTokens.spaceS),
            ShiftleyButton(
              label: 'Send Invite',
              onPressed: () async {
                try {
                  await ref.read(managementUsersProvider.notifier).inviteStaff(
                        nameController.text,
                        emailController.text,
                        phoneController.text,
                        selectedRole.toUpperCase().replaceAll(' ', '_'),
                      );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              size: ShiftleyButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: ShiftleyTokens.background,
            border: ShiftleyTokens.primaryInputBorder,
            enabledBorder: ShiftleyTokens.primaryInputBorder,
            focusedBorder: ShiftleyTokens.focusInputBorder,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDropdown(String label, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: options[0],
          icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: ShiftleyTokens.inkBlack),
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: ShiftleyTokens.bodyMedium))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: ShiftleyTokens.background,
            border: ShiftleyTokens.primaryInputBorder,
            enabledBorder: ShiftleyTokens.primaryInputBorder,
            focusedBorder: ShiftleyTokens.focusInputBorder,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(managementUsersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Manage Users', style: ShiftleyTokens.h2),
            ShiftleyButton(
              onPressed: () => _showInviteDialog(context, ref),
              icon: Icons.add,
              label: 'Invite Staff',
              size: ShiftleyButtonSize.medium,
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Search by', style: ShiftleyTokens.caption),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Name / Phone Number...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: ShiftleyTokens.paperWhite,
                        border: ShiftleyTokens.primaryInputBorder,
                        enabledBorder: ShiftleyTokens.primaryInputBorder,
                        focusedBorder: ShiftleyTokens.focusInputBorder,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: ShiftleyTokens.spaceM),
            
            ShiftleyButton(
              onPressed: () => ref.invalidate(managementUsersProvider),
              icon: Icons.refresh,
              label: '',
              isPrimary: false,
              size: ShiftleyButtonSize.medium,
            ),
          ],
        ),
        
        const SizedBox(height: ShiftleyTokens.spaceL),

        Wrap(
          spacing: ShiftleyTokens.spaceM,
          runSpacing: ShiftleyTokens.spaceM,
          children: [
            _buildFilterDropdown('Role', ['All Roles', 'Super Admin', 'Business Admin', 'Verifier', 'Professional']),
            _buildFilterDropdown('Status', ['All Status', 'Active', 'Suspended', 'Pending']),
          ],
        ),

        const SizedBox(height: ShiftleyTokens.spaceXL),

        usersAsync.when(
          data: (users) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 850, 
              child: _buildUserTable(users, ref),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, List<String> options) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.caption),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: options[0],
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: ShiftleyTokens.bodyMedium))).toList(),
            onChanged: (v) {},
            decoration: InputDecoration(
              filled: true,
              fillColor: ShiftleyTokens.paperWhite,
              border: ShiftleyTokens.primaryInputBorder,
              enabledBorder: ShiftleyTokens.primaryInputBorder,
              focusedBorder: ShiftleyTokens.focusInputBorder,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(List<ManagementUser> users, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(),
          ...users.map((user) => _buildUserRow(user, ref)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: const BoxDecoration(
        color: ShiftleyTokens.secondaryCyan,
        border: Border(bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 1.0)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('NAME', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: ShiftleyTokens.mutedText))),
          Expanded(flex: 2, child: Text('ROLE', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: ShiftleyTokens.mutedText))),
          Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: ShiftleyTokens.mutedText))),
          Expanded(flex: 2, child: Text('PHONE', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: ShiftleyTokens.mutedText))),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildUserRow(ManagementUser user, WidgetRef ref) {
    final isSuspended = user.status == 'SUSPENDED';
    const double increasedFontSizeBody = 16.5; 
    const double increasedFontSizeMedium = 15.4; 

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: ShiftleyTokens.spaceL),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ShiftleyTokens.background, width: 1.0)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(user.fullName, style: ShiftleyTokens.bodyLarge.copyWith(fontSize: increasedFontSizeBody))),
          Expanded(flex: 2, child: Text(user.role, style: ShiftleyTokens.bodyMedium.copyWith(fontSize: increasedFontSizeMedium))),
          Expanded(
            flex: 2,
            child: Text(
              user.status,
              style: TextStyle(
                color: isSuspended ? ShiftleyTokens.primaryRed : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: increasedFontSizeMedium,
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(user.phoneNumber, style: ShiftleyTokens.bodyMedium.copyWith(fontSize: increasedFontSizeMedium))),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) async {
              if (value == 'suspend') {
                await ref.read(managementUsersProvider.notifier).updateStatus(user.id, 'SUSPENDED');
              } else if (value == 'activate') {
                await ref.read(managementUsersProvider.notifier).updateStatus(user.id, 'ACTIVE');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit User')),
              if (user.status != 'SUSPENDED')
                const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
              if (user.status == 'SUSPENDED')
                const PopupMenuItem(value: 'activate', child: Text('Activate')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: ShiftleyTokens.primaryRed))),
            ],
          ),
        ],
      ),
    );
  }
}
