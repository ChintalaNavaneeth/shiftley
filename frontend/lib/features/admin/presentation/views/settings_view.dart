import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _securityAlerts = true;
  bool _maintenanceMode = false;
  bool _debugLogging = true;
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Admin Preferences'),
        _buildToggleItem(
          'Critical Security Alerts',
          'Notify immediately on suspicious login attempts',
          _securityAlerts,
          (v) => setState(() => _securityAlerts = v),
        ),
        _buildToggleItem(
          'Automatic Backups',
          'Sync system state to secure cloud storage daily',
          _autoBackup,
          (v) => setState(() => _autoBackup = v),
        ),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        _buildSectionHeader('Global System Controls'),
        _buildToggleItem(
          'Maintenance Mode',
          'Disable public access for scheduled updates',
          _maintenanceMode,
          (v) => setState(() => _maintenanceMode = v),
          isWarning: true,
        ),
        _buildToggleItem(
          'Verbose Debug Logging',
          'Enable detailed traces for system diagnostics',
          _debugLogging,
          (v) => setState(() => _debugLogging = v),
        ),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        _buildSectionHeader('Account & Security'),
        _buildActionItem(
          'Two-Factor Authentication',
          'Add an extra layer of security to your admin account',
          Icons.verified_outlined,
          () {},
        ),
        _buildActionItem(
          'Export System Audit Logs',
          'Download all administrative actions for this period',
          Icons.history_edu_outlined,
          () {},
        ),
        const SizedBox(height: ShiftleyTokens.spaceXXL),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ShiftleyTokens.h2),
        const SizedBox(height: ShiftleyTokens.spaceS),
        const Divider(color: ShiftleyTokens.inkBlack, thickness: 1.5),
        const SizedBox(height: ShiftleyTokens.spaceM),
      ],
    );
  }

  Widget _buildToggleItem(String title, String subtitle, bool value, Function(bool) onChanged, {bool isWarning = false}) {
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
                Text(
                  title,
                  style: ShiftleyTokens.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isWarning && value ? ShiftleyTokens.primaryRed : ShiftleyTokens.inkBlack,
                  ),
                ),
                Text(subtitle, style: ShiftleyTokens.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isWarning ? ShiftleyTokens.primaryRed : ShiftleyTokens.secondaryCyan,
            activeTrackColor: ShiftleyTokens.inkBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
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
                color: ShiftleyTokens.secondaryCyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: ShiftleyTokens.inkBlack),
            ),
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
            const Icon(Icons.chevron_right, color: ShiftleyTokens.mutedText),
          ],
        ),
      ),
    );
  }
}
