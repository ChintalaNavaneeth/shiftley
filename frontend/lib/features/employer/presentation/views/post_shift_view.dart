import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/shared/widgets/s_text_field.dart';
import 'package:shiftley_frontend/shared/widgets/s_dropdown.dart';

class PostGigView extends StatefulWidget {
  final VoidCallback? onPublished;
  const PostGigView({super.key, this.onPublished});

  @override
  State<PostGigView> createState() => _PostGigViewState();
}

class _PostGigViewState extends State<PostGigView> {
  int _currentStep = 1;
  final int _totalSteps = 5;
  final PageController _pageController = PageController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _workersController = TextEditingController(text: '1');
  final TextEditingController _payController = TextEditingController(text: '500');
  final TextEditingController _addressController = TextEditingController(text: 'Taj Banjara, Road No. 1, Banjara Hills, Hyderabad, Telangana 500034');
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(text: 'Hospitality');

  final String _selectedCategory = 'Hospitality';
  String? _selectedSubCategory;

  final Map<String, List<String>> _categories = {
    'Hospitality': ['Waitstaff', 'Housekeeping', 'Kitchen Assistant', 'Bell Desk'],
    'Logistics': ['Delivery Partner', 'Warehouse Associate', 'Picker/Packer'],
    'Retail': ['Sales Associate', 'Cashier', 'Inventory Staff'],
  };

  double _totalAmount = 500.0;
  bool _isPaymentProcessing = false;
  bool _isPaymentSuccess = false;

  @override
  void initState() {
    super.initState();
    _workersController.addListener(_calculateTotal);
    _payController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final workers = int.tryParse(_workersController.text) ?? 0;
    final pay = double.tryParse(_payController.text) ?? 0;
    setState(() {
      _totalAmount = (workers * pay).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isPaymentSuccess) {
      return _buildSuccessState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuotaStats(),
        const SizedBox(height: ShiftleyTokens.spaceL),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step $_currentStep of $_totalSteps', 
              style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold)),
            _buildProgressBar(),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStepWrapper(_buildStep1()),
              _buildStepWrapper(_buildStep2()),
              _buildStepWrapper(_buildStep3()),
              _buildStepWrapper(_buildStep4()),
              _buildStepWrapper(_buildStep5()),
            ],
          ),
        ),

        const SizedBox(height: ShiftleyTokens.spaceL),
        if (!_isPaymentProcessing)
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
                  label: _currentStep == _totalSteps ? 'Proceed to Pay' : 'Next Step',
                  onPressed: _nextStep,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStepWrapper(Widget child) {
    return SingleChildScrollView(
      child: child,
    );
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input, // Force digital input
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: ShiftleyTokens.primaryRed,
              onPrimary: Colors.white,
              surface: ShiftleyTokens.paperWhite,
              onSurface: ShiftleyTokens.inkBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _startMockPayment();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _startMockPayment() async {
    setState(() => _isPaymentProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isPaymentProcessing = false;
      _isPaymentSuccess = true;
    });
    
    // Auto-navigate after a brief delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && widget.onPublished != null) {
        widget.onPublished!();
      }
    });
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
        child: Container(color: ShiftleyTokens.primaryRed),
      ),
    );
  }

  Widget _buildQuotaStats() {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('POSTED SO FAR', '38'),
          Container(width: 2, height: 30, color: ShiftleyTokens.background),
          _buildStatItem('GIGS LEFT', '12'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.mutedText)),
        Text(value, style: ShiftleyTokens.h2.copyWith(color: ShiftleyTokens.primaryRed)),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('General Info', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceM),
        const Text('Specify the GIG details and categories.', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        _buildLabel('GIG Title'),
        STextField(hint: 'e.g. Waiter for Banquet Event', controller: _titleController),
        const SizedBox(height: ShiftleyTokens.spaceL),
        _buildLabel('Category'),
        STextField(
          hint: 'Hospitality', 
          controller: _categoryController, 
          readOnly: true,
          prefix: const Icon(Icons.category_outlined, size: 20),
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        _buildLabel('Sub-Category'),
        SDropdown<String>(
          value: _selectedSubCategory,
          hint: 'Select Sub-Category',
          items: [
            ..._categories[_selectedCategory]!.map((sc) => DropdownMenuItem(value: sc, child: Text(sc))),
            const DropdownMenuItem(
              value: 'REQUEST_NEW',
              child: Text('+ Request New...', style: TextStyle(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold)),
            ),
          ],
          onChanged: (val) {
            if (val == 'REQUEST_NEW') {
              _showRequestSubCategoryDialog();
            } else {
              setState(() => _selectedSubCategory = val);
            }
          },
        ),
        const SizedBox(height: ShiftleyTokens.spaceM),
        _buildLabel('Description'),
        STextField(
          hint: 'Describe the roles and responsibilities...', 
          controller: _descController, 
          maxLength: 500,
          maxLines: 5,
        ),
      ],
    );
  }

  void _showRequestSubCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShiftleyTokens.paperWhite,
        shape: RoundedRectangleBorder(
          side: ShiftleyTokens.primaryBorderSide,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        title: const Text('Request Sub-category', style: ShiftleyTokens.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Can\'t find what you\'re looking for? Suggest a new sub-category for your GIG.'),
            const SizedBox(height: ShiftleyTokens.spaceL),
            STextField(hint: 'Enter sub-category name', controller: TextEditingController()),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ShiftleyButton(label: 'Submit Request', onPressed: () => Navigator.pop(context), size: ShiftleyButtonSize.small),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date & Time', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceM),
        const Text('When do you need the professionals?', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        _buildLabel('GIG Date'),
        STextField(
          hint: 'Select Date', 
          controller: _dateController, 
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _dateController.text = "${date.day}/${date.month}/${date.year}");
            }
          },
          prefix: const Icon(Icons.calendar_today, size: 20),
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Start Time'),
                  STextField(
                    hint: '09:00 AM', 
                    controller: _startTimeController,
                    readOnly: true,
                    onTap: () => _selectTime(context, _startTimeController),
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
                  STextField(
                    hint: '05:00 PM', 
                    controller: _endTimeController,
                    readOnly: true,
                    onTap: () => _selectTime(context, _endTimeController),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location & Pay', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceM),
        const Text('Business location and compensation details.', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        _buildLabel('Business Location (Default)'),
        STextField(
          hint: 'Business Address', 
          controller: _addressController, 
          readOnly: true,
          prefix: const Icon(Icons.business_outlined, size: 20),
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Workers Needed'),
                  STextField(hint: 'Count', controller: _workersController, keyboardType: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(width: ShiftleyTokens.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Pay per Person (₹)'),
                  STextField(hint: 'Amount', controller: _payController, keyboardType: TextInputType.number),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
          decoration: BoxDecoration(
            color: ShiftleyTokens.inkBlack,
            border: ShiftleyTokens.primaryBorder,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PAYOUT', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 12)),
              Text('₹ ${_totalAmount.toStringAsFixed(0)}', style: ShiftleyTokens.h1.copyWith(color: ShiftleyTokens.secondaryCyan)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Review Summary', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceM),
        const Text('Double check everything before payment.', style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        _buildReviewItem('Title', _titleController.text.isEmpty ? 'Waitstaff' : _titleController.text),
        _buildReviewItem('Category', '$_selectedCategory / ${_selectedSubCategory ?? '---'}'),
        _buildReviewItem('Schedule', '${_dateController.text} | 09:00 AM - 05:00 PM'),
        _buildReviewItem('Location', 'Taj Banjara, Hyderabad'),
        _buildReviewItem('Total Payout', '₹ ${_totalAmount.toStringAsFixed(0)} for ${_workersController.text} Workers'),
        const SizedBox(height: ShiftleyTokens.spaceXL),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.payment_outlined, size: 80, color: ShiftleyTokens.primaryRed),
        const SizedBox(height: ShiftleyTokens.spaceL),
        const Text('Complete Payment', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceM),
        Text('Please complete the payment of ₹ ${_totalAmount.toStringAsFixed(0)} via Razorpay to publish this GIG.', 
          textAlign: TextAlign.center,
          style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXXL),
        if (_isPaymentProcessing)
          const CircularProgressIndicator(color: ShiftleyTokens.primaryRed),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green, width: 3),
          ),
          child: const Icon(Icons.check_circle, size: 100, color: Colors.green),
        ),
        const SizedBox(height: ShiftleyTokens.spaceXXL),
        const Text('GIG Published!', style: ShiftleyTokens.h1),
        const SizedBox(height: ShiftleyTokens.spaceM),
        const Text('Your GIG is now live and professionals can start applying.', 
          textAlign: TextAlign.center,
          style: ShiftleyTokens.bodyMedium),
        const SizedBox(height: ShiftleyTokens.spaceXXL),
        ShiftleyButton(
          label: 'Go to Manage GIGS',
          onPressed: () {
            if (widget.onPublished != null) {
              widget.onPublished!();
            }
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(text, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold, color: ShiftleyTokens.inkBlack)),
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
          const Divider(color: ShiftleyTokens.background, thickness: 1),
        ],
      ),
    );
  }
}
