import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _newApplicantAlerts = true;
  bool _attendanceAlerts = true;
  bool _whatsappUpdates = true;
  bool _autoApproveVerified = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Operational Alerts'),
          _buildToggleItem(
            'New Applicants',
            'Get notified as soon as a professional applies',
            _newApplicantAlerts,
            (v) => setState(() => _newApplicantAlerts = v),
          ),
          _buildToggleItem(
            'Attendance & Clock-ins',
            'Receive alerts when professionals check-in/out',
            _attendanceAlerts,
            (v) => setState(() => _attendanceAlerts = v),
          ),
          _buildToggleItem(
            'WhatsApp Updates',
            'Get shift status and emergency alerts on WhatsApp',
            _whatsappUpdates,
            (v) => setState(() => _whatsappUpdates = v),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildSectionHeader('Recruitment Preferences'),
          _buildToggleItem(
            'Auto-Approve Verified',
            'Automatically hire top-rated verified professionals',
            _autoApproveVerified,
            (v) => setState(() => _autoApproveVerified = v),
          ),
          _buildActionItem(
            'Manage Hiring Roles',
            'Configure default requirements for your shifts',
            Icons.people_outline,
            () {},
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildSectionHeader('Business Account'),
          _buildActionItem(
            'Billing & Subscription',
            'Manage your Monthly Pro plan and invoices',
            Icons.credit_card_outlined,
            () {},
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

  Widget _buildToggleItem(String title, String subtitle, bool value, Function(bool) onChanged) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: ShiftleyTokens.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ShiftleyTokens.secondaryCyan,
            activeTrackColor: ShiftleyTokens.inkBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        decoration: BoxDecoration(
          color: ShiftleyTokens.paperWhite,
          border: ShiftleyTokens.primaryBorder,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDanger ? Colors.red.withValues(alpha: 0.1) : ShiftleyTokens.secondaryCyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: isDanger ? Colors.red : ShiftleyTokens.inkBlack),
            ),
            const SizedBox(width: ShiftleyTokens.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ShiftleyTokens.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDanger ? Colors.red : ShiftleyTokens.inkBlack,
                    ),
                  ),
                  Text(subtitle, style: ShiftleyTokens.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: ShiftleyTokens.mutedText),
          ],
        ),
      ),
    );
  }

}
