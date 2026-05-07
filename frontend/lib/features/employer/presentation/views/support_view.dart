import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/shared/widgets/s_text_field.dart';

enum SupportSubView { list, chat }

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  SupportSubView _subView = SupportSubView.list;
  String _selectedTicketId = '';
  String _selectedTicketSubject = '';
  int _currentPage = 1;
  static const int _ticketsPerPage = 5;

  final List<Map<String, dynamic>> _allTickets = [
    {'id': 'TKT-8854', 'subject': 'Professional didn\'t show up', 'status': 'IN PROGRESS', 'color': Colors.blue},
    {'id': 'TKT-8821', 'subject': 'Payment not reflected', 'status': 'RESOLVED', 'color': Colors.green},
    {'id': 'TKT-8710', 'subject': 'App crashing on payout', 'status': 'RESOLVED', 'color': Colors.green},
    {'id': 'TKT-8650', 'subject': 'Change business name', 'status': 'RESOLVED', 'color': Colors.green},
    {'id': 'TKT-8520', 'subject': 'Refund for cancelled GIG', 'status': 'RESOLVED', 'color': Colors.green},
    {'id': 'TKT-8400', 'subject': 'Old issue 1', 'status': 'RESOLVED', 'color': Colors.green},
    {'id': 'TKT-8300', 'subject': 'Old issue 2', 'status': 'RESOLVED', 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    switch (_subView) {
      case SupportSubView.list:
        return _buildListView();
      case SupportSubView.chat:
        return _buildChatView();
    }
  }

  Widget _buildListView() {
    final int startIndex = (_currentPage - 1) * _ticketsPerPage;
    final int endIndex = (startIndex + _ticketsPerPage).clamp(0, _allTickets.length);
    final List<Map<String, dynamic>> displayedTickets = _allTickets.sublist(startIndex, endIndex);
    final int totalPages = (_allTickets.length / _ticketsPerPage).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Track your tickets and communicate with our team.', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tickets', style: ShiftleyTokens.h2),
            ShiftleyButton(
              label: 'New Ticket', 
              onPressed: _showRaiseTicketDialog,
              size: ShiftleyButtonSize.small,
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceM),
        
        Column(
          children: displayedTickets.map((ticket) => _buildTicketItem(
            ticket['id'], 
            ticket['subject'], 
            ticket['status'], 
            ticket['color'],
          )).toList(),
        ),
        
        const SizedBox(height: ShiftleyTokens.spaceXL),

        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageButton(Icons.chevron_left, _currentPage > 1 ? () => setState(() => _currentPage--) : null),
                const SizedBox(width: ShiftleyTokens.spaceL),
                Text('Page $_currentPage of $totalPages', style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: ShiftleyTokens.spaceL),
                _buildPageButton(Icons.chevron_right, _currentPage < totalPages ? () => setState(() => _currentPage++) : null),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPageButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap == null ? ShiftleyTokens.background : ShiftleyTokens.paperWhite,
          border: ShiftleyTokens.primaryBorder,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 20, color: onTap == null ? ShiftleyTokens.mutedText : ShiftleyTokens.inkBlack),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _subView = SupportSubView.list),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedTicketId, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
                  Text(_selectedTicketSubject, style: ShiftleyTokens.bodyLarge, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('OPEN', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const Divider(height: ShiftleyTokens.spaceL),

        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceM),
          children: [
            _buildChatBubble(
              'Hi Taj Banjara! We have received your query regarding the payment delay. Our team is looking into it.',
              isSupport: true,
              time: '10:30 AM',
            ),
            _buildChatBubble(
              'Thank you. The payment was processed 2 days ago but still shows pending in my dashboard.',
              isSupport: false,
              time: '10:35 AM',
            ),
            _buildChatBubble(
              'Understood. Could you please share the transaction reference ID?',
              isSupport: true,
              time: '10:40 AM',
            ),
          ],
        ),

        const SizedBox(height: ShiftleyTokens.spaceL),

        Padding(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          child: Row(
            children: [
              Expanded(
                child: STextField(
                  hint: 'Type your message...',
                  controller: TextEditingController(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: ShiftleyTokens.inkBlack,
                  borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                  border: ShiftleyTokens.primaryBorder,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: ShiftleyTokens.paperWhite),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(String text, {required bool isSupport, required String time}) {
    return Align(
      alignment: isSupport ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        decoration: BoxDecoration(
          color: isSupport ? ShiftleyTokens.secondaryCyan : ShiftleyTokens.inkBlack,
          border: ShiftleyTokens.primaryBorder,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isSupport ? 0 : 12),
            bottomRight: Radius.circular(isSupport ? 12 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: ShiftleyTokens.bodyMedium.copyWith(
                color: isSupport ? ShiftleyTokens.inkBlack : ShiftleyTokens.paperWhite,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isSupport ? ShiftleyTokens.mutedText : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketItem(String id, String subject, String status, Color statusColor) {
    return GestureDetector(
      onTap: () => setState(() {
        _subView = SupportSubView.chat;
        _selectedTicketId = id;
        _selectedTicketSubject = subject;
      }),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(id, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subject, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
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
      ),
    );
  }

  void _showRaiseTicketDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShiftleyTokens.paperWhite,
        shape: RoundedRectangleBorder(
          side: ShiftleyTokens.primaryBorderSide,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        title: const Text('Raise a Support Ticket', style: ShiftleyTokens.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What can we help you with?', style: ShiftleyTokens.caption),
            const SizedBox(height: 8),
            STextField(hint: 'Subject (e.g. Attendance Issue)', controller: TextEditingController()),
            const SizedBox(height: ShiftleyTokens.spaceM),
            const Text('Detailed Description', style: ShiftleyTokens.caption),
            const SizedBox(height: 8),
            STextField(hint: 'Describe your problem in detail...', controller: TextEditingController(), maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ShiftleyButton(label: 'Submit Ticket', onPressed: () => Navigator.pop(context), size: ShiftleyButtonSize.small),
        ],
      ),
    );
  }
}
