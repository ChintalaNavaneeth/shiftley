import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class AttendanceView extends StatelessWidget {
  final String shiftTitle;
  final String shiftTime;

  const AttendanceView({
    super.key,
    required this.shiftTitle,
    required this.shiftTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftleyTokens.background,
      appBar: AppBar(
        backgroundColor: ShiftleyTokens.paperWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: ShiftleyTokens.inkBlack),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shiftTitle, style: ShiftleyTokens.h2),
            Text(shiftTime, style: ShiftleyTokens.caption),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(height: 2, thickness: 2, color: ShiftleyTokens.inkBlack),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        itemCount: 4,
        itemBuilder: (context, index) {
          return _buildWorkerAttendanceCard(
            context,
            name: ['Rahul Sharma', 'Sneha Reddy', 'Vikram Singh', 'Ananya Das'][index],
            status: index % 2 == 0 ? 'NOT CLOCKED IN' : 'CLOCKED IN',
            time: index % 2 == 0 ? '--:--' : '09:05 AM',
          );
        },
      ),
    );
  }

  Widget _buildWorkerAttendanceCard(BuildContext context, {
    required String name,
    required String status,
    required String time,
  }) {
    final bool isClockedIn = status == 'CLOCKED IN';

    return Container(
      margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ShiftleyTokens.secondaryCyan,
                  border: ShiftleyTokens.primaryBorder,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: ShiftleyTokens.bodyLarge),
                    Text(status, style: ShiftleyTokens.caption.copyWith(
                      color: isClockedIn ? Colors.green : ShiftleyTokens.primaryRed,
                      fontWeight: FontWeight.bold,
                    )),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  Text(time, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          const Divider(color: ShiftleyTokens.background, thickness: 1),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Row(
            children: [
              Expanded(
                child: ShiftleyButton(
                  label: isClockedIn ? 'Clock Out (QR)' : 'Clock In (QR)',
                  onPressed: () => _openQRScanner(context, name),
                  icon: Icons.qr_code_scanner,
                  size: ShiftleyButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openQRScanner(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: ShiftleyTokens.inkBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            Text('Scanning for $name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            // Mock Scanner UI
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: ShiftleyTokens.primaryRed, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 150, color: Colors.white24),
              ),
            ),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            const Text('Align QR code within the frame', style: TextStyle(color: Colors.white70)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
              child: ShiftleyButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
                isPrimary: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
