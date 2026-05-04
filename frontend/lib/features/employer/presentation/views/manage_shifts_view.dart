import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class ManageShiftsView extends StatelessWidget {
  const ManageShiftsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: ShiftleyTokens.inkBlack,
            unselectedLabelColor: ShiftleyTokens.mutedText,
            indicatorColor: ShiftleyTokens.primaryRed,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Open (12)'),
              Tab(text: 'Active (4)'),
              Tab(text: 'History (85)'),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: TabBarView(
              children: [
                _buildShiftList('OPEN'),
                _buildShiftList('ACTIVE'),
                _buildShiftList('HISTORY'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftList(String status) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildShiftCard(
          title: 'Shift #$index - Housekeeping',
          time: '12 May, 09:00 AM - 05:00 PM',
          location: 'Banjara Hills, Hyderabad',
          workers: '2/4 Filled',
          pay: '₹ 800 / day',
          status: status,
        );
      },
    );
  }

  Widget _buildShiftCard({
    required String title,
    required String time,
    required String location,
    required String workers,
    required String pay,
    required String status,
  }) {
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
              Text(title, style: ShiftleyTokens.h2),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceS),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 8),
              Text(time, style: ShiftleyTokens.caption),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 8),
              Text(location, style: ShiftleyTokens.caption),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('COMPENSATION', style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                  Text(pay, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ATTENDANCE', style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                  Text(workers, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          const Divider(color: ShiftleyTokens.inkBlack, thickness: 1),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Row(
            children: [
              Expanded(
                child: ShiftleyButton(
                  label: 'View Applications',
                  onPressed: () {},
                  size: ShiftleyButtonSize.small,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: ShiftleyButton(
                  label: 'Manage Shift',
                  onPressed: () {},
                  size: ShiftleyButtonSize.small,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status == 'OPEN' ? ShiftleyTokens.secondaryCyan : ShiftleyTokens.background,
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
