import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';
import 'package:shiftley_frontend/shared/widgets/s_guidance.dart';

import 'views/faq_view.dart';
import 'views/support_view.dart';

enum VerifierView { queue, details, history, rejection, verifyFlow, success, support, faq, settings }

class VerifierScreen extends StatefulWidget {
  const VerifierScreen({super.key});

  @override
  State<VerifierScreen> createState() => _VerifierScreenState();
}

class _VerifierScreenState extends State<VerifierScreen> {
  VerifierView _currentView = VerifierView.queue;
  int _activeTabIndex = 0;
  String? _selectedEmployerId;
  String _rejectionReason = '';
  int _verifyStep = 1; 
  bool _isVerifying = false;
  bool _isGpsCaptured = false;
  bool _isGpsValid = false;

  // History Filters
  DateTime? _fromDate;
  DateTime? _toDate;

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
        body: _buildBody(),
      ),
    );
  }

  void _handleBack() {
    setState(() {
      if (_currentView == VerifierView.rejection || _currentView == VerifierView.verifyFlow) {
        _currentView = VerifierView.details;
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
      case VerifierView.rejection: return 'Reject Onboarding';
      case VerifierView.verifyFlow: return 'On-Site Verification';
      case VerifierView.success: return 'Verification Complete';
      case VerifierView.support: return 'Auditor Support';
      case VerifierView.faq: return 'Auditor Help & FAQ';
      case VerifierView.settings: return 'Auditor Settings';
    }
  }

  Widget _buildBody() {
    switch (_currentView) {
      case VerifierView.queue: return _buildQueueView();
      case VerifierView.details: return _buildDetailsView(_selectedEmployerId!);
      case VerifierView.history: return _buildHistoryView();
      case VerifierView.rejection: return _buildRejectionView();
      case VerifierView.verifyFlow: return _buildVerifyFlow();
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
  Widget _buildVerifyFlow() {
    bool canProceed = true;
    if (_verifyStep == 3) {
      canProceed = _isGpsValid;
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
            message: 'Please capture and verify GPS location first.',
            child: SButton(
              text: _verifyStep < 3 ? 'Next Step' : 'Complete Verification',
              type: SButtonType.primary,
              onPressed: canProceed ? () async {
                if (_verifyStep < 3) {
                  setState(() => _verifyStep++);
                } else {
                  setState(() => _isVerifying = true);
                  await Future.delayed(const Duration(seconds: 2)); 
                  setState(() {
                    _isVerifying = false;
                    _currentView = VerifierView.success;
                  });
                }
              } : null,
            ),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),
        ],
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ShiftleyTokens.h1),
        const SizedBox(height: 8),
        Text(desc, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText)),
        const SizedBox(height: ShiftleyTokens.spaceXL),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(color: ShiftleyTokens.paperWhite, border: ShiftleyTokens.primaryBorder, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: ShiftleyTokens.mutedText),
              const SizedBox(height: 16),
              if (isMulti) const Text('0 / 3 Photos Captured', style: ShiftleyTokens.caption) else const Text('Tap to open camera', style: ShiftleyTokens.caption),
            ],
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
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        setState(() => _isGpsCaptured = true);
                        await Future.delayed(const Duration(seconds: 1)); // Simulate capture
                        setState(() => _isGpsValid = true);
                      },
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.gps_fixed, color: ShiftleyTokens.primaryRed, size: 20),
                        SizedBox(width: 12),
                        Text('Current GPS Signal: EXCELLENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailItem('Current Lat', '17.4148° N'),
                    _buildDetailItem('Current Long', '78.4485° E'),
                    _buildDetailItem('Distance to Target', '12 meters'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green[50], border: Border.all(color: Colors.green), borderRadius: BorderRadius.circular(4)),
                      child: Row(children: const [Icon(Icons.check_circle, color: Colors.green, size: 16), SizedBox(width: 8), Text('Location Verified (within 100m range)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11))]),
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
    return Drawer(
      backgroundColor: ShiftleyTokens.paperWhite,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                    border: Border.all(color: ShiftleyTokens.paperWhite, width: 3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 48, color: ShiftleyTokens.inkBlack),
                ),
                const SizedBox(height: ShiftleyTokens.spaceL),
                const Text(
                  'Rahul Sharma',
                  style: TextStyle(color: ShiftleyTokens.paperWhite, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Figtree'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verifier',
                  style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.secondaryCyan, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: ShiftleyTokens.spaceXL),
                _buildProfileMeta(Icons.email_outlined, 'rahul.v@shiftley.com'),
                const SizedBox(height: 8),
                _buildProfileMeta(Icons.phone_android_outlined, '+91 99887 76655'),
              ],
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
          _buildDrawerItem(Icons.logout, 'Logout', false, isDestructive: true, onTap: () => Navigator.pop(context)),
          const SizedBox(height: ShiftleyTokens.spaceM),
        ],
      ),
    );
  }

  Widget _buildProfileMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ShiftleyTokens.paperWhite.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: ShiftleyTokens.paperWhite, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Other Helpers ───────────────────────────────────────────
  Widget _buildQueueView() {
    final List<Map<String, String>> allItems = [
      {'id': '1', 'name': 'Taj Banjara', 'details': 'GST Verification & Physical Visit', 'status': 'Pending', 'time': '2h ago'},
      {'id': '2', 'name': 'Zomato Kitchen (Madhapur)', 'details': 'FSSAI License Review', 'status': 'In Progress', 'time': '1d ago'},
      {'id': '3', 'name': 'GMR AeroCity', 'details': 'Identity & Address Proof', 'status': 'Pending', 'time': '3h ago'},
      {'id': '4', 'name': 'ITC Kakatiya', 'details': 'Final Site Audit', 'status': 'Completed', 'time': '4h ago'},
      {'id': '5', 'name': 'Blue Fox', 'details': 'Bank Account Verification', 'status': 'In Progress', 'time': '5h ago'},
    ];
    final String targetStatus = _activeTabIndex == 0 ? 'Pending' : _activeTabIndex == 1 ? 'In Progress' : 'Completed';
    final filteredItems = allItems.where((item) => item['status'] == targetStatus).toList();
    return Column(children: [_buildStatusTabs(), Expanded(child: filteredItems.isEmpty ? Center(child: Text('No $targetStatus items', style: ShiftleyTokens.caption)) : ListView.builder(padding: const EdgeInsets.all(ShiftleyTokens.spaceL), itemCount: filteredItems.length, itemBuilder: (context, index) { final item = filteredItems[index]; return _buildQueueItem(id: item['id']!, name: item['name']!, details: item['details']!, status: item['status']!, time: item['time']!); }))]);
  }

  Widget _buildDetailsView(String id) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('General Information', style: ShiftleyTokens.h2), _buildStatusChip('Pending')]),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildDetailSection('Business Details', [_buildDetailItem('Legal Business Name', 'Taj Banjara Pvt Ltd'), _buildDetailItem('Trade Name', 'Taj Banjara'), _buildDetailItem('Business Type', 'Hospitality / Hotel'), _buildDetailItem('GST Number', '36AAAAA0000A1Z5'), _buildDetailItem('PAN Number', 'AAAAA0000A')]),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildDetailSection('Contact Information', [_buildDetailItem('Contact Person', 'Rajesh Gupta'), _buildDetailItem('Designation', 'General Manager'), _buildDetailItem('Phone Number', '+91 98765 43210'), _buildDetailItem('Official Email', 'admin@tajbanjara.com')]),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildDetailSection('Operational Address', [_buildDetailItem('Address Line 1', 'Road No. 1, Banjara Hills'), _buildDetailItem('City', 'Hyderabad'), _buildDetailItem('State', 'Telangana'), _buildDetailItem('PIN Code', '500034')]),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildDetailSection('Geo Location', [_buildDetailItem('Latitude', '17.4147° N'), _buildDetailItem('Longitude', '78.4484° E'), const SizedBox(height: ShiftleyTokens.spaceS), SButton(text: 'View on Google Maps', type: SButtonType.secondary, onPressed: () {})]),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildDetailSection('Bank Account Details', [_buildDetailItem('Account Holder', 'Taj Banjara Pvt Ltd'), _buildDetailItem('Account Number', '0011223344556677'), _buildDetailItem('IFSC Code', 'ICIC0000011'), _buildDetailItem('Bank Name', 'ICICI Bank'), _buildDetailItem('Account Type', 'Current Account')]),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildDetailSection('Uploaded Documents', [_buildDocumentItem('GST Certificate', 'gst_cert_36a.pdf'), _buildDocumentItem('PAN Card Copy', 'pan_card_taj.jpg'), _buildDocumentItem('FSSAI License', 'fssai_882.pdf'), _buildDocumentItem('Address Proof', 'utility_bill.pdf')]),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
          Row(children: [Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentView = VerifierView.rejection), style: OutlinedButton.styleFrom(foregroundColor: ShiftleyTokens.primaryRed, side: const BorderSide(color: ShiftleyTokens.primaryRed, width: 1.5), minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal))), child: const Text('Reject Onboarding', style: TextStyle(fontWeight: FontWeight.bold)))), const SizedBox(width: ShiftleyTokens.spaceM), Expanded(child: ElevatedButton(onPressed: () => setState(() { _verifyStep = 1; _currentView = VerifierView.verifyFlow; }), style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal))), child: const Text('Verify Now', style: TextStyle(fontWeight: FontWeight.bold))))]),
          const SizedBox(height: ShiftleyTokens.spaceXL),
        ],
      ),
    );
  }

  Widget _buildRejectionView() {
    final suggestions = ['GST Number Mismatch', 'Invalid Address', 'Incomplete Documents', 'FSSAI License Expired', 'Mismatch in PAN details'];
    return Padding(padding: const EdgeInsets.all(ShiftleyTokens.spaceL), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Why are you rejecting this onboarding?', style: ShiftleyTokens.bodyLarge), const SizedBox(height: ShiftleyTokens.spaceM), Wrap(spacing: 8, runSpacing: 8, children: suggestions.map((s) => ActionChip(label: Text(s, style: const TextStyle(fontSize: 12)), backgroundColor: ShiftleyTokens.paperWhite, side: const BorderSide(color: ShiftleyTokens.inkBlack), onPressed: () => setState(() => _rejectionReason = s))).toList()), const SizedBox(height: ShiftleyTokens.spaceXL), const Text('Additional Justification', style: ShiftleyTokens.caption), const SizedBox(height: 8), TextField(maxLines: 4, decoration: InputDecoration(border: ShiftleyTokens.primaryInputBorder, enabledBorder: ShiftleyTokens.primaryInputBorder, focusedBorder: ShiftleyTokens.focusInputBorder, hintText: 'Provide detailed reason...', fillColor: ShiftleyTokens.paperWhite, filled: true), controller: TextEditingController(text: _rejectionReason), onChanged: (v) => _rejectionReason = v), const Spacer(), SButton(text: 'Confirm Rejection', type: SButtonType.primary, onPressed: () => setState(() => _currentView = VerifierView.queue)), const SizedBox(height: ShiftleyTokens.spaceXL)]));
  }

  Widget _buildHistoryView() {
    return Column(children: [Container(color: ShiftleyTokens.paperWhite, padding: const EdgeInsets.all(ShiftleyTokens.spaceL), child: Column(children: [Row(children: [Expanded(child: _buildDatePicker('From Date', _fromDate, (date) => setState(() => _fromDate = date))), const SizedBox(width: ShiftleyTokens.spaceM), Expanded(child: _buildDatePicker('To Date', _toDate, (date) => setState(() => _toDate = date)))]), const SizedBox(height: ShiftleyTokens.spaceM), SizedBox(height: 48, child: TextField(decoration: InputDecoration(hintText: 'Search history...', prefixIcon: const Icon(Icons.search, size: 20), filled: true, fillColor: ShiftleyTokens.background, border: ShiftleyTokens.primaryInputBorder, enabledBorder: ShiftleyTokens.primaryInputBorder, focusedBorder: ShiftleyTokens.focusInputBorder, contentPadding: EdgeInsets.zero)))])), const Divider(color: ShiftleyTokens.inkBlack, thickness: 1.5, height: 1), Expanded(child: ListView(padding: const EdgeInsets.all(ShiftleyTokens.spaceL), children: [_buildHistoryItem('ITC Kohenur', 'APPROVED', '24 Oct 2023', 'Verified by GST & On-site visit'), _buildHistoryItem('Paradise Biryani', 'REJECTED', '22 Oct 2023', 'GST mismatch / Invalid Address')]))]);
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onSelect) {
    return GestureDetector(onTap: () async { final picked = await showDatePicker(context: context, initialDate: date ?? DateTime.now(), firstDate: DateTime(2023), lastDate: DateTime.now()); if (picked != null) onSelect(picked); }, child: Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: ShiftleyTokens.background, border: ShiftleyTokens.primaryBorder, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(date == null ? label : '${date.day}/${date.month}/${date.year}', style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.bold)), const Icon(Icons.calendar_today, size: 16)])));
  }

  Widget _buildHistoryItem(String name, String status, String date, String note) {
    final bool isApproved = status == 'APPROVED';
    return Container(margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM), padding: const EdgeInsets.all(ShiftleyTokens.spaceM), decoration: BoxDecoration(color: ShiftleyTokens.paperWhite, border: ShiftleyTokens.primaryBorder, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: ShiftleyTokens.bodyLarge), Text(note, style: ShiftleyTokens.caption), const SizedBox(height: 4), Text('Audited on $date', style: ShiftleyTokens.caption.copyWith(fontSize: 10))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isApproved ? Colors.green[50] : Colors.red[50], border: Border.all(color: isApproved ? Colors.green : Colors.red), borderRadius: BorderRadius.circular(4)), child: Text(status, style: TextStyle(color: isApproved ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold, fontSize: 10)))]));
  }

  Widget _buildStatusTabs() {
    return Container(width: double.infinity, decoration: const BoxDecoration(color: ShiftleyTokens.paperWhite, border: Border(bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 1.5))), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceL), child: Row(children: [_buildTab('Pending (12)', 0), _buildTab('In Progress (3)', 1), _buildTab('Completed (45)', 2)])));
  }

  Widget _buildTab(String label, int index) {
    final isActive = _activeTabIndex == index;
    return GestureDetector(onTap: () => setState(() => _activeTabIndex = index), child: Container(padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: 16), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isActive ? ShiftleyTokens.primaryRed : Colors.transparent, width: 3))), child: Text(label, style: TextStyle(color: isActive ? ShiftleyTokens.inkBlack : ShiftleyTokens.mutedText, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, fontSize: 13))));
  }

  Widget _buildQueueItem({required String id, required String name, required String details, required String status, required String time}) {
    return Container(margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceL), padding: const EdgeInsets.all(ShiftleyTokens.spaceL), decoration: BoxDecoration(color: ShiftleyTokens.paperWhite, border: ShiftleyTokens.primaryBorder, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)), child: Column(children: [Row(children: [Container(padding: const EdgeInsets.all(ShiftleyTokens.spaceS), decoration: BoxDecoration(color: ShiftleyTokens.secondaryCyan, border: Border.all(color: ShiftleyTokens.inkBlack, width: 1.5), shape: BoxShape.circle), child: const Icon(Icons.business_outlined, color: ShiftleyTokens.inkBlack, size: 20)), const SizedBox(width: ShiftleyTokens.spaceM), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: ShiftleyTokens.bodyLarge), const SizedBox(height: 2), Text('EMPLOYER • $details', style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(time, style: ShiftleyTokens.caption), const SizedBox(height: 4), _buildStatusChip(status)])]), const SizedBox(height: ShiftleyTokens.spaceXL), Row(children: [Expanded(child: OutlinedButton(onPressed: () => setState(() { _selectedEmployerId = id; _currentView = VerifierView.details; }), style: OutlinedButton.styleFrom(foregroundColor: ShiftleyTokens.inkBlack, side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 1.5), minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal))), child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))), const SizedBox(width: ShiftleyTokens.spaceM), Expanded(child: ElevatedButton(onPressed: () => setState(() { _selectedEmployerId = id; _verifyStep = 1; _currentView = VerifierView.verifyFlow; }), style: ElevatedButton.styleFrom(backgroundColor: ShiftleyTokens.inkBlack, foregroundColor: ShiftleyTokens.paperWhite, minimumSize: const Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal))), child: const Text('Verify Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))))])]));
  }

  Widget _buildStatusChip(String status) {
    final bool isInProgress = status == 'In Progress';
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: isInProgress ? ShiftleyTokens.secondaryCyan : ShiftleyTokens.background, border: Border.all(color: ShiftleyTokens.inkBlack, width: 1.0), borderRadius: BorderRadius.circular(4)), child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.inkBlack)));
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.primaryRed)), const SizedBox(height: ShiftleyTokens.spaceM), Container(width: double.infinity, padding: const EdgeInsets.all(ShiftleyTokens.spaceM), decoration: BoxDecoration(color: ShiftleyTokens.paperWhite, border: ShiftleyTokens.primaryBorder, borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)), child: Column(children: items))]);
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold))), Expanded(flex: 3, child: Text(value, style: ShiftleyTokens.bodyMedium))]));
  }

  Widget _buildDocumentItem(String label, String fileName) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(children: [const Icon(Icons.description_outlined, size: 20, color: ShiftleyTokens.mutedText), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)), Text(fileName, style: ShiftleyTokens.caption)])), TextButton(onPressed: () {}, child: const Text('VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)))]));
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
          Switch(value: val, onChanged: (v) {}, activeColor: ShiftleyTokens.secondaryCyan, activeTrackColor: ShiftleyTokens.inkBlack),
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
