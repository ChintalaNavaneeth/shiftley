import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import '../providers/admin_providers.dart';

class ConfigView extends ConsumerWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(platformConfigNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Platform Variable Management', style: ShiftleyTokens.h2),
        const SizedBox(height: ShiftleyTokens.spaceL),
        
        configAsync.when(
          data: (config) => LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  _buildConfigCard(
                    title: 'Platform Service Fees',
                    ref: ref,
                    children: [
                      _buildInputField(
                        'Service Fee (%)',
                        config.feePercentage.toString(),
                        onChanged: (val) async {
                          final fee = double.tryParse(val);
                          if (fee != null) {
                            await ref.read(platformConfigNotifierProvider.notifier).updateFees(fee);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: ShiftleyTokens.spaceL),
                  _buildConfigCard(
                    title: 'Operational Defaults',
                    ref: ref,
                    children: [
                      _buildInputField('Max Workers per Gig', config.maxWorkersPerGig.toString()),
                      _buildInputField('Min Wage (INR/hr)', (config.minWagePaise / 100).toString()),
                    ],
                  ),
                ],
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ],
    );
  }

  Widget _buildConfigCard({required String title, required List<Widget> children, required WidgetRef ref}) {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value, {ValueChanged<String>? onChanged}) {
    final controller = TextEditingController(text: value);
    return Padding(
      padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.bodyMedium),
          const SizedBox(height: ShiftleyTokens.spaceS),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onSubmitted: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: ShiftleyTokens.background,
              border: ShiftleyTokens.primaryInputBorder,
              enabledBorder: ShiftleyTokens.primaryInputBorder,
              focusedBorder: ShiftleyTokens.focusInputBorder,
              contentPadding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM),
              suffixIcon: onChanged != null ? IconButton(
                icon: const Icon(Icons.check, size: 16),
                onPressed: () => onChanged(controller.text),
              ) : null,
            ),
          ),
        ],
      ),
    );
  }
}
