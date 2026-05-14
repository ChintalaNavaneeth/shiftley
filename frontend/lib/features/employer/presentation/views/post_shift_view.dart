import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/features/employer/data/employer_repository.dart';
import 'package:shiftley_frontend/features/employer/domain/models/taxonomy_models.dart';
import 'package:shiftley_frontend/shared/widgets/s_dropdown.dart';
import 'package:shiftley_frontend/shared/widgets/s_text_field.dart';
import 'package:uuid/uuid.dart';

class PostGigView extends ConsumerStatefulWidget {
  final VoidCallback? onPublished;
  const PostGigView({super.key, this.onPublished});

  @override
  ConsumerState<PostGigView> createState() => _PostGigViewState();
}

class _PostGigViewState extends ConsumerState<PostGigView> {
  int _currentStep = 1;
  final int _totalSteps = 4;
  late final PageController _pageController;

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _workersController = TextEditingController(text: '1');
  final TextEditingController _payController = TextEditingController(text: '500');
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // Taxonomy selections — category is locked from employer profile, user only picks skill
  TaxonomyCategory? _lockedCategory;
  TaxonomySkill? _selectedSkill;
  String _payType = 'PER_DAY';

  double _totalAmount = 500.0;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  bool _isSavedDraft = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _workersController.addListener(_calculateTotal);
    _payController.addListener(_calculateTotal);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveLockedCategory());
  }

  void _resolveLockedCategory() {
    final taxonomy = ref.read(taxonomyProvider).asData?.value;
    final dashboard = ref.read(employerDashboardProvider).asData?.value;
    if (taxonomy == null || dashboard == null) return;
    
    // Match employer's business_type name to a taxonomy category
    final businessType = dashboard.profile.businessType.toLowerCase().trim();
    final match = taxonomy.where((c) =>
      c.name.toLowerCase().trim() == businessType ||
      c.id == businessType, // also match by ID if stored as UUID
    );
    if (match.isNotEmpty) {
      setState(() => _lockedCategory = match.first);
    } else if (taxonomy.isNotEmpty) {
      // Fallback: use first category if no match
      setState(() => _lockedCategory = taxonomy.first);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _workersController.dispose();
    _payController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final workers = int.tryParse(_workersController.text) ?? 0;
    final pay = double.tryParse(_payController.text) ?? 0;
    setState(() => _totalAmount = (workers * pay).toDouble());
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _showGigPaymentModal();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Shows a scrollable drum-style time picker bottom sheet.
  Future<void> _showDrumTimePicker(TextEditingController controller, {String initial = '09:00 AM'}) async {
    // Parse initial values
    int initHour = 9;
    int initMinute = 0;
    bool initIsPm = false;
    final existing = controller.text.isNotEmpty ? controller.text : initial;
    try {
      final parts = existing.split(' ');
      final hm = parts[0].split(':');
      initHour = int.parse(hm[0]);
      initMinute = int.parse(hm[1]);
      initIsPm = parts.length > 1 && parts[1].toUpperCase() == 'PM';
    } catch (_) {}

    final hours = List.generate(12, (i) => (i + 1)); // 1–12
    final minutes = [0, 15, 30, 45];
    final periods = ['AM', 'PM'];

    int selHour = initHour > 12 ? initHour - 12 : (initHour == 0 ? 12 : initHour);
    int selMinuteIdx = minutes.indexWhere((m) => m >= initMinute).clamp(0, 3);
    int selPeriodIdx = initIsPm ? 1 : 0;

    final hourCtrl = FixedExtentScrollController(initialItem: selHour - 1);
    final minCtrl = FixedExtentScrollController(initialItem: selMinuteIdx);
    final ampmCtrl = FixedExtentScrollController(initialItem: selPeriodIdx);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          height: 300,
          decoration: const BoxDecoration(
            color: ShiftleyTokens.paperWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: ShiftleyTokens.mutedText)),
                    ),
                    const Text('Select Time', style: ShiftleyTokens.h2),
                    TextButton(
                      onPressed: () {
                        final h = hours[hourCtrl.selectedItem];
                        final m = minutes[minCtrl.selectedItem];
                        final ampm = periods[ampmCtrl.selectedItem];
                        setState(() => controller.text =
                            '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ampm');
                        Navigator.pop(ctx);
                      },
                      child: const Text('Done', style: TextStyle(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Highlight band
                    Container(
                      height: 46,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: ShiftleyTokens.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ShiftleyTokens.inkBlack.withValues(alpha: 0.1)),
                      ),
                    ),
                    Row(
                      children: [
                        // Hour drum
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: hourCtrl,
                            itemExtent: 46,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (_) {},
                            childDelegate: ListWheelChildListDelegate(
                              children: hours.map((h) => Center(
                                child: Text(
                                  h.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                        const Text(':', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        // Minute drum
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: minCtrl,
                            itemExtent: 46,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (_) {},
                            childDelegate: ListWheelChildListDelegate(
                              children: minutes.map((m) => Center(
                                child: Text(
                                  m.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                        // AM/PM drum
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: ampmCtrl,
                            itemExtent: 46,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (_) {},
                            childDelegate: ListWheelChildListDelegate(
                              children: periods.map((p) => Center(
                                child: Text(
                                  p,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: p == 'PM' ? ShiftleyTokens.primaryRed : ShiftleyTokens.inkBlack,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _parseTimeToISO(String dateStr, String timeStr) {
    try {
      final timeParts = timeStr.split(' ');
      final hm = timeParts[0].split(':');
      final isPM = timeParts.length > 1 && timeParts[1].toUpperCase() == 'PM';
      int h = int.parse(hm[0]);
      final m = int.parse(hm[1]);
      if (isPM && h != 12) h += 12;
      if (!isPM && h == 12) h = 0;
      return '${dateStr}T${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:00Z';
    } catch (_) {
      return '${dateStr}T09:00:00Z';
    }
  }

  /// Validates form fields. Returns gigData map or null on error.
  Map<String, dynamic>? _buildGigData() {
    if (_lockedCategory == null) {
      _showError('Business category could not be resolved. Please try again.');
      return null;
    }
    if (_selectedSkill == null) {
      _showError('Please select a specific role/skill');
      return null;
    }
    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a gig title');
      return null;
    }
    if (_dateController.text.isEmpty) {
      _showError('Please select a gig date');
      return null;
    }
    final dateStr = _dateController.text;
    final startISO = _startTimeController.text.isNotEmpty
        ? _parseTimeToISO(dateStr, _startTimeController.text)
        : '${dateStr}T09:00:00Z';
    final endISO = _endTimeController.text.isNotEmpty
        ? _parseTimeToISO(dateStr, _endTimeController.text)
        : '${dateStr}T17:00:00Z';
    final wageInPaise = (double.tryParse(_payController.text) ?? 500) * 100;
    return {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : 'No description provided.',
      'category_id': _lockedCategory!.id,
      'skill_id': _selectedSkill!.id,
      'workers_needed': int.tryParse(_workersController.text) ?? 1,
      'wage_per_worker': wageInPaise.toInt(),
      'start_time': startISO,
      'end_time': endISO,
      'pay_type': _payType,
    };
  }

  /// Shows the payment bottom sheet. On success, creates gig → confirms payment → goes OPEN.
  void _showGigPaymentModal() {
    final gigData = _buildGigData();
    if (gigData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GigPaymentModal(
        gigTitle: _titleController.text.trim(),
        totalAmount: _totalAmount,
        workers: int.tryParse(_workersController.text) ?? 1,
        onSuccess: (paymentId) async {
          Navigator.pop(ctx);
          setState(() => _isSubmitting = true);
          try {
            final repo = ref.read(employerRepositoryProvider);
            final idempotencyKey = const Uuid().v4();
            final response = await repo.postGigRaw(gigData, idempotencyKey);
            final gigId = response['gig_id']?.toString() ?? '';
            if (gigId.isEmpty) throw Exception('Invalid gig ID returned from server');

            // Confirm payment → moves gig DRAFT → OPEN
            await repo.confirmGigPayment(gigId);

            ref.invalidate(employerGigsProvider('OPEN'));
            ref.invalidate(employerGigsProvider('ACTIVE'));
            ref.invalidate(employerGigsProvider(null));
            ref.invalidate(employerDashboardProvider);

            if (mounted) setState(() { _isSubmitting = false; _isSuccess = true; _isSavedDraft = false; });
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) widget.onPublished?.call();
            });
          } catch (e) {
            if (!mounted) return;
            setState(() => _isSubmitting = false);
            _showError(e.toString());
          }
        },
        onSaveAsDraft: () {
          Navigator.pop(ctx);
          _saveDraft(gigData);
        },
      ),
    );
  }

  /// Saves the gig as a DRAFT (no payment confirmation).
  Future<void> _saveDraft(Map<String, dynamic> gigData) async {
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(employerRepositoryProvider);
      final idempotencyKey = const Uuid().v4();
      await repo.postGigRaw(gigData, idempotencyKey);

      ref.invalidate(employerGigsProvider(null));
      ref.invalidate(employerDashboardProvider);

      if (mounted) setState(() { _isSubmitting = false; _isSuccess = true; _isSavedDraft = true; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ShiftleyTokens.primaryRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccess();
    if (_isSubmitting) return _buildLoading();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceL),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep of $_totalSteps',
                style: ShiftleyTokens.caption.copyWith(
                  color: ShiftleyTokens.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildProgressBar(),
            ],
          ),
        ),

        // PageView for smooth slide transitions
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // navigation via buttons only
            children: [
              SingleChildScrollView(padding: const EdgeInsets.only(bottom: 16), child: _buildStep1()),
              SingleChildScrollView(padding: const EdgeInsets.only(bottom: 16), child: _buildStep2()),
              SingleChildScrollView(padding: const EdgeInsets.only(bottom: 16), child: _buildStep3()),
              SingleChildScrollView(padding: const EdgeInsets.only(bottom: 16), child: _buildStep4()),
            ],
          ),
        ),

        // Navigation buttons pinned at bottom
        const SizedBox(height: ShiftleyTokens.spaceM),
        Row(
          children: [
            if (_currentStep > 1)
              Expanded(
                child: ShiftleyButton(
                  label: 'Back',
                  onPressed: _prevStep,
                  isPrimary: false,
                ),
              ),
            if (_currentStep > 1) const SizedBox(width: ShiftleyTokens.spaceM),
            Expanded(
              child: ShiftleyButton(
                label: _currentStep == _totalSteps ? 'PROCEED TO PAY' : 'Next Step',
                icon: _currentStep == _totalSteps ? Icons.payment : null,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
        if (_currentStep == _totalSteps) ...[
          const SizedBox(height: ShiftleyTokens.spaceM),
          ShiftleyButton(
            label: 'Save as Draft',
            icon: Icons.save_outlined,
            onPressed: () {
              final gigData = _buildGigData();
              if (gigData != null) _saveDraft(gigData);
            },
            isPrimary: false,
            isFullWidth: true,
          ),
        ],
        const SizedBox(height: ShiftleyTokens.spaceS),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: 150,
      height: 8,
      decoration: BoxDecoration(
        color: ShiftleyTokens.background,
        border: Border.all(color: ShiftleyTokens.inkBlack, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _currentStep / _totalSteps,
        child: Container(
          decoration: BoxDecoration(
            color: ShiftleyTokens.primaryRed,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // STEP 1: Skill Selection (category locked from profile)
  // ──────────────────────────────────────────
  Widget _buildStep1() {
    final taxonomyAsync = ref.watch(taxonomyProvider);
    final dashboardAsync = ref.watch(employerDashboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What role do you need?', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceS),
        const Text('Your business category is fixed. Select the specific role for this GIG.', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        taxonomyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed)),
          error: (err, _) => Center(child: Text('Failed to load taxonomy: $err')),
          data: (categories) {
            // Resolve locked category if not done yet
            if (_lockedCategory == null) {
              final dashboard = dashboardAsync.asData?.value;
              if (dashboard != null) {
                final businessType = dashboard.profile.businessType.toLowerCase().trim();
                final match = categories.where((c) =>
                  c.name.toLowerCase().trim() == businessType || c.id == businessType);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _lockedCategory = match.isNotEmpty ? match.first : (categories.isNotEmpty ? categories.first : null));
                });
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Locked Category Badge
                _buildLabel('Business Category (from your profile)'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceL, vertical: ShiftleyTokens.spaceM),
                  decoration: BoxDecoration(
                    color: ShiftleyTokens.inkBlack,
                    borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: Colors.white60, size: 16),
                      const SizedBox(width: ShiftleyTokens.spaceS),
                      Text(
                        _lockedCategory?.name ?? 'Loading...',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ShiftleyTokens.spaceXL),

                // Skill Dropdown (filtered to locked category)
                if (_lockedCategory != null) ...[
                  _buildLabel('Specific Role / Skill *'),
                  SDropdown<TaxonomySkill>(
                    value: _selectedSkill,
                    hint: 'Select a role',
                    items: _lockedCategory!.skills
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedSkill = val),
                  ),
                ] else
                  const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed)),

                const SizedBox(height: ShiftleyTokens.spaceXL),
                _buildLabel('GIG Title *'),
                STextField(
                  hint: 'e.g. Waiter for Saturday Banquet',
                  controller: _titleController,
                ),
                const SizedBox(height: ShiftleyTokens.spaceL),
                _buildLabel('Description (optional)'),
                STextField(
                  hint: 'Describe what the worker will be doing...',
                  controller: _descController,
                  maxLines: 4,
                  maxLength: 500,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // STEP 2: Date & Time
  // ──────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('When is the GIG?', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceS),
        const Text('Set the date and shift timings.', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        _buildLabel('GIG Date'),
        STextField(
          hint: 'Select Date',
          controller: _dateController,
          readOnly: true,
          prefix: const Icon(Icons.calendar_today, size: 20),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _dateController.text =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
            }
          },
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Start Time'),
                  GestureDetector(
                    onTap: () => _showDrumTimePicker(_startTimeController, initial: '09:00 AM'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: ShiftleyTokens.paperWhite,
                        border: ShiftleyTokens.primaryBorder,
                        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, size: 18, color: ShiftleyTokens.mutedText),
                          const SizedBox(width: 8),
                          Text(
                            _startTimeController.text.isEmpty ? '09:00 AM' : _startTimeController.text,
                            style: TextStyle(
                              color: _startTimeController.text.isEmpty ? ShiftleyTokens.mutedText : ShiftleyTokens.inkBlack,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ShiftleyTokens.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('End Time'),
                  GestureDetector(
                    onTap: () => _showDrumTimePicker(_endTimeController, initial: '05:00 PM'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: ShiftleyTokens.paperWhite,
                        border: ShiftleyTokens.primaryBorder,
                        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, size: 18, color: ShiftleyTokens.mutedText),
                          const SizedBox(width: 8),
                          Text(
                            _endTimeController.text.isEmpty ? '05:00 PM' : _endTimeController.text,
                            style: TextStyle(
                              color: _endTimeController.text.isEmpty ? ShiftleyTokens.mutedText : ShiftleyTokens.inkBlack,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // STEP 3: Workers & Pay
  // ──────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pay & Workers', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceS),
        const Text('How many workers and how much will they earn?', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Workers Needed'),
                  STextField(
                    hint: '1',
                    controller: _workersController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: ShiftleyTokens.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Pay per Person (₹)'),
                  STextField(
                    hint: '500',
                    controller: _payController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        _buildLabel('Pay Type'),
        Row(
          children: [
            Expanded(
              child: _buildPayTypeChip('PER_DAY', 'Per Day'),
            ),
            const SizedBox(width: ShiftleyTokens.spaceM),
            Expanded(
              child: _buildPayTypeChip('PER_HOUR', 'Per Hour'),
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
          decoration: BoxDecoration(
            color: ShiftleyTokens.inkBlack,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL PAYOUT', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w900)),
                  Text(
                    '₹ ${_totalAmount.toStringAsFixed(0)}',
                    style: ShiftleyTokens.h1.copyWith(color: ShiftleyTokens.secondaryCyan),
                  ),
                ],
              ),
              Text(
                '${_workersController.text} worker${(int.tryParse(_workersController.text) ?? 1) > 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayTypeChip(String value, String label) {
    final isSelected = _payType == value;
    return GestureDetector(
      onTap: () => setState(() => _payType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceM),
        decoration: BoxDecoration(
          color: isSelected ? ShiftleyTokens.inkBlack : ShiftleyTokens.paperWhite,
          border: Border.all(color: ShiftleyTokens.inkBlack, width: 2),
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : ShiftleyTokens.inkBlack,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // STEP 4: Review & Confirm
  // ──────────────────────────────────────────
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review & Publish', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceS),
        const Text('Double check everything before publishing.', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),

        _buildReviewItem('Category', _lockedCategory?.name ?? '—'),
        _buildReviewItem('Skill / Role', _selectedSkill?.name ?? '—'),
        _buildReviewItem('Title', _titleController.text.isEmpty ? '—' : _titleController.text),
        _buildReviewItem('Date', _dateController.text.isEmpty ? '—' : _dateController.text),
        _buildReviewItem(
          'Shift Hours',
          '${_startTimeController.text.isEmpty ? '09:00 AM' : _startTimeController.text}'
          ' → '
          '${_endTimeController.text.isEmpty ? '05:00 PM' : _endTimeController.text}',
        ),
        _buildReviewItem('Workers Needed', _workersController.text),
        _buildReviewItem('Pay per Worker', '₹ ${_payController.text} (${_payType == 'PER_DAY' ? 'Per Day' : 'Per Hour'})'),
        const SizedBox(height: ShiftleyTokens.spaceL),
        Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
          decoration: BoxDecoration(
            color: ShiftleyTokens.inkBlack,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PAYOUT', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w900)),
              Text('₹ ${_totalAmount.toStringAsFixed(0)}', style: ShiftleyTokens.h1.copyWith(color: ShiftleyTokens.secondaryCyan)),
            ],
          ),
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            border: Border.all(color: Colors.orange, width: 1.5),
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: Text(
                  'Your location from your business profile will be used as the shift location.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    if (_isSavedDraft) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange, width: 3),
            ),
            child: const Icon(Icons.save_outlined, size: 80, color: Colors.orange),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
          const Text('Saved as Draft!', style: ShiftleyTokens.h1),
          const SizedBox(height: ShiftleyTokens.spaceM),
          const Text(
            'Your GIG has been saved as a draft. You can find it in the Manage GIGs tab and publish it later when ready.',
            textAlign: TextAlign.center,
            style: ShiftleyTokens.bodyMedium,
          ),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
          ShiftleyButton(
            label: 'VIEW MY DRAFTS',
            onPressed: () => widget.onPublished?.call(),
            isFullWidth: true,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 3),
          ),
          child: const Icon(Icons.check_circle, size: 80, color: Colors.green),
        ),
        const SizedBox(height: ShiftleyTokens.spaceXXL),
        const Text('GIG Published!', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceM),
        const Text(
          'Your GIG is now live and visible to workers in the area.',
          textAlign: TextAlign.center,
          style: ShiftleyTokens.bodyMedium,
        ),
        const SizedBox(height: ShiftleyTokens.spaceXXL),
        ShiftleyButton(
          label: 'VIEW MY GIGS',
          onPressed: () => widget.onPublished?.call(),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ShiftleyTokens.primaryRed),
          SizedBox(height: ShiftleyTokens.spaceXL),
          Text('Publishing your GIG...', style: ShiftleyTokens.bodyLarge),
          SizedBox(height: ShiftleyTokens.spaceM),
          Text('Confirming escrow and making it live.', style: ShiftleyTokens.caption),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold, color: ShiftleyTokens.inkBlack),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.caption),
          Text(value, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          const Divider(color: ShiftleyTokens.background, thickness: 1.5),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// GIG PAYMENT MODAL
// ──────────────────────────────────────────
class _GigPaymentModal extends StatelessWidget {
  final String gigTitle;
  final double totalAmount;
  final int workers;
  final Function(String paymentId) onSuccess;
  final VoidCallback onSaveAsDraft;

  const _GigPaymentModal({
    required this.gigTitle,
    required this.totalAmount,
    required this.workers,
    required this.onSuccess,
    required this.onSaveAsDraft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header — Razorpay-style dark bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF02042B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(Icons.payment, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RAZORPAY',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13),
                      ),
                      Text(
                        'Escrow for: $gigTitle',
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Amount Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            color: const Color(0xFF02042B),
            child: Column(
              children: [
                const Text('TOTAL ESCROW AMOUNT', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  '₹ ${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$workers worker${workers > 1 ? 's' : ''} • Held in secure escrow until GIG completes',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          // Payment Methods
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Pay via', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 12),
                _buildMethod(context, Icons.qr_code_2, 'UPI', 'Google Pay, PhonePe, Paytm'),
                _buildMethod(context, Icons.credit_card, 'Card', 'Visa, Mastercard, RuPay'),
                _buildMethod(context, Icons.account_balance, 'Netbanking', 'All major banks supported'),
                _buildMethod(context, Icons.wallet, 'Wallet', 'Paytm, Mobikwik, etc.'),
                const SizedBox(height: 8),
                const Center(
                  child: Text('TEST MODE — No real payment charged', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lock_outline, size: 18, color: Colors.white),
                    label: Text('PAY ₹ ${totalAmount.toStringAsFixed(0)} SECURELY', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ShiftleyTokens.primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
                    ),
                    onPressed: () => onSuccess('pay_mock_${DateTime.now().millisecondsSinceEpoch}'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  icon: const Icon(Icons.save_outlined, size: 16, color: ShiftleyTokens.mutedText),
                  label: const Text('Save as Draft instead', style: TextStyle(color: ShiftleyTokens.mutedText, fontSize: 13)),
                  onPressed: onSaveAsDraft,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethod(BuildContext context, IconData icon, String label, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        onTap: () => onSuccess('pay_mock_${DateTime.now().millisecondsSinceEpoch}'),
      ),
    );
  }
}
