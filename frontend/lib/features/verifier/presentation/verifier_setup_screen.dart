import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:shiftley_frontend/features/verifier/data/verifier_repository_provider.dart';

class VerifierSetupScreen extends ConsumerStatefulWidget {
  const VerifierSetupScreen({super.key});

  @override
  ConsumerState<VerifierSetupScreen> createState() => _VerifierSetupScreenState();
}

class _VerifierSetupScreenState extends ConsumerState<VerifierSetupScreen> {
  XFile? _profileImage;
  String? _aadharFileName;
  String? _aadharFilePath;
  Position? _currentPosition;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _aadharFileName = result.files.single.name;
        _aadharFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ShiftleyTokens.paperWhite,
            shape: const RoundedRectangleBorder(side: BorderSide(color: ShiftleyTokens.inkBlack, width: 2)),
            title: const Text('LOCATION DISABLED', style: ShiftleyTokens.h2),
            content: const Text('Location services are disabled on your device. Please enable them to continue.', style: ShiftleyTokens.bodyMedium),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL', style: TextStyle(color: ShiftleyTokens.inkBlack)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                },
                child: const Text('OPEN SETTINGS', style: TextStyle(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      setState(() => _currentPosition = position);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location captured successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('Location Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture location: $e'), backgroundColor: ShiftleyTokens.primaryRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submit() async {
    if (_profileImage == null || _aadharFilePath == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all verification steps (Photo, Aadhar, and Location).')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(verifierRepositoryProvider).completeOnboarding(
        profileImage: _profileImage!,
        aadharPath: _aadharFilePath!,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );

      if (!mounted) return;
      
      // Logout to clear session and show success
      await ref.read(authProvider.notifier).logout();
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: ShiftleyTokens.paperWhite,
          shape: const RoundedRectangleBorder(side: BorderSide(color: ShiftleyTokens.inkBlack, width: 3)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_outlined, color: Colors.green, size: 80),
              const SizedBox(height: ShiftleyTokens.spaceL),
              const Text(
                'VERIFIER SETUP COMPLETE',
                style: ShiftleyTokens.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ShiftleyTokens.spaceM),
              const Text(
                'Your profile has been submitted for approval. Please login again later.',
                style: ShiftleyTokens.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ShiftleyTokens.spaceXL),
              ShiftleyButton(
                label: 'CONTINUE',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/dev');
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: ShiftleyTokens.primaryRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Shiftley.',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: ShiftleyTokens.inkBlack,
                        letterSpacing: -2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceXL),
                    const Text(
                      'VERIFIER ONBOARDING',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: ShiftleyTokens.inkBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceM),
                    const Text(
                      'Complete your auditor profile to access the verification dashboard.',
                      style: ShiftleyTokens.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceXL),

                    // ── Profile Picture ──────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: ShiftleyTokens.paperWhite,
                                border: ShiftleyTokens.primaryBorder,
                                shape: BoxShape.circle,
                                image: _profileImage != null 
                                  ? DecorationImage(image: FileImage(File(_profileImage!.path)), fit: BoxFit.cover)
                                  : null,
                              ),
                              child: _profileImage == null 
                                ? const Icon(Icons.person_outline, size: 64, color: ShiftleyTokens.mutedText)
                                : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ShiftleyTokens.secondaryCyan,
                                  border: ShiftleyTokens.primaryBorder,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(color: ShiftleyTokens.inkBlack, offset: Offset(2, 2)),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_outlined, size: 20, color: ShiftleyTokens.inkBlack),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Upload Profile Photo (PNG, JPG, HEIC)',
                      style: ShiftleyTokens.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceXL),

                    const SizedBox(height: ShiftleyTokens.spaceXL),

                    // ── Identity Verification (NEW) ──────────────────────────
                    const Text(
                      'IDENTITY VERIFICATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: ShiftleyTokens.primaryRed,
                      ),
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceM),
                    _buildFileUpload(
                      label: 'MASKED AADHAR (PDF)',
                      fileName: _aadharFileName,
                      icon: Icons.picture_as_pdf_outlined,
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceL),

                    // ── Location Verification (NEW) ─────────────────────────
                    const Text(
                      'BASE LOCATION SETUP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: ShiftleyTokens.primaryRed,
                      ),
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceM),
                    _buildLocationCapture(),
                    const SizedBox(height: ShiftleyTokens.spaceXL),

                    ShiftleyButton(
                      label: 'SUBMIT FOR APPROVAL',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildFileUpload({required String label, required String? fileName, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: ShiftleyTokens.spaceS),
        Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: ShiftleyTokens.paperWhite,
            border: ShiftleyTokens.primaryBorder,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Row(
            children: [
              Icon(icon, color: ShiftleyTokens.primaryRed),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: Text(fileName ?? 'Select PDF File', style: ShiftleyTokens.bodyMedium),
              ),
              ShiftleyButton(
                label: fileName == null ? 'BROWSE' : 'CHANGE',
                onPressed: _pickFile,
                isPrimary: false,
                size: ShiftleyButtonSize.small,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCapture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GEOTAG HOME BASE', style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: ShiftleyTokens.spaceS),
        Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: ShiftleyTokens.paperWhite,
            border: ShiftleyTokens.primaryBorder,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: ShiftleyTokens.primaryRed),
                  const SizedBox(width: ShiftleyTokens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPosition != null 
                            ? '${_currentPosition!.latitude.toStringAsFixed(4)}° N, ${_currentPosition!.longitude.toStringAsFixed(4)}° E' 
                            : 'Location not captured', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                        ),
                        Text(
                          _currentPosition != null 
                            ? 'Accuracy: ± ${_currentPosition!.accuracy.toStringAsFixed(1)} meters' 
                            : 'Accuracy: N/A', 
                          style: ShiftleyTokens.caption
                        ),
                      ],
                    ),
                  ),
                  ShiftleyButton(
                    label: _currentPosition == null ? 'CAPTURE' : 'RE-SYNC',
                    onPressed: _getCurrentLocation,
                    isPrimary: true,
                    size: ShiftleyButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
