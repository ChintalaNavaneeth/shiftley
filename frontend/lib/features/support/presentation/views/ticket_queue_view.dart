import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_text_field.dart';

class TicketQueueView extends StatefulWidget {
  final bool showResolved;
  const TicketQueueView({super.key, required this.showResolved});

  @override
  State<TicketQueueView> createState() => _TicketQueueViewState();
}

class _TicketQueueViewState extends State<TicketQueueView> {
  String? _selectedTicketId;

  @override
  Widget build(BuildContext context) {
    if (_selectedTicketId != null) {
      return _buildTicketDetail(_selectedTicketId!);
    }

    return Column(
      children: [
        STextField(
          hint: 'Search tickets...',
          prefix: const Icon(Icons.search),
          controller: TextEditingController(),
        ),
        const SizedBox(height: ShiftleyTokens.spaceM),
        _buildFilterRow(),
        const SizedBox(height: ShiftleyTokens.spaceL),
        if (widget.showResolved) ...[
          const Text('Source Distribution', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          _buildSourceDistribution(),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          const Text('Resolved History', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          ..._buildResolvedTickets(),
        ] else ...[
          const Text('All Open Tickets', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceM),
          ..._buildActiveTickets(),
        ],
      ],
    );
  }

  Widget _buildSourceDistribution() {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        children: [
          _buildDistRow('Professional Issues', 0.65, ShiftleyTokens.secondaryCyan),
          const SizedBox(height: 12),
          _buildDistRow('Employer Support', 0.25, Colors.blue),
          const SizedBox(height: 12),
          _buildDistRow('Technical / Bug', 0.10, ShiftleyTokens.primaryRed),
        ],
      ),
    );
  }

  Widget _buildDistRow(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
            Text('${(percent * 100).toInt()}%', style: ShiftleyTokens.caption),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: ShiftleyTokens.background,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All Priorities', true),
          const SizedBox(width: 8),
          _buildFilterChip('Critical Tickets', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? ShiftleyTokens.inkBlack : ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : ShiftleyTokens.inkBlack,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildActiveTickets() {
    return [
      _buildTicketCard('TKT-9912', 'Payment Delay', 'Rahul Sharma', 'Professional', 'URGENT', ShiftleyTokens.primaryRed, true),
      _buildTicketCard('TKT-9850', 'Profile Bug', 'Taj Banjara', 'Employer', 'HIGH', Colors.orange, false),
      _buildTicketCard('TKT-9740', 'GPS Issue', 'Anita D.', 'Professional', 'MEDIUM', Colors.blue, true),
      _buildTicketCard('TKT-9721', 'KYC Pending', 'GMR AeroCity', 'Employer', 'LOW', Colors.green, false),
    ];
  }

  List<Widget> _buildResolvedTickets() {
    return [
      _buildTicketCard('TKT-9600', 'Login Issue', 'Sagar V.', 'Professional', 'RESOLVED', Colors.grey, false),
      _buildTicketCard('TKT-9550', 'Wrong Location', 'Blue Fox', 'Employer', 'RESOLVED', Colors.grey, false),
    ];
  }

  Widget _buildTicketCard(String id, String subject, String user, String role, String priority, Color priorityColor, bool isWaitingResponse) {
    final bool isCritical = priority == 'URGENT';

    return GestureDetector(
      onTap: () => setState(() => _selectedTicketId = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        decoration: BoxDecoration(
          color: ShiftleyTokens.paperWhite,
          border: isCritical ? Border.all(color: ShiftleyTokens.primaryRed, width: 2) : ShiftleyTokens.primaryBorder,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          boxShadow: isCritical ? [
            BoxShadow(color: ShiftleyTokens.primaryRed.withValues(alpha: 0.1), blurRadius: 8, spreadRadius: 1)
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(id, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold, color: isCritical ? ShiftleyTokens.primaryRed : null)),
                    if (isWaitingResponse) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: ShiftleyTokens.primaryRed, shape: BoxShape.circle),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), border: Border.all(color: priorityColor), borderRadius: BorderRadius.circular(4)),
                  child: Text(priority, style: TextStyle(color: priorityColor, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(subject, style: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: ShiftleyTokens.mutedText),
                const SizedBox(width: 4),
                Text('$user ($role)', style: ShiftleyTokens.caption),
                const Spacer(),
                const Text('Last update: 5m ago', style: TextStyle(fontSize: 10, color: ShiftleyTokens.mutedText)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketDetail(String id) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _selectedTicketId = null)),
            Text('Conversation: $id', style: ShiftleyTokens.h2),
            const Spacer(),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        const Divider(height: 1, thickness: 1, color: ShiftleyTokens.inkBlack),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceM),
          child: Column(
            children: [
              _buildChatBubble('Hello, I worked the Sunday shift at Taj Banjara but my payment of ₹1200 is still showing as "Pending" in my wallet.', false, '09:00 AM'),
              _buildChatBubble('Hi Rahul, I can help you with that. Let me check the verification status from the employer side.', true, '09:02 AM'),
              _buildChatBubble('One moment please...', true, '09:02 AM'),
              _buildChatBubble('Okay, I see that the employer has not yet marked the shift as "Completed". I am sending them a nudge now.', true, '09:05 AM'),
              _buildChatBubble('Thank you! Please let me know when it\'s done.', false, '09:06 AM'),
            ],
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatBubble(String text, bool isAgent, String time) {
    return Align(
      alignment: isAgent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        decoration: BoxDecoration(
          color: isAgent ? ShiftleyTokens.inkBlack : ShiftleyTokens.secondaryCyan,
          border: ShiftleyTokens.primaryBorder,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isAgent ? 12 : 0),
            bottomRight: Radius.circular(isAgent ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: ShiftleyTokens.bodyMedium.copyWith(color: isAgent ? Colors.white : ShiftleyTokens.inkBlack)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(fontSize: 10, color: isAgent ? Colors.white60 : ShiftleyTokens.mutedText)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: const BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: Border(top: BorderSide(color: ShiftleyTokens.inkBlack, width: 2)),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
          Expanded(
            child: STextField(
              hint: 'Type a message...',
              controller: TextEditingController(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: ShiftleyTokens.inkBlack, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
            child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () {}),
          ),
        ],
      ),
    );
  }
}
