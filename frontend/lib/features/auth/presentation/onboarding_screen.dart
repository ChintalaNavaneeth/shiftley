import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';
import 'package:shiftley_frontend/features/auth/data/auth_repository_provider.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';
import '../domain/models/auth_models.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final String role; // 'WORKER' or 'EMPLOYER'
  final String phoneNumber;

  const OnboardingScreen({super.key, required this.role, required this.phoneNumber});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // ── Common Fields ───────────────────────────────────────────
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  late final TextEditingController _phoneController;
  
  // ── Worker Fields ────────────────────────────────────────────
  final _degreeController = TextEditingController();
  final _specializationController = TextEditingController();
  final _passingYearController = TextEditingController();
  List<Category> _taxonomy = [];
  final List<String> _selectedSkillIds = [];
  XFile? _profilePicture;
  String? _workerAadhaarPath;
  String? _workerAadhaarName;

  // ── Employer Fields ──────────────────────────────────────────
  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _aadhaarNumberController = TextEditingController();
  String? _employerAadhaarPath;
  String? _employerAadhaarName;
  final List<XFile?> _businessPhotos = [null, null, null];

  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _fetchTaxonomy();
  }

  Future<void> _fetchTaxonomy() async {
    if (widget.role == 'WORKER') {
      try {
        final categories = await ref.read(authRepositoryProvider).getTaxonomy();
        setState(() => _taxonomy = categories);
      } catch (e) {
        debugPrint('Taxonomy Fetch Error: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _degreeController.dispose();
    _specializationController.dispose();
    _passingYearController.dispose();
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _businessAddressController.dispose();
    _gstNumberController.dispose();
    _businessPhoneController.dispose();
    _aadhaarNumberController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────
  
  Future<void> _pickImage(int index, {bool isProfile = false}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isProfile) {
          _profilePicture = image;
        } else {
          _businessPhotos[index] = image;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        if (widget.role == 'WORKER') {
          _workerAadhaarName = result.files.single.name;
          _workerAadhaarPath = result.files.single.path;
        } else {
          _employerAadhaarName = result.files.single.name;
          _employerAadhaarPath = result.files.single.path;
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permission denied';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() => _currentPosition = position);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final AuthResponse response;
      if (widget.role == 'WORKER') {
        response = await _submitWorker();
      } else {
        response = await _submitEmployer();
      }
      
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;
        
        if (accessToken != null && refreshToken != null) {
          final storage = ref.read(tokenStorageProvider);
          await storage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
      }

      if (mounted) {
        context.go(widget.role == 'WORKER' ? '/employee' : '/employer');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<AuthResponse> _submitWorker() async {
    final formData = FormData.fromMap({
      'full_name': _fullNameController.text,
      'email': _emailController.text,
      'phone_number': _phoneController.text,
      'skill_ids': jsonEncode(_selectedSkillIds),
      'degree': _degreeController.text,
      'specialization': _specializationController.text,
      'passing_year': _passingYearController.text,
      'location': jsonEncode({'lat': _currentPosition?.latitude, 'lng': _currentPosition?.longitude}),
      'profile_picture': await MultipartFile.fromFile(_profilePicture!.path),
      'aadhaar_pdf': await MultipartFile.fromFile(_workerAadhaarPath!),
    });
    return await ref.read(authRepositoryProvider).completeEmployeeOnboarding(formData);
  }

  Future<AuthResponse> _submitEmployer() async {
    final formData = FormData.fromMap({
      'full_name': _fullNameController.text,
      'email': _emailController.text,
      'business_name': _businessNameController.text,
      'business_type': _businessTypeController.text,
      'location': jsonEncode({'lat': _currentPosition?.latitude, 'lng': _currentPosition?.longitude}),
      'business_address': _businessAddressController.text,
      'gst_number': _gstNumberController.text,
      'business_phone_number': _businessPhoneController.text,
      'employer_phone_number': _phoneController.text,
      'aadhaar_number': _aadhaarNumberController.text,
      'aadhaar_pdf': await MultipartFile.fromFile(_employerAadhaarPath!),
      'business_photo_1': await MultipartFile.fromFile(_businessPhotos[0]!.path),
      'business_photo_2': await MultipartFile.fromFile(_businessPhotos[1]!.path),
      'business_photo_3': await MultipartFile.fromFile(_businessPhotos[2]!.path),
    });
    return await ref.read(authRepositoryProvider).completeEmployerOnboarding(formData);
  }

  // ── Build Methods ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftleyTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shiftley.', style: ShiftleyTokens.h1),
              Text('STEP ${_currentStep + 1} OF 3', style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: ShiftleyTokens.utilityGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(ShiftleyTokens.primaryRed),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Details', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildTextField('Full Name', _fullNameController, hint: 'As per Aadhaar'),
          _buildTextField('Email Address', _emailController, hint: 'name@example.com'),
          _buildTextField('Phone Number', _phoneController, hint: '+91', enabled: false),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    if (widget.role == 'WORKER') {
      return _buildWorkerStep2();
    } else {
      return _buildEmployerStep2();
    }
  }

  Widget _buildWorkerStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skills & Education', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          const Text('Select your skills', style: ShiftleyTokens.bodyLarge),
          const SizedBox(height: ShiftleyTokens.spaceM),
          ..._taxonomy.map((cat) => _buildCategorySection(cat)),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildTextField('Highest Degree', _degreeController),
          _buildTextField('Specialization', _specializationController),
          _buildTextField('Passing Year', _passingYearController, keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildCategorySection(Category cat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cat.name, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: ShiftleyTokens.spaceS),
        Wrap(
          spacing: 8,
          children: cat.skills.map((skill) {
            final isSelected = _selectedSkillIds.contains(skill.id);
            return ChoiceChip(
              label: Text(skill.name, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black)),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedSkillIds.add(skill.id);
                  } else {
                    _selectedSkillIds.remove(skill.id);
                  }
                });
              },
              selectedColor: ShiftleyTokens.inkBlack,
              backgroundColor: ShiftleyTokens.paperWhite,
              shape: const RoundedRectangleBorder(side: BorderSide(color: ShiftleyTokens.inkBlack)),
            );
          }).toList(),
        ),
        const SizedBox(height: ShiftleyTokens.spaceM),
      ],
    );
  }

  Widget _buildEmployerStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Business Information', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildTextField('Business Name', _businessNameController),
          _buildTextField('Business Type', _businessTypeController, hint: 'e.g. Restaurant, Retail'),
          _buildTextField('Business Phone', _businessPhoneController),
          _buildTextField('Business Address', _businessAddressController, maxLines: 3),
          _buildTextField('GST Number (Optional)', _gstNumberController),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Verification Documents', style: ShiftleyTokens.h2),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          
          if (widget.role == 'WORKER') ...[
             _buildImageUpload('Profile Picture', _profilePicture, () => _pickImage(0, isProfile: true)),
             const SizedBox(height: ShiftleyTokens.spaceL),
             _buildFileUpload('Aadhaar Card (Masked PDF)', _workerAadhaarName, _pickFile),
          ] else ...[
             _buildTextField('Aadhaar Number', _aadhaarNumberController),
             _buildFileUpload('Aadhaar Card (Masked PDF)', _employerAadhaarName, _pickFile),
             const SizedBox(height: ShiftleyTokens.spaceL),
             const Text('Business Photos (3 required)', style: ShiftleyTokens.bodyLarge),
             const SizedBox(height: ShiftleyTokens.spaceM),
             Row(
               children: List.generate(3, (i) => Expanded(child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 4),
                 child: _buildImageUpload('', _businessPhotos[i], () => _pickImage(i)),
               ))),
             ),
          ],

          const SizedBox(height: ShiftleyTokens.spaceXL),
          const Text('Base Location', style: ShiftleyTokens.bodyLarge),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Container(
            padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
            decoration: BoxDecoration(
              color: ShiftleyTokens.paperWhite,
              border: ShiftleyTokens.primaryBorder,
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: ShiftleyTokens.primaryRed),
                const SizedBox(width: ShiftleyTokens.spaceM),
                Expanded(child: Text(_currentPosition != null ? 'Location Captured' : 'Not Captured')),
                TextButton(onPressed: _getCurrentLocation, child: const Text('CAPTURE')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      decoration: const BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: Border(top: BorderSide(color: ShiftleyTokens.inkBlack, width: 2)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ShiftleyButton(label: 'BACK', isPrimary: false, onPressed: _prevStep),
              ),
            ),
          Expanded(
            flex: 2,
            child: SButton(
              text: _currentStep == 2 ? 'COMPLETE SETUP' : 'NEXT STEP',
              isLoading: _isLoading,
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, int maxLines = 1, bool enabled = true, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: ShiftleyTokens.primaryInputBorder,
              enabledBorder: ShiftleyTokens.primaryInputBorder,
              focusedBorder: ShiftleyTokens.focusInputBorder,
              filled: true,
              fillColor: enabled ? Colors.white : ShiftleyTokens.utilityGrey.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUpload(String label, XFile? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: ShiftleyTokens.paperWhite,
              border: ShiftleyTokens.primaryBorder,
              image: image != null ? DecorationImage(image: FileImage(File(image.path)), fit: BoxFit.cover) : null,
            ),
            child: image == null ? const Center(child: Icon(Icons.add_a_photo_outlined)) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(String label, String? fileName, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
            decoration: BoxDecoration(
              color: ShiftleyTokens.paperWhite,
              border: ShiftleyTokens.primaryBorder,
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf_outlined, color: ShiftleyTokens.primaryRed),
                const SizedBox(width: ShiftleyTokens.spaceM),
                Expanded(child: Text(fileName ?? 'Select PDF')),
                const Icon(Icons.attach_file),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
