import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShiftleyTokens.paperWhite,
        elevation: 0, // Removed shadow
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Allows wider dialog
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 2),
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        title: const Text('Invite New Staff', style: ShiftleyTokens.h2),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7, // Increased width by ~20% (relative to previous)
          child: SingleChildScrollView( // Prevents keyboard overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField('Full Name', 'e.g. John Doe'),
                const SizedBox(height: ShiftleyTokens.spaceM),
                _buildDialogField('Email Address', 'e.g. john@example.com'),
                const SizedBox(height: ShiftleyTokens.spaceM),
                _buildDialogField('Phone Number', 'e.g. 9876543210'),
                const SizedBox(height: ShiftleyTokens.spaceM),
                _buildDialogDropdown('Assign Role', ['Verifier', 'Business Admin', 'Customer Support', 'Insights']),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: ShiftleyTokens.mutedText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ShiftleyTokens.inkBlack,
              foregroundColor: ShiftleyTokens.paperWhite,
              elevation: 0, // Removed shadow
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: ShiftleyTokens.background,
            border: ShiftleyTokens.primaryInputBorder,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDropdown(String label, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: ShiftleyTokens.inkBlack),
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: ShiftleyTokens.bodyMedium))).toList(),
          onChanged: (v) {},
          decoration: InputDecoration(
            filled: true,
            fillColor: ShiftleyTokens.background,
            border: ShiftleyTokens.primaryInputBorder,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header & Invite ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Manage Users', style: ShiftleyTokens.h2),
            ElevatedButton.icon(
              onPressed: () => _showInviteDialog(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Invite Staff'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ShiftleyTokens.inkBlack,
                foregroundColor: ShiftleyTokens.paperWhite,
                padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceL, vertical: ShiftleyTokens.spaceM),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: ShiftleyTokens.inkBlack),
                  borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                ),
                elevation: 0, // Removed shadow as requested
              ),
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        // ── Search & Reset (Row 1) ──────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Search', style: ShiftleyTokens.caption),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Name / Phone Number...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: ShiftleyTokens.paperWhite,
                        border: ShiftleyTokens.primaryInputBorder,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: ShiftleyTokens.spaceM),
            
            // Reset Filter Button
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_off, size: 18, color: ShiftleyTokens.primaryRed),
                label: const Text('Reset', style: TextStyle(color: ShiftleyTokens.primaryRed)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ShiftleyTokens.primaryRed, width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: ShiftleyTokens.spaceL),

        // ── Filters (Row 2) ──────────────────────────────────────────
        Wrap(
          spacing: ShiftleyTokens.spaceM,
          runSpacing: ShiftleyTokens.spaceM,
          children: [
            _buildFilterDropdown('Role', ['All Roles', 'Super Admin', 'Business Admin', 'Verifier', 'Professional']),
            _buildFilterDropdown('Status', ['All Status', 'Active', 'Suspended', 'Pending']),
          ],
        ),

        const SizedBox(height: ShiftleyTokens.spaceXL),

        // ── Table Wrapper ────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 850, 
            child: _buildUserTable(),
          ),
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
            value: options[0],
            items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: ShiftleyTokens.bodyMedium))).toList(),
            onChanged: (v) {},
            decoration: InputDecoration(
              filled: true,
              fillColor: ShiftleyTokens.paperWhite,
              border: ShiftleyTokens.primaryInputBorder,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable() {
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
          _buildUserRow('Navaneeth Chintala', 'Super Admin', 'Active', '9876543210'),
          _buildUserRow('Rahul Sharma', 'Professional', 'Active', '8877665544'),
          _buildUserRow('Megha Rao', 'Business Admin', 'Suspended', '7766554433'),
          _buildUserRow('Amit Singh', 'Verifier', 'Active', '6655443322'),
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
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('NAME', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: ShiftleyTokens.mutedText))),
          Expanded(flex: 2, child: Text('ROLE', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: ShiftleyTokens.mutedText))),
          Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: ShiftleyTokens.mutedText))),
          Expanded(flex: 2, child: Text('PHONE', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: ShiftleyTokens.mutedText))),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildUserRow(String name, String role, String status, String phone) {
    final isSuspended = status == 'Suspended';
    const double increasedFontSizeBody = 16.5; // ~10% increase from 15
    const double increasedFontSizeMedium = 15.4; // ~10% increase from 14

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: ShiftleyTokens.spaceL),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ShiftleyTokens.background, width: 1.0)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: ShiftleyTokens.bodyLarge.copyWith(fontSize: increasedFontSizeBody))),
          Expanded(flex: 2, child: Text(role, style: ShiftleyTokens.bodyMedium.copyWith(fontSize: increasedFontSizeMedium))),
          Expanded(
            flex: 2,
            child: Text(
              status,
              style: TextStyle(
                color: isSuspended ? ShiftleyTokens.primaryRed : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: increasedFontSizeMedium,
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(phone, style: ShiftleyTokens.bodyMedium.copyWith(fontSize: increasedFontSizeMedium))),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) {
              // Handle Edit/Action
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit User')),
              const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: ShiftleyTokens.primaryRed))),
            ],
          ),
        ],
      ),
    );
  }
}
