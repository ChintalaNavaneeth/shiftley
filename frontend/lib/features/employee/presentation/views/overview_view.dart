import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next Shift Section
          const Text('Next Shift', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          _buildNextShiftCard(
            context,
            'Housekeeping Professional',
            'Taj Banjara, Hyderabad',
            'Tomorrow, 09:00 AM - 05:00 PM',
            '₹800',
            'General cleaning of lobby area, banquet halls, and guest corridors. Ensure high standards of hygiene and presentation.',
            'Mr. Rajesh Gupta',
            '+91 98765 43210',
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          // Stats Table Section
          const Text('Performance Stats', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          _buildStatsTable(),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
        ],
      ),
    );
  }

  Widget _buildStatsTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        children: [
          _buildTablePair('Total Gigs', '42', 'Total Earned', '₹12,450'),
          const Divider(height: 1, color: ShiftleyTokens.inkBlack),
          _buildTablePair('This Month', '₹3,200', 'No Shows', '0'),
          const Divider(height: 1, color: ShiftleyTokens.inkBlack),
          _buildTablePair('Fines', '₹0', 'Avg Rating', '4.9 ★'),
        ],
      ),
    );
  }

  Widget _buildTablePair(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(child: _buildTableCell(label1, value1)),
        Container(width: 1, height: 60, color: ShiftleyTokens.inkBlack),
        Expanded(child: _buildTableCell(label2, value2)),
      ],
    );
  }

  Widget _buildTableCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.caption.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNextShiftCard(
    BuildContext context, 
    String title, 
    String location, 
    String time, 
    String pay,
    String description,
    String employerName,
    String contactNumber,
  ) {
    return Container(
      width: double.infinity,
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
              Text(title, style: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Text(pay, style: ShiftleyTokens.h2.copyWith(color: Colors.green)),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceS),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text(location, style: ShiftleyTokens.caption),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text(time, style: ShiftleyTokens.caption),
            ],
          ),
          const Divider(height: ShiftleyTokens.spaceXL, color: ShiftleyTokens.inkBlack),
          
          const Text('JOB DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.primaryRed)),
          const SizedBox(height: 4),
          Text(description, style: ShiftleyTokens.bodyMedium),
          const SizedBox(height: ShiftleyTokens.spaceL),

          const Text('EMPLOYER CONTACT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.primaryRed)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: ShiftleyTokens.secondaryCyan, shape: BoxShape.circle),
                child: const Icon(Icons.person, size: 16, color: ShiftleyTokens.inkBlack),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employerName, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(contactNumber, style: ShiftleyTokens.caption),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.phone_in_talk, color: Colors.green),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          ShiftleyButton(
            label: 'Check-In Details',
            onPressed: () => _showQrDialog(context),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShiftleyTokens.paperWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          side: ShiftleyTokens.primaryBorderSide,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        title: const Text('Check-In QR Code', style: ShiftleyTokens.h2),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Show this QR code to the employer at the shift location.', style: ShiftleyTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: ShiftleyTokens.spaceXL),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: ShiftleyTokens.primaryBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: QrImageView(
                      data: 'SHIFT-EMP-12345-RAHUL',
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
