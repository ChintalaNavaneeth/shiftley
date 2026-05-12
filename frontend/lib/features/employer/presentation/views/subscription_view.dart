import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/features/employer/data/employer_repository.dart';
import 'package:shiftley_frontend/features/employer/domain/models/employer_models.dart';

class SubscriptionView extends ConsumerWidget {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(employerDashboardProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed)),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (data) {
        debugPrint('SubscriptionView: Received ${data.availablePlans.length} plans');
        for (var p in data.availablePlans) {
          debugPrint('Plan: ${p.name}, Price: ${p.pricePaise}, ID: ${p.id}');
        }
        return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage your subscription and usage limits.', style: ShiftleyTokens.bodyMedium),
            const SizedBox(height: ShiftleyTokens.spaceXL),
    
            // Current Plan Card
            _buildCurrentPlanCard(data.stats),
    
            const SizedBox(height: ShiftleyTokens.spaceXL),
    
            const Text('Available Plans', style: ShiftleyTokens.h1),
            const Text('Choose a plan that fits your business needs.', style: ShiftleyTokens.bodyMedium),
            const SizedBox(height: ShiftleyTokens.spaceL),

            if (data.availablePlans.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('No plans available at the moment.'),
              ))
            else
              ...data.availablePlans.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
                child: _buildPlanCard(
                  context,
                  ref,
                  plan.id,
                  plan.name.toUpperCase(),
                  '₹ ${(plan.pricePaise / 100).toStringAsFixed(0)}',
                  '${plan.maxGigs} Gig Posts included',
                  'Maximum ${plan.maxEmployeesPerGig} employees per gig',
                  'Valid for ${plan.durationDays} days',
                  data.stats.activePlan == plan.id,
                ),
              )),
            
            ],
          ),
        );
      },
    );
  }

  String _formatPlanName(String planId) {
    if (planId == 'NONE') return 'No Active Plan';
    if (planId.toLowerCase().contains('daily')) return 'Daily';
    if (planId.toLowerCase().contains('weekly')) return 'Weekly';
    if (planId.toLowerCase().contains('monthly')) return 'Monthly';
    return planId.split('_').first.toUpperCase();
  }

  String _formatExpiry(DateTime expiry) {
    final diff = expiry.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    
    if (days > 0) {
      return '$days Day${days > 1 ? 's' : ''} $hours Hour${hours != 1 ? 's' : ''}';
    }
    return '$hours Hour${hours != 1 ? 's' : ''}';
  }

  Widget _buildCurrentPlanCard(EmployerStats data) {
    final bool hasPlan = data.activePlan != 'NONE';
    final int totalGigs = data.totalGigsPosted.toInt();
    final int remaining = data.freeGigsRemaining;
    final int maxVal = totalGigs + remaining;
    final double progress = maxVal > 0 ? (totalGigs / maxVal) : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: BoxDecoration(
        color: ShiftleyTokens.inkBlack,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CURRENT PLAN', style: TextStyle(color: ShiftleyTokens.secondaryCyan, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(
                      hasPlan ? '${_formatPlanName(data.activePlan)} Plan' : 'No Active Plan', 
                      style: const TextStyle(color: ShiftleyTokens.paperWhite, fontSize: 26, fontWeight: FontWeight.w900),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasPlan)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
            ],
          ),
          if (hasPlan) ...[
            const SizedBox(height: ShiftleyTokens.spaceXL),
            Row(
              children: [
                _buildLargeStat('$remaining / $maxVal', 'POSTS REMAINING'),
                const SizedBox(width: ShiftleyTokens.spaceXXL),
                if (data.planExpiresAt != null)
                  _buildLargeStat(_formatExpiry(data.planExpiresAt!), 'UNTIL EXPIRY'),
              ],
            ),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF333333),
              color: ShiftleyTokens.primaryRed,
              minHeight: 12,
            ),
          ] else ...[
            const SizedBox(height: ShiftleyTokens.spaceXL),
            const Text(
              'Purchase a plan below to start posting gigs and hiring employees.',
              style: TextStyle(color: ShiftleyTokens.utilityGrey, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLargeStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: ShiftleyTokens.paperWhite, fontSize: 24, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: ShiftleyTokens.utilityGrey, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, 
    WidgetRef ref,
    String planId,
    String name, 
    String price, 
    String posts, 
    String employees, 
    String description,
    bool isCurrent
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: BoxDecoration(
        color: isCurrent ? ShiftleyTokens.secondaryCyan : ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        boxShadow: isCurrent ? [] : [
          const BoxShadow(
            color: ShiftleyTokens.inkBlack,
            offset: Offset(4, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0)),
              Text(price, style: ShiftleyTokens.h1.copyWith(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: ShiftleyTokens.bodyMedium.copyWith(color: isCurrent ? ShiftleyTokens.inkBlack : ShiftleyTokens.mutedText)),
          const Divider(height: 32, color: ShiftleyTokens.inkBlack),
          Row(
            children: [
              const Icon(Icons.post_add, size: 20),
              const SizedBox(width: 8),
              Text(posts, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 20),
              const SizedBox(width: 8),
              Text(employees, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          if (isCurrent)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Center(
                child: Text('CURRENT ACTIVE PLAN', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            )
          else
            ShiftleyButton(
              label: 'ACTIVATE PLAN',
              onPressed: () => _showPurchaseDialog(context, ref, planId, name),
              isFullWidth: true,
            ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, WidgetRef ref, String planId, String planName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RazorpayMockModal(
        planName: planName,
        onSuccess: (paymentId) async {
          // Call backend to activate plan
          try {
            await ref.read(employerRepositoryProvider).purchaseSubscription(planId, paymentId);
            if (context.mounted) {
              Navigator.pop(context);
              _showSuccessScreen(context, ref, planName);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to activate plan: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showSuccessScreen(BuildContext context, WidgetRef ref, String planName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PaymentSuccessScreen(
          planName: planName,
          onDone: () {
            ref.invalidate(employerDashboardProvider);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _RazorpayMockModal extends StatelessWidget {
  final String planName;
  final Function(String) onSuccess;

  const _RazorpayMockModal({required this.planName, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF02042B), // Razorpay Dark Blue
            child: Row(
              children: [
                const Icon(Icons.payment, color: Colors.blue, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RAZORPAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    Text('Paying for $planName Plan', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Preferred Payment Methods', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                _buildMethod(Icons.qr_code, 'UPI - Google Pay, PhonePe, etc.'),
                _buildMethod(Icons.credit_card, 'Card - Visa, Mastercard, RuPay'),
                _buildMethod(Icons.account_balance, 'Netbanking'),
                _buildMethod(Icons.wallet, 'Wallet'),
                const SizedBox(height: 32),
                const Center(
                  child: Text('TEST MODE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ShiftleyButton(
              label: 'PAY NOW', 
              onPressed: () => onSuccess('pay_mock_${DateTime.now().millisecondsSinceEpoch}'),
              isFullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethod(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: () {},
    );
  }
}

class _PaymentSuccessScreen extends StatelessWidget {
  final String planName;
  final VoidCallback onDone;

  const _PaymentSuccessScreen({required this.planName, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 24),
              const Text('Payment Successful!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                'Your $planName Plan is now active. You can now start posting GIGs and hiring.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              ShiftleyButton(
                label: 'BACK TO DASHBOARD',
                onPressed: onDone,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
