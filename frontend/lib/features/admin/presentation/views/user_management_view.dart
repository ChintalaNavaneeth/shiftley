import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import '../../domain/admin_models.dart';
import '../providers/admin_providers.dart';

class UserManagementView extends ConsumerStatefulWidget {
  const UserManagementView({super.key});

  @override
  ConsumerState<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends ConsumerState<UserManagementView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showInviteDialog(BuildContext context) {
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
                  _buildDialogField('Full Name', 'Full Name as in Aadhaar', nameController),
                  const SizedBox(height: ShiftleyTokens.spaceM),
                  _buildDialogField('Email Address', 'Email Address', emailController),
                  const SizedBox(height: ShiftleyTokens.spaceM),
                  _buildPhoneInput(phoneController),
                  const SizedBox(height: ShiftleyTokens.spaceM),
                  _buildDialogDropdown(
                    'Assign Role',
                    ['Verifier', 'Business Admin', 'HR Admin', 'Customer Support', 'Insights'],
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
                  const roleMap = {
                    'Verifier': 'VERIFIER',
                    'Business Admin': 'ADMIN',
                    'HR Admin': 'HR_ADMIN',
                    'Customer Support': 'CS_AGENT',
                    'Insights': 'ANALYST',
                  };

                  final phone = phoneController.text;
                  if (phone.length != 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
                    );
                    return;
                  }
                  
                  final fullPhone = '+91$phone';
                  
                  final message = await ref.read(managementUsersProvider.notifier).inviteStaff(
                        nameController.text,
                        emailController.text,
                        fullPhone,
                        roleMap[selectedRole] ?? 'VERIFIER',
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: ShiftleyTokens.inkBlack,
                      ),
                    );
                  }
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

  void _showEditDialog(BuildContext context, ManagementUser user) {
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    // Remove +91 prefix for the pinput
    String initialPhone = user.phoneNumber;
    if (initialPhone.startsWith('+91')) {
      initialPhone = initialPhone.substring(3);
    }
    final phoneController = TextEditingController(text: initialPhone);
    
    const reverseRoleMap = {
      'VERIFIER': 'Verifier',
      'ADMIN': 'Business Admin',
      'HR_ADMIN': 'HR Admin',
      'CS_AGENT': 'Customer Support',
      'ANALYST': 'Insights',
    };
    
    String selectedRole = reverseRoleMap[user.role] ?? 'Verifier';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ShiftleyTokens.paperWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 2),
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          title: Text('Edit ${user.fullName}', style: ShiftleyTokens.h2),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField('Full Name', 'Full Name', nameController),
                  const SizedBox(height: ShiftleyTokens.spaceM),
                  _buildDialogField('Email Address', 'Email Address', emailController),
                  const SizedBox(height: ShiftleyTokens.spaceM),
                  _buildPhoneInput(phoneController),
                  const SizedBox(height: ShiftleyTokens.spaceM),
                  _buildDialogDropdown(
                    'Assign Role',
                    ['Verifier', 'Business Admin', 'HR Admin', 'Customer Support', 'Insights'],
                    (v) => setState(() => selectedRole = v!),
                    initialValue: selectedRole,
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
              label: 'Save Changes',
              onPressed: () async {
                try {
                  const roleMap = {
                    'Verifier': 'VERIFIER',
                    'Business Admin': 'ADMIN',
                    'HR Admin': 'HR_ADMIN',
                    'Customer Support': 'CS_AGENT',
                    'Insights': 'ANALYST',
                  };

                  final phone = phoneController.text;
                  if (phone.length != 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
                    );
                    return;
                  }
                  
                  final fullPhone = '+91$phone';
                  
                  await ref.read(managementUsersProvider.notifier).editUser(
                        user.id,
                        fullName: nameController.text,
                        email: emailController.text,
                        phoneNumber: fullPhone,
                        role: roleMap[selectedRole],
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User updated successfully'), backgroundColor: ShiftleyTokens.inkBlack),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  void _showDeleteConfirmation(BuildContext context, ManagementUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShiftleyTokens.paperWhite,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 2),
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        title: const Text('Delete User', style: ShiftleyTokens.h2),
        content: Text('Are you sure you want to delete ${user.fullName}? This action cannot be undone.', style: ShiftleyTokens.bodyMedium),
        actions: [
          ShiftleyButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
            size: ShiftleyButtonSize.small,
          ),
          const SizedBox(width: ShiftleyTokens.spaceS),
          ShiftleyButton(
            label: 'Delete',
            onPressed: () async {
              try {
                await ref.read(managementUsersProvider.notifier).deleteUser(user.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted successfully'), backgroundColor: ShiftleyTokens.inkBlack),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            size: ShiftleyButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(TextEditingController controller) {
    final defaultPinTheme = PinTheme(
      width: 32,
      height: 40,
      textStyle: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 2)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mobile Number', style: ShiftleyTokens.caption),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 2)),
              ),
              child: Text('+91', style: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Pinput(
                length: 10,
                controller: controller,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: ShiftleyTokens.primaryRed, width: 2.5)),
                  ),
                ),
                keyboardType: TextInputType.phone,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceM),
      ],
    );
  }

  Widget _buildDialogField(String label, String hint, TextEditingController controller, {List<TextInputFormatter>? inputFormatters, int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            counterText: '', // Hide the counter for a cleaner look
            hintText: hint,
            filled: false,
            border: ShiftleyTokens.underlineInputBorder,
            enabledBorder: ShiftleyTokens.underlineInputBorder,
            focusedBorder: ShiftleyTokens.underlineFocusInputBorder,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDropdown(String label, List<String> options, ValueChanged<String?> onChanged, {String? initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: initialValue ?? options[0],
          icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: ShiftleyTokens.inkBlack),
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: ShiftleyTokens.bodyMedium))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: false,
            border: ShiftleyTokens.underlineInputBorder,
            enabledBorder: ShiftleyTokens.underlineInputBorder,
            focusedBorder: ShiftleyTokens.underlineFocusInputBorder,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, List<String> options) {
    final currentValue = label == 'Role'
        ? ref.watch(managementRoleFilterProvider)
        : ref.watch(managementStatusFilterProvider);

    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.caption),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: currentValue,
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: ShiftleyTokens.bodyMedium))).toList(),
            onChanged: (val) {
              if (val == null) return;
              if (label == 'Role') {
                ref.read(managementRoleFilterProvider.notifier).state = val;
              } else {
                ref.read(managementStatusFilterProvider.notifier).state = val;
              }
            },
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

  Widget _buildUserCard(ManagementUser user) {
    final isSuspended = user.status == 'SUSPENDED';

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  user.fullName,
                  style: ShiftleyTokens.h2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuspended ? ShiftleyTokens.secondaryCyan : ShiftleyTokens.inkBlack,
                  border: ShiftleyTokens.primaryBorder,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  user.status,
                  style: ShiftleyTokens.caption.copyWith(
                    color: isSuspended ? ShiftleyTokens.primaryRed : ShiftleyTokens.paperWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: ShiftleyTokens.spaceS),
              if (user.role != 'SUPER_ADMIN')
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 24, color: ShiftleyTokens.inkBlack),
                  onSelected: (value) async {
                    if (value == 'suspend') {
                      await ref.read(managementUsersProvider.notifier).updateStatus(user.id, 'SUSPENDED');
                    } else if (value == 'activate') {
                      await ref.read(managementUsersProvider.notifier).updateStatus(user.id, 'ACTIVE');
                    } else if (value == 'edit') {
                      _showEditDialog(context, user);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, user);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit User', style: ShiftleyTokens.bodyMedium)),
                    if (!isSuspended)
                      const PopupMenuItem(value: 'suspend', child: Text('Suspend', style: ShiftleyTokens.bodyMedium)),
                    if (isSuspended)
                      const PopupMenuItem(value: 'activate', child: Text('Activate', style: ShiftleyTokens.bodyMedium)),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold, fontFamily: 'Figtree')),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceS),
          const Divider(color: ShiftleyTokens.inkBlack, thickness: 1.5),
          const SizedBox(height: ShiftleyTokens.spaceS),
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 16, color: ShiftleyTokens.mutedText),
              const SizedBox(width: ShiftleyTokens.spaceS),
              Text(user.role, style: ShiftleyTokens.bodyMedium),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXS),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: ShiftleyTokens.mutedText),
              const SizedBox(width: ShiftleyTokens.spaceS),
              Text(user.phoneNumber, style: ShiftleyTokens.bodyMedium),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXS),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 16, color: ShiftleyTokens.mutedText),
              const SizedBox(width: ShiftleyTokens.spaceS),
              Text(user.email, style: ShiftleyTokens.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(managementUsersProvider);

    // Sync text controller when provider changes externally (e.g. from refresh)
    ref.listen(managementSearchQueryProvider, (prev, next) {
      if (next.isEmpty && _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    });

    // React to filter/search changes and re-fetch
    ref.listen(managementSearchQueryProvider, (_, next) {
      ref.read(managementUsersProvider.notifier).fetchWithFilters(
        query: next,
        role: ref.read(managementRoleFilterProvider),
        status: ref.read(managementStatusFilterProvider),
      );
    });
    ref.listen(managementRoleFilterProvider, (_, next) {
      ref.read(managementUsersProvider.notifier).fetchWithFilters(
        query: ref.read(managementSearchQueryProvider),
        role: next,
        status: ref.read(managementStatusFilterProvider),
      );
    });
    ref.listen(managementStatusFilterProvider, (_, next) {
      ref.read(managementUsersProvider.notifier).fetchWithFilters(
        query: ref.read(managementSearchQueryProvider),
        role: ref.read(managementRoleFilterProvider),
        status: next,
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ───────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Manage Users', style: ShiftleyTokens.h2),
            ShiftleyButton(
              onPressed: () => _showInviteDialog(context),
              icon: Icons.add,
              label: 'Invite Staff',
              size: ShiftleyButtonSize.medium,
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        // ── Search ────────────────────────────────────────────────────
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
                    controller: _searchController,
                    onChanged: (val) =>
                        ref.read(managementSearchQueryProvider.notifier).state = val,
                    decoration: InputDecoration(
                      hintText: 'Name / Phone Number...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: false,
                      border: ShiftleyTokens.underlineInputBorder,
                      enabledBorder: ShiftleyTokens.underlineInputBorder,
                      focusedBorder: ShiftleyTokens.underlineFocusInputBorder,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

        const SizedBox(height: ShiftleyTokens.spaceL),

        // ── Filters ───────────────────────────────────────────────────
        Wrap(
          spacing: ShiftleyTokens.spaceM,
          runSpacing: ShiftleyTokens.spaceM,
          children: [
            _buildFilterDropdown('Role', ['All Roles', 'Super Admin', 'Business Admin', 'Verifier', 'CS Agent', 'Analyst']),
            _buildFilterDropdown('Status', ['All Status', 'Active', 'Suspended']),
          ],
        ),

        const SizedBox(height: ShiftleyTokens.spaceXL),

        // ── User List ─────────────────────────────────────────────────
        usersAsync.when(
          data: (users) => users.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Text('No users found', style: ShiftleyTokens.caption),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: users.map(_buildUserCard).toList(),
                ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ],
    );
  }
}
