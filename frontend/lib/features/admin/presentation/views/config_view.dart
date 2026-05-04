import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Platform Variable Management', style: ShiftleyTokens.h2),
        const SizedBox(height: ShiftleyTokens.spaceL),
        
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 800) {
              return Column(
                children: [
                  _buildConfigCard(
                    title: 'Employer Subscription Fees',
                    children: [
                      _buildInputField('Monthly Fee (INR)', '₹ 2,999'),
                      _buildInputField('Weekly Fee (INR)', '₹ 899'),
                      _buildInputField('Daily Fee (INR)', '₹ 150'),
                    ],
                  ),
                  const SizedBox(height: ShiftleyTokens.spaceL),
                  _buildConfigCard(
                    title: 'Cancellation Penalties',
                    children: [
                      _buildInputField('Professional No-Show Penalty (INR)', '₹ 500'),
                      _buildInputField('Business Late-Cancel Penalty (INR)', '₹ 300'),
                    ],
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildConfigCard(
                    title: 'Employer Subscription Fees',
                    children: [
                      _buildInputField('Monthly Fee (INR)', '₹ 2,999'),
                      _buildInputField('Weekly Fee (INR)', '₹ 899'),
                      _buildInputField('Daily Fee (INR)', '₹ 150'),
                    ],
                  ),
                ),
                const SizedBox(width: ShiftleyTokens.spaceL),
                Expanded(
                  child: _buildConfigCard(
                    title: 'Cancellation Penalties',
                    children: [
                      _buildInputField('Professional No-Show Penalty (INR)', '₹ 500'),
                      _buildInputField('Business Late-Cancel Penalty (INR)', '₹ 300'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfigCard({required String title, required List<Widget> children}) {
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
          const SizedBox(height: ShiftleyTokens.spaceL),
          Align(
            alignment: Alignment.centerRight,
            child: ShiftleyButton(
              label: 'Save Changes',
              onPressed: () {},
              size: ShiftleyButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.bodyMedium),
          const SizedBox(height: ShiftleyTokens.spaceS),
          TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              filled: true,
              fillColor: ShiftleyTokens.background,
              border: ShiftleyTokens.primaryInputBorder,
              enabledBorder: ShiftleyTokens.primaryInputBorder,
              focusedBorder: ShiftleyTokens.focusInputBorder,
              contentPadding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM),
            ),
          ),
        ],
      ),
    );
  }
}
