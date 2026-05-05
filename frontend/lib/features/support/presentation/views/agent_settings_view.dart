import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class AgentSettingsView extends StatefulWidget {
  const AgentSettingsView({super.key});

  @override
  State<AgentSettingsView> createState() => _AgentSettingsViewState();
}

class _AgentSettingsViewState extends State<AgentSettingsView> {
  bool _isOnline = true;
  bool _autoAssign = true;
  bool _desktopNotifications = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Agent Availability'),
          _buildToggleItem(
            'Go Online',
            'Start receiving new support tickets',
            _isOnline,
            (v) => setState(() => _isOnline = v),
          ),
          _buildToggleItem(
            'Auto-Assign Tickets',
            'Automatically pick up new tickets from queue',
            _autoAssign,
            (v) => setState(() => _autoAssign = v),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildSectionHeader('Alerts & Notifications'),
          _buildToggleItem(
            'System Desktop Alerts',
            'Browser notifications for new messages',
            _desktopNotifications,
            (v) => setState(() => _desktopNotifications = v),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

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
        const Divider(color: ShiftleyTokens.inkBlack, thickness: 1.5),
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
            activeThumbColor: ShiftleyTokens.secondaryCyan,
            activeTrackColor: ShiftleyTokens.inkBlack,
          ),
        ],
      ),
    );
  }

}
