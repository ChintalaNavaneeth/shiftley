import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transaction History', style: ShiftleyTokens.h2),
        const SizedBox(height: ShiftleyTokens.spaceM),

        Expanded(
          child: ListView(
            children: [
              _buildTransactionItem(
                'Shift Payout: Housekeeping',
                'May 03, 2024',
                '₹800',
                true, // credit
              ),
              _buildTransactionItem(
                'Penalty: No-Show (May 01)',
                'May 02, 2024',
                '-₹200',
                false, // debit
              ),
              _buildTransactionItem(
                'Shift Payout: Waiter Service',
                'Apr 30, 2024',
                '₹1,200',
                true,
              ),
              _buildTransactionItem(
                'Payout to Bank Account',
                'Apr 29, 2024',
                '-₹2,500',
                false,
                isPayout: true,
              ),
              _buildTransactionItem(
                'Shift Payout: Cleaning',
                'Apr 28, 2024',
                '₹800',
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount, bool isCredit, {bool isPayout = false}) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPayout ? ShiftleyTokens.secondaryCyan : (isCredit ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPayout ? Icons.account_balance : (isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline),
              size: 20,
              color: isPayout ? ShiftleyTokens.inkBlack : (isCredit ? Colors.green : Colors.red),
            ),
          ),
          const SizedBox(width: ShiftleyTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(date, style: ShiftleyTokens.caption),
              ],
            ),
          ),
          Text(
            amount,
            style: ShiftleyTokens.h2.copyWith(
              color: isCredit ? Colors.green : (isPayout ? ShiftleyTokens.inkBlack : Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
