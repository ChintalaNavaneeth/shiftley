import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class MyGigsView extends StatefulWidget {
  const MyGigsView({super.key});

  @override
  State<MyGigsView> createState() => _MyGigsViewState();
}

class _MyGigsViewState extends State<MyGigsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: ShiftleyTokens.inkBlack,
          unselectedLabelColor: ShiftleyTokens.mutedText,
          indicatorColor: ShiftleyTokens.primaryRed,
          indicatorWeight: 3,
          labelStyle: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Applied'),
            Tab(text: 'History'),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceM),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingList(),
              _buildAppliedList(),
              _buildHistoryList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingList() {
    return ListView(
      children: [
        _buildGigItem(
          'Housekeeping Professional',
          'Taj Banjara, Hyderabad',
          'Tomorrow, 09:00 AM',
          '₹800',
          'CONFIRMED',
          showActions: true,
        ),
        _buildGigItem(
          'Kitchen Assistant',
          'ITC Kohenur, Hyderabad',
          'May 09, 06:00 PM',
          '₹600',
          'CONFIRMED',
          showActions: true,
        ),
      ],
    );
  }

  Widget _buildAppliedList() {
    return ListView(
      children: [
        _buildGigItem(
          'Security Guard',
          'GVK One Mall, Hyderabad',
          'May 10, 10:00 PM',
          '₹750',
          'PENDING',
        ),
        _buildGigItem(
          'Parking Attendant',
          'Inorbit Mall, Hyderabad',
          'May 11, 11:00 AM',
          '₹500',
          'PENDING',
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return ListView(
      children: [
        _buildGigItem(
          'Waiter (Fine Dining)',
          'Park Hyatt, Hyderabad',
          'May 02, 07:00 PM',
          '₹1,200',
          'COMPLETED',
        ),
        _buildGigItem(
          'Cleaning Staff',
          'Radisson Blu, Hyderabad',
          'Apr 28, 08:00 AM',
          '₹800',
          'COMPLETED',
        ),
      ],
    );
  }

  Widget _buildGigItem(String title, String location, String time, String pay, String status, {bool showActions = false}) {
    Color statusColor = ShiftleyTokens.mutedText;
    if (status == 'CONFIRMED') statusColor = Colors.blue;
    if (status == 'PENDING') statusColor = Colors.orange;
    if (status == 'COMPLETED') statusColor = Colors.green;

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
              Expanded(child: Text(title, style: ShiftleyTokens.h2, overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  border: Border.all(color: statusColor, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(location, style: ShiftleyTokens.bodyMedium),
          Text('$time • $pay', style: ShiftleyTokens.caption),
          
          if (showActions) ...[
            const SizedBox(height: ShiftleyTokens.spaceM),
            Row(
              children: [
                Expanded(
                  child: ShiftleyButton(
                    label: 'Get Directions',
                    onPressed: () {},
                    isPrimary: false,
                    size: ShiftleyButtonSize.small,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShiftleyButton(
                    label: 'Check-In',
                    onPressed: () {},
                    size: ShiftleyButtonSize.small,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
