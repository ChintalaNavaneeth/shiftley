import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class DisputeView extends StatefulWidget {
  const DisputeView({super.key});

  @override
  State<DisputeView> createState() => _DisputeViewState();
}

class _DisputeViewState extends State<DisputeView> {
  bool _showClosed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _showClosed ? 'Closed Disputes' : 'Pending Disputes',
              style: ShiftleyTokens.h2,
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _showClosed = !_showClosed),
              icon: Icon(_showClosed ? Icons.pending_actions : Icons.history),
              label: Text(_showClosed ? 'View Pending' : 'View History'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ShiftleyTokens.inkBlack),
                foregroundColor: ShiftleyTokens.inkBlack,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
              ),
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        
        if (!_showClosed) ...[
          _buildDisputeCard(
            id: 'DISP-4421',
            professional: 'Rahul Sharma',
            business: 'Radisson Blu',
            amount: '₹ 1,200',
            reason: 'No-show reported by business, professional claims attendance.',
            time: '3 hours ago',
            isClosed: false,
          ),
          _buildDisputeCard(
            id: 'DISP-4422',
            professional: 'Anita Deshmukh',
            business: 'Cafe Coffee Day',
            amount: '₹ 800',
            reason: 'Business claims poor service, professional claims overtime unpaid.',
            time: '5 hours ago',
            isClosed: false,
          ),
        ] else ...[
          _buildDisputeCard(
            id: 'DISP-4410',
            professional: 'Kiran Deep',
            business: 'The Park Hotel',
            amount: '₹ 2,500',
            reason: 'Dispute over break timing resolved via mediation.',
            time: 'Yesterday',
            isClosed: true,
            resolution: 'Approved',
          ),
          _buildDisputeCard(
            id: 'DISP-4408',
            professional: 'Sagar Varma',
            business: 'McDonalds',
            amount: '₹ 450',
            reason: 'Uniform damage claim rejected due to lack of evidence.',
            time: '2 days ago',
            isClosed: true,
            resolution: 'Rejected',
          ),
        ],
      ],
    );
  }

  Widget _buildDisputeCard({
    required String id,
    required String professional,
    required String business,
    required String amount,
    required String reason,
    required String time,
    required bool isClosed,
    String? resolution,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 500;

        return Container(
          margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceL),
          padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
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
                  Text(id, style: ShiftleyTokens.bodyLarge.copyWith(color: isClosed ? ShiftleyTokens.mutedText : ShiftleyTokens.primaryRed)),
                  if (isClosed && resolution != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: resolution == 'Approved' ? Colors.green.withValues(alpha: 0.1) : ShiftleyTokens.primaryRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        resolution.toUpperCase(),
                        style: TextStyle(
                          color: resolution == 'Approved' ? Colors.green : ShiftleyTokens.primaryRed,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(time, style: ShiftleyTokens.caption),
                ],
              ),
              const SizedBox(height: ShiftleyTokens.spaceM),
              
              if (isMobile) ...[
                _buildEntityInfo('PROFESSIONAL', professional),
                const SizedBox(height: ShiftleyTokens.spaceM),
                _buildEntityInfo('BUSINESS', business),
                const SizedBox(height: ShiftleyTokens.spaceM),
                _buildEntityInfo('DISPUTED AMOUNT', amount),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildEntityInfo('PROFESSIONAL', professional)),
                    const SizedBox(width: ShiftleyTokens.spaceM),
                    Expanded(child: _buildEntityInfo('BUSINESS', business)),
                    const SizedBox(width: ShiftleyTokens.spaceM),
                    Expanded(child: _buildEntityInfo('DISPUTED AMOUNT', amount)),
                  ],
                ),
              
              const Divider(height: ShiftleyTokens.spaceXL),
              Text('Reason for Dispute:', style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: ShiftleyTokens.spaceS),
              Text(reason, style: ShiftleyTokens.bodyMedium),
              const SizedBox(height: ShiftleyTokens.spaceXL),
              
              if (!isClosed)
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildButton(label: 'Reject Request', isPrimary: false),
                      const SizedBox(height: ShiftleyTokens.spaceM),
                      _buildButton(label: 'Approve Resolution', isPrimary: true),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildButton(label: 'Reject Request', isPrimary: false),
                      const SizedBox(width: ShiftleyTokens.spaceM),
                      _buildButton(label: 'Approve Resolution', isPrimary: true),
                    ],
                  )
              else
                const Center(
                  child: Text(
                    'This dispute has been settled.',
                    style: TextStyle(fontStyle: FontStyle.italic, color: ShiftleyTokens.mutedText),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton({required String label, required bool isPrimary}) {
    return isPrimary
        ? ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: ShiftleyTokens.inkBlack,
              foregroundColor: ShiftleyTokens.paperWhite,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceL, vertical: ShiftleyTokens.spaceM),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
            ),
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: ShiftleyTokens.inkBlack),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceL, vertical: ShiftleyTokens.spaceM),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
            ),
            child: Text(label, style: const TextStyle(color: ShiftleyTokens.inkBlack)),
          );
  }

  Widget _buildEntityInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption),
        const SizedBox(height: 4),
        Text(value, style: ShiftleyTokens.bodyLarge),
      ],
    );
  }
}
