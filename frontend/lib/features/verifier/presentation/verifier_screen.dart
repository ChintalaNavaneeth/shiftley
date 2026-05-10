import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';
import 'package:shiftley_frontend/shared/widgets/s_guidance.dart';

import 'views/faq_view.dart';
import 'views/support_view.dart';
import 'package:shiftley_frontend/shared/widgets/s_refreshable.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftley_frontend/features/verifier/presentation/providers/verifier_providers.dart';
import 'package:shiftley_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shiftley_frontend/features/verifier/data/verifier_repository_provider.dart';
import 'package:shiftley_frontend/features/auth/presentation/providers/profile_provider.dart';
import 'package:shiftley_frontend/features/verifier/presentation/widgets/selfie_capture_screen.dart';
import 'dart:io';
import 'package:shiftley_frontend/features/verifier/domain/models/verifier_models.dart';

enum VerifierView { queue, details, history, historyDetails, rejection, verifyFlow, success, support, faq, settings }

class VerifierScreen extends StatefulWidget {
  const VerifierScreen({super.key});

  @override
  State<VerifierScreen> createState() => _VerifierScreenState();
}

class _VerifierScreenState extends State<VerifierScreen> {
  VerifierView _currentView = VerifierView.queue;
  int _activeTabIndex = 0;
  String? _selectedEmployerId;
  VerificationAudit? _selectedAudit;
  String _rejectionReason = '';
  int _verifyStep = 1; 
  bool _isVerifying = false;
  bool _isGpsCaptured = false;
  bool _isGpsValid = false;

  // Capture State
  XFile? _selfieFile;
  final List<XFile> _businessPhotos = [];
  Position? _currentPosition;
  final ImagePicker _picker = ImagePicker();

  // History Filters
  DateTime? _fromDate;
  DateTime? _toDate;
  String _historySearchQuery = '';

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    // Reset orientation to system defaults
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        appBar: AppBar(
          title: Text(_getViewTitle(), style: ShiftleyTokens.h2),
          backgroundColor: ShiftleyTokens.paperWhite,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: ShiftleyTokens.inkBlack),
          leading: _currentView != VerifierView.queue && _currentView != VerifierView.success
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _handleBack(),
                )
              : null,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: ShiftleyTokens.inkBlack, height: 1.5),
          ),
        ),
        drawer: _currentView == VerifierView.queue ? _buildDrawer() : null,
        body: Consumer(
          builder: (context, ref, child) {
            return _buildBody(ref);
          },
        ),
      ),
    );
  }

  void _handleBack() {
    setState(() {
      if (_currentView == VerifierView.rejection || _currentView == VerifierView.verifyFlow) {
        _currentView = VerifierView.details;
      } else if (_currentView == VerifierView.historyDetails) {
        _currentView = VerifierView.history;
      } else if (_currentView == VerifierView.support || _currentView == VerifierView.faq || _currentView == VerifierView.settings) {
        _currentView = VerifierView.queue;
      } else {
        _currentView = VerifierView.queue;
      }
    });
  }

  String _getViewTitle() {
    switch (_currentView) {
      case VerifierView.queue: return 'Verification Queue';
      case VerifierView.details: return 'Employer Details';
      case VerifierView.history: return 'Audit History';
      case VerifierView.historyDetails: return 'Audit Details';
      case VerifierView.rejection: return 'Reject Onboarding';
      case VerifierView.verifyFlow: return 'On-Site Verification';
      case VerifierView.success: return 'Verification Complete';
      case VerifierView.support: return 'Auditor Support';
      case VerifierView.faq: return 'Auditor Help & FAQ';
      case VerifierView.settings: return 'Auditor Settings';
    }
  }

  Widget _buildBody(WidgetRef ref) {
    switch (_currentView) {
      case VerifierView.queue: return _buildQueueView(ref);
      case VerifierView.details: return _buildDetailsView(ref, _selectedEmployerId!);
      case VerifierView.history: return _buildHistoryView(ref);
      case VerifierView.historyDetails: return _buildHistoryDetailsView();
      case VerifierView.rejection: return _buildRejectionView();
      case VerifierView.verifyFlow: return _buildVerifyFlow(ref);
      case VerifierView.success: return _buildSuccessView();
      case VerifierView.support: return const Padding(padding: EdgeInsets.all(16), child: SupportView());
      case VerifierView.faq: return const Padding(padding: EdgeInsets.all(16), child: FAQView());
      case VerifierView.settings: return _buildSettingsView();
    }
  }

  // ── Success View ───────────────────────────────────────────
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 80, color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            const Text('Verification Successful!', style: ShiftleyTokens.h1, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'The employer data and physical location have been verified and synced with the backend.',
              textAlign: TextAlign.center,
              style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText),
            ),
            const SizedBox(height: ShiftleyTokens.spaceXXL),
            SButton(
              text: 'Return to Queue',
              type: SButtonType.primary,
              onPressed: () => setState(() {
                _currentView = VerifierView.queue;
                _isGpsCaptured = false;
                _isGpsValid = false;
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Verify Flow ─────────────────────────────────────────────
  Widget _buildVerifyFlow(WidgetRef ref) {
    bool canProceed = false;
    if (_verifyStep == 1) {
      canProceed = _selfieFile != null;
    } else if (_verifyStep == 2) {
      canProceed = _businessPhotos.length >= 3;
    } else if (_verifyStep == 3) {
      canProceed = _isGpsValid && _currentPosition != null;
    }

    return Padding(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step $_verifyStep of 3', style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildVerifyStepContent(),
          const Spacer(),
          if (_isVerifying)
            const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed))
          else
            ShiftleyGuidance(
            isActive: !canProceed,
            message: _verifyStep == 1 ? 'Please capture a selfie first.' : (_verifyStep == 2 ? 'Please capture all 3 business photos.' : 'Please capture and verify GPS location first.'),
            child: SButton(
              text: _verifyStep < 3 ? 'Next Step' : 'Complete Verification',
              type: SButtonType.primary,
              onPressed: canProceed ? () async {
                if (_verifyStep < 3) {
                  setState(() => _verifyStep++);
                } else {
                  _submitVerification(ref);
                }
              } : null,
            ),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),
        ],
      ),
    );
  }

  Future<void> _submitVerification(WidgetRef ref) async {
    if (_selectedEmployerId == null || _selfieFile == null || _businessPhotos.length < 3 || _currentPosition == null) return;

    setState(() => _isVerifying = true);
    try {
      await ref.read(verifierRepositoryProvider).verifyEmployer(
        employerId: _selectedEmployerId!,
        selfie: _selfieFile!,
        businessPhotos: _businessPhotos,
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        isApproved: true,
      );
      setState(() {
        _isVerifying = false;
        _currentView = VerifierView.success;
      });
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
      }
    }
  }

  Future<void> _captureImage(bool isSelfie) async {
    try {
      XFile? image;
      
      if (isSelfie) {
        // Use custom camera for selfie to enforce front lens
        image = await Navigator.push<XFile>(
          context,
          MaterialPageRoute(builder: (context) => const SelfieCaptureScreen()),
        );
      } else {
        // Use standard picker for business photos
        image = await _picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          imageQuality: 70,
        );
      }

      if (image != null) {
        setState(() {
          if (isSelfie) {
            _selfieFile = image;
          } else {
            if (_businessPhotos.length < 3) {
              _businessPhotos.add(image!);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _captureLocation() async {
    setState(() => _isVerifying = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        setState(() {
          _currentPosition = position;
          _isGpsCaptured = true;
          _isGpsValid = true;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  Widget _buildVerifyStepContent() {
    switch (_verifyStep) {
      case 1:
        return _buildStepLayout('Capture Selfie', 'Take a photo with the contact person at the business location.', Icons.face_retouching_natural);
      case 2:
        return _buildStepLayout('Business Photos', 'Take 3 clear pictures of the business premise (Front, Internal, Signage).', Icons.add_a_photo_outlined, isMulti: true);
      case 3:
        return _buildGeoStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStepLayout(String title, String desc, IconData icon, {bool isMulti = false}) {
    final bool hasImage = isMulti ? _businessPhotos.isNotEmpty : _selfieFile != null;
    final file = isMulti ? (_businessPhotos.isNotEmpty ? _businessPhotos.last : null) : _selfieFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ShiftleyTokens.h1),
        const SizedBox(height: 8),
        Text(desc, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText)),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        GestureDetector(
          onTap: () => _captureImage(!isMulti),
          child: Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: ShiftleyTokens.paperWhite, 
              border: ShiftleyTokens.primaryBorder, 
              borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
              image: hasImage ? DecorationImage(image: FileImage(File(file!.path)), fit: BoxFit.cover) : null,
            ),
            child: !hasImage ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: ShiftleyTokens.mutedText),
                const SizedBox(height: 16),
                if (isMulti) const Text('0 / 3 Photos Captured', style: ShiftleyTokens.caption) else const Text('Tap to open camera', style: ShiftleyTokens.caption),
              ],
            ) : (isMulti ? Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text('${_businessPhotos.length} / 3 Captured', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ) : null),
          ),
        ),
      ],
    );
  }

  Widget _buildGeoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm Location', style: ShiftleyTokens.h1),
        const SizedBox(height: 8),
        Text('Sync your current GPS coordinates to verify physical existence.', style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText)),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
          decoration: BoxDecoration(color: ShiftleyTokens.paperWhite, border: ShiftleyTokens.primaryBorder, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
          child: Column(
            children: [
              if (!_isGpsCaptured)
                Column(
                  children: [
                    const Icon(Icons.location_searching, size: 48, color: ShiftleyTokens.mutedText),
                    const SizedBox(height: 16),
                    const Text('GPS Location Not Captured', style: ShiftleyTokens.caption),
                    const SizedBox(height: 24),
                    SButton(
                      text: 'Capture GPS Location',
                      type: SButtonType.primary, 
                      onPressed: _captureLocation,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const Icon(Icons.check_circle, size: 48, color: Colors.green),
                    const SizedBox(height: 16),
                    Text('Location Captured Successfully', style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Lat: ${_currentPosition?.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition?.longitude.toStringAsFixed(6)}', style: ShiftleyTokens.caption),
                    const SizedBox(height: 24),
                    SButton(
                      text: 'Re-capture Location',
                      type: SButtonType.secondary, 
                      onPressed: _captureLocation,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Drawer UI ──────────────────────────────────────────────
  Widget _buildDrawer() {
    return Consumer(
      builder: (context, ref, child) {
        final profileAsync = ref.watch(userProfileProvider);

        return Drawer(
          backgroundColor: ShiftleyTokens.paperWhite,
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profileAsync.when(
                loading: () => Container(height: 250, color: ShiftleyTokens.inkBlack, child: const Center(child: CircularProgressIndicator(color: ShiftleyTokens.secondaryCyan))),
                error: (err, stack) => Container(height: 250, color: ShiftleyTokens.inkBlack, child: Center(child: Text('Error loading profile', style: ShiftleyTokens.caption.copyWith(color: Colors.white)))),
                data: (profile) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(ShiftleyTokens.spaceXL, 64, ShiftleyTokens.spaceXL, ShiftleyTokens.spaceXL),
                  decoration: const BoxDecoration(
                    color: ShiftleyTokens.inkBlack,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: ShiftleyTokens.secondaryCyan,
                          border: Border.all(color: ShiftleyTokens.inkBlack, width: 3),
                          shape: BoxShape.circle,
                          image: (profile['profile_photo_url'] != null && profile['profile_photo_url'].isNotEmpty) 
                            ? DecorationImage(
                                image: NetworkImage(_getFullUrl(profile['profile_photo_url'])),
                                fit: BoxFit.cover,
                              )
                            : null,
                        ),
                        child: (profile['profile_photo_url'] == null || profile['profile_photo_url'].isEmpty)
                          ? const Icon(Icons.person, size: 48, color: ShiftleyTokens.inkBlack)
                          : null,
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceL),
                      Text(
                        profile['full_name'] ?? 'Verifier Staff',
                        style: const TextStyle(color: ShiftleyTokens.paperWhite, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Figtree'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile['email'] ?? 'auditor@shiftley.in',
                        style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.secondaryCyan, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceL),
                      _buildProfileMeta(Icons.phone_outlined, profile['phone_number'] ?? '+91 00000 00000'),
                      const SizedBox(height: 8),
                      _buildProfileMeta(Icons.badge_outlined, profile['role'] ?? 'VERIFIER'),
                      const SizedBox(height: 8),
                      _buildProfileMeta(Icons.verified_user_outlined, 'Aadhaar Verified', iconColor: Colors.greenAccent),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: ShiftleyTokens.spaceXL),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(Icons.queue_outlined, 'Verification Queue', _currentView == VerifierView.queue, onTap: () { setState(() => _currentView = VerifierView.queue); Navigator.pop(context); }),
                    _buildDrawerItem(Icons.history_outlined, 'History', _currentView == VerifierView.history, onTap: () { setState(() => _currentView = VerifierView.history); Navigator.pop(context); }),
                    _buildDrawerItem(Icons.support_agent_outlined, 'Support Hub', _currentView == VerifierView.support, onTap: () { setState(() => _currentView = VerifierView.support); Navigator.pop(context); }),
                    _buildDrawerItem(Icons.help_outline_rounded, 'Help & FAQ', _currentView == VerifierView.faq, onTap: () { setState(() => _currentView = VerifierView.faq); Navigator.pop(context); }),
                    _buildDrawerItem(Icons.settings_outlined, 'Settings', _currentView == VerifierView.settings, onTap: () { setState(() => _currentView = VerifierView.settings); Navigator.pop(context); }),
                  ],
                ),
              ),
              
              const Divider(color: ShiftleyTokens.inkBlack, thickness: 1.5, height: 1),
              _buildDrawerItem(
                Icons.logout, 
                'Logout', 
                false, 
                isDestructive: true, 
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/dev');
                  }
                },
              ),
              const SizedBox(height: ShiftleyTokens.spaceM),
            ],
          ),
        );
      },
    );
  }

  String _getFullUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    // Assuming ApiClient.baseUrl is 'http://192.168.1.6:8080/api/v1/'
    return 'http://192.168.1.6:8080$path';
  }

  Widget _buildProfileMeta(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor ?? ShiftleyTokens.paperWhite.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: ShiftleyTokens.paperWhite, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Other Helpers ───────────────────────────────────────────
  Widget _buildQueueView(WidgetRef ref) {
    const String roleFilter = 'EMPLOYER';
    final String statusFilter = _activeTabIndex == 0 ? 'PENDING' : 'VERIFIED';
    final queueAsync = ref.watch(verifierQueueListProvider((type: roleFilter, status: statusFilter)));

    return SRefreshable(
      onRefresh: () async {
        ref.invalidate(verifierQueueListProvider);
        ref.invalidate(userProfileProvider);
        await Future.delayed(const Duration(seconds: 1));
      },
      child: queueAsync.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed))),
        error: (err, stack) => Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text('Error: $err', style: ShiftleyTokens.caption))),
        data: (items) {
          return Column(
            children: [
              _buildStatusTabs(),
              Padding(
                padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Showing ${items.length} tasks', style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
                    const Icon(Icons.filter_list, size: 16),
                  ],
                ),
              ),
              if (items.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(64.0), child: Text('No $roleFilter tasks found', style: ShiftleyTokens.caption)))
              else
                Column(
                  children: items.map((item) {
                    return _buildQueueItem(
                      id: item.userId,
                      name: item.fullName,
                      details: item.kycStatus,
                      status: item.role,
                      time: _formatDate(item.createdAt),
                      phoneNumber: item.phoneNumber,
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildDetailsView(WidgetRef ref, String id) {
    final detailsAsync = ref.watch(employerDetailsProvider(id));

    return detailsAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(64.0), child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed))),
      error: (err, stack) => Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text('Error loading details: $err', style: ShiftleyTokens.caption))),
      data: (profile) => SingleChildScrollView(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('General Information', style: ShiftleyTokens.h2), _buildStatusChip(profile.verificationStatus)]),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            _buildDetailSection('Business Details', [
              _buildDetailItem('Legal Business Name', profile.businessName),
              _buildDetailItem('Business Type', profile.businessType),
              _buildDetailItem('GST Number', profile.gstNumber ?? 'N/A'),
              _buildDetailItem('Aadhaar Last 4', profile.aadhaarLast4 ?? 'N/A'),
            ]),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            _buildDetailSection('Contact Information', [
              _buildDetailItem('Phone Number', profile.phoneNumber),
              _buildDetailItem('Email Address', profile.email),
            ]),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            _buildDetailSection('Operational Address', [
              _buildDetailItem('Full Address', profile.businessAddress),
            ]),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            _buildDetailSection('Geo Location', [
              _buildDetailItem('Latitude', profile.lat.toStringAsFixed(6)),
              _buildDetailItem('Longitude', profile.lng.toStringAsFixed(6)),
              const SizedBox(height: ShiftleyTokens.spaceS),
              SButton(
                text: 'View on Google Maps', 
                type: SButtonType.secondary, 
                onPressed: () => _launchUrl('https://www.google.com/maps/search/?api=1&query=${profile.lat},${profile.lng}'),
              ),
            ]),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            _buildDetailSection('Uploaded Documents', [
              if (profile.aadhaarUrl != null)
                _buildDocumentItem('Aadhaar Document', 'aadhaar_proof.pdf', url: profile.aadhaarUrl),
              ...profile.photoUrls.asMap().entries.map((entry) {
                return _buildDocumentItem('Business Photo ${entry.key + 1}', 'business_${entry.key + 1}.jpg', url: entry.value);
              }),
            ]),
            const SizedBox(height: ShiftleyTokens.spaceXXL),
            if (profile.verificationStatus == 'PENDING')
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentView = VerifierView.rejection), style: OutlinedButton.styleFrom(foregroundColor: ShiftleyTokens.primaryRed, side: const BorderSide(color: ShiftleyTokens.primaryRed, width: 1.5), minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal))), child: const Text('Reject Onboarding', style: TextStyle(fontWeight: FontWeight.bold)))),
                const SizedBox(width: ShiftleyTokens.spaceM),
                Expanded(child: ElevatedButton(onPressed: () => setState(() { _verifyStep = 1; _currentView = VerifierView.verifyFlow; }), style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 2.0), minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal))), child: const Text('Verify Now', style: TextStyle(fontWeight: FontWeight.bold)))),
              ]),
            const SizedBox(height: ShiftleyTokens.spaceXL),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionView() {
    final suggestions = ['GST Number Mismatch', 'Invalid Address', 'Incomplete Documents', 'FSSAI License Expired', 'Mismatch in PAN details'];
    return Padding(padding: const EdgeInsets.all(ShiftleyTokens.spaceL), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Why are you rejecting this onboarding?', style: ShiftleyTokens.bodyLarge), const SizedBox(height: ShiftleyTokens.spaceM), Wrap(spacing: 8, runSpacing: 8, children: suggestions.map((s) => ActionChip(label: Text(s, style: const TextStyle(fontSize: 12)), backgroundColor: ShiftleyTokens.paperWhite, side: const BorderSide(color: ShiftleyTokens.inkBlack), onPressed: () => setState(() => _rejectionReason = s))).toList()), const SizedBox(height: ShiftleyTokens.spaceXL), const Text('Additional Justification', style: ShiftleyTokens.caption), const SizedBox(height: 8), TextField(maxLines: 4, decoration: InputDecoration(border: ShiftleyTokens.primaryInputBorder, enabledBorder: ShiftleyTokens.primaryInputBorder, focusedBorder: ShiftleyTokens.focusInputBorder, hintText: 'Provide detailed reason...', fillColor: ShiftleyTokens.paperWhite, filled: true), controller: TextEditingController(text: _rejectionReason), onChanged: (v) => _rejectionReason = v), const Spacer(), SButton(text: 'Confirm Rejection', type: SButtonType.primary, onPressed: () => setState(() => _currentView = VerifierView.queue)), const SizedBox(height: ShiftleyTokens.spaceXL)]));
  }

  Widget _buildHistoryView(WidgetRef ref) {
    final String? fromStr = _fromDate?.toIso8601String().split('T')[0];
    final String? toStr = _toDate?.toIso8601String().split('T')[0];
    
    final historyAsync = ref.watch(verifierHistoryListProvider((
      from: fromStr, 
      to: toStr, 
      query: _historySearchQuery.isEmpty ? null : _historySearchQuery
    )));

    return SRefreshable(
      onRefresh: () async {
        ref.invalidate(verifierHistoryListProvider);
        await Future.delayed(const Duration(seconds: 1));
      },
      child: Column(
        children: [
          Container(
            color: ShiftleyTokens.paperWhite, 
            padding: const EdgeInsets.all(ShiftleyTokens.spaceL), 
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDatePicker('From Date', _fromDate, (date) => setState(() => _fromDate = date))), 
                    const SizedBox(width: ShiftleyTokens.spaceM), 
                    Expanded(child: _buildDatePicker('To Date', _toDate, (date) => setState(() => _toDate = date)))
                  ]
                ), 
                const SizedBox(height: ShiftleyTokens.spaceM), 
                SizedBox(
                  height: 48, 
                  child: TextField(
                    onChanged: (v) => setState(() => _historySearchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by user name...', 
                      prefixIcon: const Icon(Icons.search, size: 20), 
                      filled: true, 
                      fillColor: ShiftleyTokens.background, 
                      border: ShiftleyTokens.primaryInputBorder, 
                      enabledBorder: ShiftleyTokens.primaryInputBorder, 
                      focusedBorder: ShiftleyTokens.focusInputBorder, 
                      contentPadding: EdgeInsets.zero
                    )
                  )
                )
              ]
            )
          ), 
          const Divider(color: ShiftleyTokens.inkBlack, thickness: 1.5, height: 1),
          Padding(
            padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed)),
              error: (err, stack) => Text('Error: $err'),
              data: (audits) {
                if (audits.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No history found', style: ShiftleyTokens.caption)));
                return Column(
                  children: audits.map((audit) {
                    return _buildHistoryItem(
                      audit.userFullName ?? 'User: ${audit.userId.substring(0, 8)}',
                      audit.status,
                      _formatDate(audit.createdAt),
                      audit.notes,
                      onTap: () => setState(() {
                        _selectedAudit = audit;
                        _currentView = VerifierView.historyDetails;
                      }),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryDetailsView() {
    if (_selectedAudit == null) return const Center(child: Text('No audit selected'));
    final audit = _selectedAudit!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Audit Evidence', style: ShiftleyTokens.h2),
              _buildStatusChip(audit.status),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          
          _buildDetailSection('Business Information', [
            _buildDetailItem('User ID', audit.userId),
            _buildDetailItem('Full Name', audit.userFullName ?? 'N/A'),
            _buildDetailItem('Audited On', _formatDate(audit.createdAt)),
            _buildDetailItem('Status', audit.status),
          ]),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildDetailSection('Verification Evidence', [
            if (audit.verifierSelfieUrl != null)
              _buildEvidenceItem('Auditor Selfie', audit.verifierSelfieUrl!),
            if (audit.locationPhoto1Url != null)
              _buildEvidenceItem('Business Photo 1', audit.locationPhoto1Url!),
            const SizedBox(height: 8),
            _buildDetailItem('Coordinates', '${audit.verifiedLat?.toStringAsFixed(6)}, ${audit.verifiedLng?.toStringAsFixed(6)}'),
          ]),
          const SizedBox(height: ShiftleyTokens.spaceXL),

          _buildDetailSection('Audit Notes', [
            Text(
              audit.notes.isEmpty ? 'No notes provided.' : audit.notes,
              style: ShiftleyTokens.bodyMedium,
            ),
          ]),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          
          SButton(
            text: 'Back to History',
            type: SButtonType.secondary,
            onPressed: () => setState(() => _currentView = VerifierView.history),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),
        ],
      ),
    );
  }

  Widget _buildEvidenceItem(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: ShiftleyTokens.primaryBorder,
              borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
              image: DecorationImage(
                image: NetworkImage(_getFullUrl(url)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onSelect) {
    return GestureDetector(onTap: () async { final picked = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2023), lastDate: DateTime.now()); if (picked != null) onSelect(picked); }, child: Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: ShiftleyTokens.background, border: ShiftleyTokens.primaryBorder, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(date == null ? label : '${date.day}/${date.month}/${date.year}', style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.bold)), const Icon(Icons.calendar_today, size: 16)])));
  }

  Widget _buildHistoryItem(String name, String status, String date, String note, {VoidCallback? onTap}) {
    final bool isApproved = status == 'APPROVED';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM), 
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM), 
        decoration: BoxDecoration(
          color: ShiftleyTokens.paperWhite, 
          border: ShiftleyTokens.primaryBorder, 
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)
        ), 
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(name, style: ShiftleyTokens.bodyLarge), 
                  Text(note, style: ShiftleyTokens.caption, maxLines: 1, overflow: TextOverflow.ellipsis), 
                  const SizedBox(height: 4), 
                  Text('Audited on $date', style: ShiftleyTokens.caption.copyWith(fontSize: 10))
                ]
              )
            ), 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
              decoration: BoxDecoration(
                color: isApproved ? Colors.green[50] : Colors.red[50], 
                border: Border.all(color: isApproved ? Colors.green : Colors.red), 
                borderRadius: BorderRadius.circular(4)
              ), 
              child: Text(status, style: TextStyle(color: isApproved ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold, fontSize: 10))
            )
          ]
        )
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      width: double.infinity, 
      decoration: const BoxDecoration(
        color: ShiftleyTokens.paperWhite, 
        border: Border(bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 1.5))
      ), 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceL), 
        child: Row(
          children: [
            _buildTab('PENDING', 0), 
            _buildTab('COMPLETED', 2)
          ]
        )
      )
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _activeTabIndex == index;
    return GestureDetector(onTap: () => setState(() => _activeTabIndex = index), child: Container(padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: 16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isActive ? ShiftleyTokens.primaryRed : Colors.transparent, width: 3))), child: Text(label, style: TextStyle(color: isActive ? ShiftleyTokens.inkBlack : ShiftleyTokens.mutedText, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, fontSize: 13))));
  }

  Widget _buildQueueItem({required String id, required String name, required String details, required String status, required String time, required String phoneNumber}) {
    return Container(margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceL), padding: const EdgeInsets.all(ShiftleyTokens.spaceL), decoration: BoxDecoration(color: ShiftleyTokens.paperWhite, border: ShiftleyTokens.primaryBorder, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)), child: Column(children: [Row(children: [Container(padding: const EdgeInsets.all(ShiftleyTokens.spaceS), decoration: BoxDecoration(color: ShiftleyTokens.secondaryCyan, border: Border.all(color: ShiftleyTokens.inkBlack, width: 1.5), shape: BoxShape.circle), child: const Icon(Icons.business_outlined, color: ShiftleyTokens.inkBlack, size: 20)), const SizedBox(width: ShiftleyTokens.spaceM), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: ShiftleyTokens.bodyLarge), const SizedBox(height: 2), Text('EMPLOYER • $details', style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(phoneNumber, style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.w600))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(time, style: ShiftleyTokens.caption), const SizedBox(height: 4), _buildStatusChip(status)])]), const SizedBox(height: ShiftleyTokens.spaceXL), Row(children: [Expanded(child: OutlinedButton(onPressed: () => setState(() { _selectedEmployerId = id; _currentView = VerifierView.details; }), style: OutlinedButton.styleFrom(foregroundColor: ShiftleyTokens.inkBlack, side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 1.5), minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal))), child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))), const SizedBox(width: ShiftleyTokens.spaceM), Expanded(child: ElevatedButton(onPressed: () => _launchUrl('tel:$phoneNumber'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: ShiftleyTokens.paperWhite, side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 2.0), minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal))), child: const Text('Call Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))))])]));
  }

  Widget _buildStatusChip(String status) {
    Color bgColor = ShiftleyTokens.background;
    Color textColor = ShiftleyTokens.inkBlack;
    
    final upperStatus = status.toUpperCase();
    
    if (upperStatus == 'VERIFIED' || upperStatus == 'APPROVED') {
      bgColor = Colors.green[100]!;
      textColor = Colors.green[900]!;
    } else if (upperStatus == 'REJECTED') {
      bgColor = Colors.red[100]!;
      textColor = Colors.red[900]!;
    } else if (upperStatus == 'PENDING' || upperStatus == 'IN PROGRESS') {
      bgColor = ShiftleyTokens.secondaryCyan;
      textColor = ShiftleyTokens.inkBlack;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
      decoration: BoxDecoration(
        color: bgColor, 
        border: Border.all(color: ShiftleyTokens.inkBlack, width: 1.0), 
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal / 2)
      ), 
      child: Text(
        upperStatus, 
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textColor)
      )
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.primaryRed)), const SizedBox(height: ShiftleyTokens.spaceM), Container(width: double.infinity, padding: const EdgeInsets.all(ShiftleyTokens.spaceM), decoration: BoxDecoration(color: ShiftleyTokens.paperWhite, border: ShiftleyTokens.primaryBorder, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)), child: Column(children: items))]);
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold))), Expanded(flex: 3, child: Text(value, style: ShiftleyTokens.bodyMedium))]));
  }

  Widget _buildDocumentItem(String label, String fileName, {String? url}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), 
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 20, color: ShiftleyTokens.mutedText), 
          const SizedBox(width: 12), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(label, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)), 
                Text(fileName, style: ShiftleyTokens.caption)
              ]
            )
          ), 
          TextButton(
            onPressed: url != null ? () => _launchUrl(_getFullUrl(url)) : null, 
            child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue))
          )
        ]
      )
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  Widget _buildDrawerItem(IconData icon, String label, bool isActive, {bool isDestructive = false, required VoidCallback onTap}) {
    final color = isDestructive ? ShiftleyTokens.primaryRed : ShiftleyTokens.inkBlack;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: 4), child: ListTile(leading: Icon(icon, color: color, size: 22), title: Text(label, style: TextStyle(color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, fontSize: 14)), tileColor: isActive ? ShiftleyTokens.secondaryCyan : Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal), side: isActive ? const BorderSide(color: ShiftleyTokens.inkBlack, width: 1.5) : BorderSide.none), onTap: onTap));
  }

  Widget _buildSettingsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailSection('Auditor Preferences', [
            _buildToggleRow('System Notifications', 'Receive audit assignments and deadlines', true),
            _buildToggleRow('WhatsApp Updates', 'Sync audit reports via WhatsApp', true),
            _buildToggleRow('Offline Mode', 'Store audit data locally when offline', false),
          ]),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildDetailSection('Account Management', [
            _buildSettingsAction('Export My Audit Logs', 'Download your verification history', Icons.download_outlined, () {}),
          ]),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: ShiftleyTokens.caption),
              ],
            ),
          ),
          Switch(value: val, onChanged: (v) {}, activeThumbColor: ShiftleyTokens.secondaryCyan, activeTrackColor: ShiftleyTokens.inkBlack),
        ],
      ),
    );
  }

  Widget _buildSettingsAction(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isDanger ? Colors.red.withValues(alpha: 0.1) : ShiftleyTokens.secondaryCyan.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: isDanger ? Colors.red : ShiftleyTokens.inkBlack),
      ),
      title: Text(title, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: isDanger ? Colors.red : ShiftleyTokens.inkBlack)),
      subtitle: Text(subtitle, style: ShiftleyTokens.caption),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    );
  }
}
