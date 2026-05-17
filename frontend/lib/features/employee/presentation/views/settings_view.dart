import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_refreshable.dart';
import 'package:shiftley_frontend/features/employee/data/employee_repository.dart';
import 'package:geolocator/geolocator.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _whatsappAlerts = true;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationProvider);

    return SRefreshable(
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Device Location'),
            _buildLocationItem(locationAsync),
            const SizedBox(height: ShiftleyTokens.spaceXXL),

            _buildSectionHeader('Notifications'),
            _buildToggleItem(
              'Push Notifications',
              'Receive real-time alerts for gig approvals',
              _pushNotifications,
              (v) => setState(() => _pushNotifications = v),
            ),
            _buildToggleItem(
              'Email Alerts',
              'Get shift summaries and payment receipts',
              _emailAlerts,
              (v) => setState(() => _emailAlerts = v),
            ),
            _buildToggleItem(
              'WhatsApp Alerts',
              'Receive urgent shift updates and gig links on WhatsApp',
              _whatsappAlerts,
              (v) => setState(() => _whatsappAlerts = v),
            ),

            const SizedBox(height: ShiftleyTokens.spaceXXL),
          ],
        ),
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
            activeThumbColor: ShiftleyTokens.secondaryCyan,
            activeTrackColor: ShiftleyTokens.inkBlack,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationItem(AsyncValue<Position?> locationAsync) {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 24, color: ShiftleyTokens.inkBlack),
          const SizedBox(width: ShiftleyTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('GPS Location Status', style: TextStyle(fontWeight: FontWeight.bold)),
                locationAsync.when(
                  data: (pos) => Text(
                    pos == null ? 'Location Services Required' : 'Location Active',
                    style: ShiftleyTokens.caption,
                  ),
                  loading: () => const Text('Detecting...', style: ShiftleyTokens.caption),
                  error: (err, _) => const Text('Location Access Denied', style: ShiftleyTokens.caption),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final enabled = await Geolocator.isLocationServiceEnabled();
              if (!enabled) {
                await Geolocator.openLocationSettings();
              } else {
                ref.invalidate(userLocationProvider);
              }
            },
            child: const Text('Update', style: TextStyle(color: ShiftleyTokens.primaryRed)),
          ),
        ],
      ),
    );
  }
}
