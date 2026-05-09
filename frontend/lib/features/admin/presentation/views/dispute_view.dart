import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import '../../domain/admin_models.dart';
import '../providers/admin_providers.dart';

class DisputeView extends ConsumerWidget {
  const DisputeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disputesAsync = ref.watch(pendingDisputesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Disputes',
          style: ShiftleyTokens.h2,
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        
        disputesAsync.when(
          data: (disputes) => disputes.isEmpty
              ? const Center(child: Text('No pending disputes found.', style: ShiftleyTokens.bodyMedium))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: disputes.length,
                  itemBuilder: (context, index) => _buildDisputeCard(disputes[index], ref, context),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ],
    );
  }

  Widget _buildDisputeCard(Dispute dispute, WidgetRef ref, BuildContext context) {
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
                  Text(dispute.id, style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.primaryRed)),
                  Text(
                    '${dispute.createdAt.day}/${dispute.createdAt.month} ${dispute.createdAt.hour}:${dispute.createdAt.minute}',
                    style: ShiftleyTokens.caption,
                  ),
                ],
              ),
              const SizedBox(height: ShiftleyTokens.spaceM),
              
              if (isMobile) ...[
                _buildEntityInfo('PROFESSIONAL', dispute.workerName),
                const SizedBox(height: ShiftleyTokens.spaceM),
                _buildEntityInfo('BUSINESS', dispute.businessName),
                const SizedBox(height: ShiftleyTokens.spaceM),
                _buildEntityInfo('DISPUTED AMOUNT', '₹ ${(dispute.amountPaise / 100).toStringAsFixed(2)}'),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildEntityInfo('PROFESSIONAL', dispute.workerName)),
                    const SizedBox(width: ShiftleyTokens.spaceM),
                    Expanded(child: _buildEntityInfo('BUSINESS', dispute.businessName)),
                    const SizedBox(width: ShiftleyTokens.spaceM),
                    Expanded(child: _buildEntityInfo('DISPUTED AMOUNT', '₹ ${(dispute.amountPaise / 100).toStringAsFixed(2)}')),
                  ],
                ),
              
              const Divider(height: ShiftleyTokens.spaceXL),
              Text('Reason for Dispute:', style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: ShiftleyTokens.spaceS),
              Text(dispute.reason, style: ShiftleyTokens.bodyMedium),
              const SizedBox(height: ShiftleyTokens.spaceXL),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ShiftleyButton(
                    label: 'Reject Request',
                    isPrimary: false,
                    onPressed: () => _handleResolve(context, ref, dispute.id, 'REJECTED'),
                  ),
                  const SizedBox(width: ShiftleyTokens.spaceM),
                  ShiftleyButton(
                    label: 'Approve Resolution',
                    onPressed: () => _handleResolve(context, ref, dispute.id, 'APPROVED'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleResolve(BuildContext context, WidgetRef ref, String id, String resolution) {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${resolution == 'APPROVED' ? 'Approve' : 'Reject'} Dispute'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add internal notes for resolution...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(pendingDisputesProvider.notifier).resolve(id, resolution, notesController.text);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
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
