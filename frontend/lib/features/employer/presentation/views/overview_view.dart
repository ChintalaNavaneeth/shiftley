import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'attendance_view.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: ShiftleyTokens.spaceM),

        // Upcoming Gigs Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Upcoming Shifts', style: ShiftleyTokens.h2),
            TextButton(
              onPressed: () {},
              child: const Text('View All', style: TextStyle(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceM),

        // Gig List
        _buildGigItem(context, 'Housekeeping Staff', 'Tomorrow, 09:00 AM', '4 Workers', 'OPEN'),
        _buildGigItem(context, 'Kitchen Assistant', 'May 06, 06:00 PM', '2 Workers', 'FILLED'),
        _buildGigItem(context, 'Front Desk Support', 'May 08, 10:00 AM', '1 Worker', 'DRAFT'),
      ],
    );
  }

  Widget _buildGigItem(BuildContext context, String title, String time, String workers, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendanceView(shiftTitle: title, shiftTime: time),
            ),
          );
        },
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        child: Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: ShiftleyTokens.paperWhite,
            border: ShiftleyTokens.primaryBorder,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ShiftleyTokens.spaceS),
                decoration: BoxDecoration(
                  color: ShiftleyTokens.background,
                  border: Border.all(color: ShiftleyTokens.inkBlack, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work_outline, size: 20),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ShiftleyTokens.bodyLarge),
                    Text('$time • $workers', style: ShiftleyTokens.caption),
                  ],
                ),
              ),
              _buildStatusChip(status),
              const SizedBox(width: ShiftleyTokens.spaceM),
              const Icon(Icons.chevron_right, color: ShiftleyTokens.mutedText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor = ShiftleyTokens.background;
    if (status == 'OPEN') bgColor = const Color(0xFFE3F2FD);
    if (status == 'FILLED') bgColor = const Color(0xFFE8F5E9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: ShiftleyTokens.inkBlack, width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}
