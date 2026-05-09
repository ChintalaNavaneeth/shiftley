import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import '../../domain/admin_models.dart';
import '../providers/admin_providers.dart';

class ConfigView extends ConsumerStatefulWidget {
  const ConfigView({super.key});

  @override
  ConsumerState<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends ConsumerState<ConfigView> {
  // Editing states for each section
  bool _isEditingPricing = false;
  bool _isEditingPenalties = false;
  bool _isEditingCancellation = false;
  
  // Controllers
  late TextEditingController _monthlyController;
  late TextEditingController _weeklyController;
  late TextEditingController _dailyController;
  late TextEditingController _noShowController;
  late TextEditingController _cancel6hController;
  late TextEditingController _cancel3hController;
  late TextEditingController _cancel1hController;

  @override
  void initState() {
    super.initState();
    _monthlyController = TextEditingController();
    _weeklyController = TextEditingController();
    _dailyController = TextEditingController();
    _noShowController = TextEditingController();
    _cancel6hController = TextEditingController();
    _cancel3hController = TextEditingController();
    _cancel1hController = TextEditingController();
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    _weeklyController.dispose();
    _dailyController.dispose();
    _noShowController.dispose();
    _cancel6hController.dispose();
    _cancel3hController.dispose();
    _cancel1hController.dispose();
    super.dispose();
  }

  void _syncControllers(PlatformConfig config) {
    if (!_isEditingPricing) {
      _monthlyController.text = config.employerSubscriptionMonthly.toString();
      _weeklyController.text = config.employerSubscriptionWeekly.toString();
      _dailyController.text = config.employerSubscriptionDaily.toString();
    }
    if (!_isEditingPenalties) {
      _noShowController.text = config.workerNoShowPenalty.toString();
    }
    if (!_isEditingCancellation) {
      _cancel6hController.text = config.employerCancelPenalty6h.toString();
      _cancel3hController.text = config.employerCancelPenalty3h.toString();
      _cancel1hController.text = config.employerCancelPenalty1h.toString();
    }
  }

  Future<void> _saveSection({
    double? monthly,
    double? weekly,
    double? daily,
    double? noShow,
    double? c6h,
    double? c3h,
    double? c1h,
  }) async {
    final notifier = ref.read(platformConfigNotifierProvider.notifier);
    await notifier.updateConfig(
      employerSubscriptionMonthly: monthly,
      employerSubscriptionWeekly: weekly,
      employerSubscriptionDaily: daily,
      workerNoShowPenalty: noShow,
      employerCancelPenalty6h: c6h,
      employerCancelPenalty3h: c3h,
      employerCancelPenalty1h: c1h,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Section updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(platformConfigNotifierProvider);

    return configAsync.when(
      data: (config) {
        _syncControllers(config);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform Configuration', style: ShiftleyTokens.h2),
            const SizedBox(height: ShiftleyTokens.spaceL),
            Column(
              children: [
                _buildConfigCard(
                  title: 'Subscription Pricing',
                  isEditing: _isEditingPricing,
                  onEditToggle: () => setState(() => _isEditingPricing = !_isEditingPricing),
                  onSave: () async {
                    await _saveSection(
                      monthly: double.tryParse(_monthlyController.text),
                      weekly: double.tryParse(_weeklyController.text),
                      daily: double.tryParse(_dailyController.text),
                    );
                    setState(() => _isEditingPricing = false);
                  },
                  children: [
                    _buildInputField('Monthly Subscription (INR)', _monthlyController, _isEditingPricing),
                    _buildInputField('Weekly Subscription (INR)', _weeklyController, _isEditingPricing),
                    _buildInputField('Daily Subscription (INR)', _dailyController, _isEditingPricing),
                  ],
                ),
                const SizedBox(height: ShiftleyTokens.spaceL),
                _buildConfigCard(
                  title: 'Compliance & Penalties',
                  isEditing: _isEditingPenalties,
                  onEditToggle: () => setState(() => _isEditingPenalties = !_isEditingPenalties),
                  onSave: () async {
                    await _saveSection(
                      noShow: double.tryParse(_noShowController.text),
                    );
                    setState(() => _isEditingPenalties = false);
                  },
                  children: [
                    _buildInputField('Worker No Show Penalty (INR)', _noShowController, _isEditingPenalties),
                  ],
                ),
                const SizedBox(height: ShiftleyTokens.spaceL),
                _buildConfigCard(
                  title: 'Employer Cancellation Policy',
                  isEditing: _isEditingCancellation,
                  onEditToggle: () => setState(() => _isEditingCancellation = !_isEditingCancellation),
                  onSave: () async {
                    await _saveSection(
                      c6h: double.tryParse(_cancel6hController.text),
                      c3h: double.tryParse(_cancel3hController.text),
                      c1h: double.tryParse(_cancel1hController.text),
                    );
                    setState(() => _isEditingCancellation = false);
                  },
                  children: [
                    const Text(
                      'Penalty percentages based on cancellation time before shift start.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceM),
                    _buildInputField('6 Hours Before (%)', _cancel6hController, _isEditingCancellation),
                    _buildInputField('3 Hours Before (%)', _cancel3hController, _isEditingCancellation),
                    _buildInputField('1 Hour Before (%)', _cancel1hController, _isEditingCancellation),
                  ],
                ),
                const SizedBox(height: ShiftleyTokens.spaceXL),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildConfigCard({
    required String title, 
    required List<Widget> children,
    required bool isEditing,
    required VoidCallback onEditToggle,
    required VoidCallback onSave,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ShiftleyTokens.h2),
                const SizedBox(height: ShiftleyTokens.spaceL),
                ...children,
              ],
            ),
          ),
          if (!isEditing)
            _buildFullWidthButton(
              text: 'EDIT',
              onPressed: onEditToggle,
              color: ShiftleyTokens.inkBlack,
              textColor: ShiftleyTokens.paperWhite,
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildFullWidthButton(
                    text: 'CANCEL',
                    onPressed: onEditToggle,
                    color: ShiftleyTokens.primaryRed,
                    textColor: ShiftleyTokens.paperWhite,
                    hasRightBorder: true,
                  ),
                ),
                Expanded(
                  child: _buildFullWidthButton(
                    text: 'SAVE',
                    onPressed: onSave,
                    color: ShiftleyTokens.secondaryCyan,
                    textColor: ShiftleyTokens.inkBlack,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFullWidthButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
    bool hasRightBorder = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: Border(
            top: ShiftleyTokens.primaryBorderSide,
            right: hasRightBorder ? ShiftleyTokens.primaryBorderSide : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: ShiftleyTokens.buttonLabel.copyWith(
            color: textColor,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.inkBlack)),
          const SizedBox(height: ShiftleyTokens.spaceS),
          TextField(
            controller: controller,
            enabled: isEnabled,
            keyboardType: TextInputType.number,
            style: ShiftleyTokens.bodyMedium.copyWith(
              color: ShiftleyTokens.inkBlack,
              fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w400,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: ShiftleyTokens.paperWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: ShiftleyTokens.primaryBorderSide,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: ShiftleyTokens.primaryBorderSide,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: ShiftleyTokens.thinBorderSide.copyWith(color: ShiftleyTokens.inkBlack.withAlpha(128)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: ShiftleyTokens.focusBorderSide,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: ShiftleyTokens.spaceS),
            ),
          ),
        ],
      ),
    );
  }
}
