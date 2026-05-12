import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/features/employer/data/employer_repository.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';
import 'package:intl/intl.dart';

enum ManageGigSubView { list, applications, details, profile }

class ManageGigsView extends ConsumerStatefulWidget {
  const ManageGigsView({super.key});

  @override
  ConsumerState<ManageGigsView> createState() => _ManageGigsViewState();
}

class _ManageGigsViewState extends ConsumerState<ManageGigsView> {
  ManageGigSubView _subView = ManageGigSubView.list;
  String _selectedGigTitle = '';
  String _selectedGigId = '';
  String _selectedGigStatus = '';
  String _selectedGigWorkers = '';
  GigApplication? _selectedApplicant;

  @override
  Widget build(BuildContext context) {
    switch (_subView) {
      case ManageGigSubView.list:
        return _buildListView();
      case ManageGigSubView.applications:
        return _buildApplicationsView();
      case ManageGigSubView.details:
        return _buildDetailsView();
      case ManageGigSubView.profile:
        return _buildApplicantProfileView();
    }
  }

  Widget _buildListView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: ShiftleyTokens.inkBlack,
            unselectedLabelColor: ShiftleyTokens.mutedText,
            indicatorColor: ShiftleyTokens.primaryRed,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Active (16)'),
              Tab(text: 'History (85)'),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          Expanded(
            child: TabBarView(
              children: [
                _buildGigList('ACTIVE'),
                _buildGigList('HISTORY'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGigList(String status) {
    final gigsAsync = ref.watch(employerGigsProvider(status));

    return gigsAsync.when(
      data: (gigs) {
        if (gigs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_off_outlined, size: 64, color: ShiftleyTokens.mutedText.withValues(alpha: 0.2)),
                const SizedBox(height: ShiftleyTokens.spaceM),
                Text('No $status Gigs Found', style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.mutedText)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: gigs.length,
          padding: const EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            return _buildGigCard(gigs[index], status);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildGigCard(Gig gig, String listStatus) {
    final startTime = DateFormat('MMM dd, hh:mm a').format(gig.startTime);

    return Container(
      margin: EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      padding: EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(gig.title, style: ShiftleyTokens.h2, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              _buildStatusChip(gig.status),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceS),
          Text(startTime, style: ShiftleyTokens.caption),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PAYOUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  Text('₹ ${gig.wagePerWorker}', style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('GIG ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  Text(gig.id.substring(0, 8).toUpperCase(), style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: ShiftleyTokens.primaryRed)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('FILLED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  Text('0/${gig.workersNeeded}', style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          if (listStatus != 'HISTORY') ...[
            const Divider(color: ShiftleyTokens.inkBlack, thickness: 1),
            const SizedBox(height: ShiftleyTokens.spaceM),
            Row(
              children: [
                Expanded(
                  child: ShiftleyButton(
                    label: 'Applicants',
                    onPressed: () => setState(() {
                      _subView = ManageGigSubView.applications;
                      _selectedGigTitle = gig.title;
                      _selectedGigId = gig.id;
                      _selectedGigStatus = gig.status;
                      _selectedGigWorkers = '0/${gig.workersNeeded}';
                    }),
                    size: ShiftleyButtonSize.small,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: ShiftleyTokens.spaceM),
                Expanded(
                  child: ShiftleyButton(
                    label: 'Manage GIG',
                    onPressed: () => setState(() {
                      _subView = ManageGigSubView.details;
                      _selectedGigTitle = gig.title;
                      _selectedGigId = gig.id;
                      _selectedGigStatus = gig.status;
                      _selectedGigWorkers = '0/${gig.workersNeeded}';
                    }),
                    size: ShiftleyButtonSize.small,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApplicationsView() {
    final applicationsAsync = ref.watch(gigApplicationsProvider(_selectedGigId));

    return applicationsAsync.when(
      data: (apps) {
        final hired = apps.where((a) => a.status == 'APPROVED').toList();
        final available = apps.where((a) => a.status == 'APPLIED' || a.status == 'SHORTLISTED').toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _subView = ManageGigSubView.list),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Applicants: $_selectedGigTitle', style: ShiftleyTokens.h2, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: ShiftleyTokens.spaceL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('HIRED PROFESSIONALS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.mutedText)),
                  Text('${hired.length}/${_selectedGigWorkers.split('/')[1]}'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.primaryRed)),
                ],
              ),
              const SizedBox(height: 8),
              if (hired.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No professionals hired yet', style: ShiftleyTokens.caption)),
                )
              else
                ...hired.map((app) => _buildApplicationItem(app)),
              const SizedBox(height: ShiftleyTokens.spaceL),
              const Text('AVAILABLE APPLICANTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.mutedText)),
              const SizedBox(height: 8),
              if (available.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No pending applications', style: ShiftleyTokens.caption)),
                )
              else
                ...available.map((app) => _buildApplicationItem(app)),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildApplicationItem(GigApplication applicant) {
    final bool isHired = applicant.status == 'APPROVED';
    final bool isGigRunning = _selectedGigStatus == 'RUNNING';

    return GestureDetector(
      onTap: () => setState(() {
        _selectedApplicant = applicant;
        _subView = ManageGigSubView.profile;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
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
                CircleAvatar(
                  backgroundColor: ShiftleyTokens.secondaryCyan,
                  child: Text(applicant.employeeName?[0] ?? '?', style: const TextStyle(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: ShiftleyTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(applicant.employeeName ?? 'Professional', style: ShiftleyTokens.bodyLarge),
                      Text('${applicant.employeeRating ?? 0.0} ★', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ),
                ),
                if (!isHired)
                  ShiftleyButton(
                    label: 'Hire',
                    onPressed: () => _updateAppStatus(applicant.id, 'APPROVED'),
                    size: ShiftleyButtonSize.small,
                  ),
                if (isHired)
                  ShiftleyButton(
                    label: 'Unhire',
                    onPressed: () => _showUnhireDialog(applicant.id, applicant.employeeName ?? 'Professional'),
                    size: ShiftleyButtonSize.small,
                    isPrimary: false,
                  ),
              ],
            ),
            if (isHired && isGigRunning) ...[
              const SizedBox(height: ShiftleyTokens.spaceM),
              const Divider(thickness: 1),
              const SizedBox(height: ShiftleyTokens.spaceS),
              Row(
                children: [
                  Expanded(
                    child: ShiftleyButton(
                      label: 'QR Attendance',
                      icon: Icons.qr_code_scanner,
                      onPressed: () => _showQRScanner(context, applicant.employeeName ?? 'Professional'),
                      size: ShiftleyButtonSize.small,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ShiftleyButton(
                      label: 'No-Show',
                      onPressed: () => _showNoShowDialog(applicant.employeeName ?? 'Professional'),
                      size: ShiftleyButtonSize.small,
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateAppStatus(String id, String status) async {
    try {
      await ref.read(employerRepositoryProvider).updateApplicationStatus(id, status);
      ref.invalidate(gigApplicationsProvider(_selectedGigId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application $status successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showQRScanner(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: ShiftleyTokens.inkBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            Text('Scanning for $name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: ShiftleyTokens.primaryRed, width: 4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 150, color: Colors.white24),
              ),
            ),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            const Text('Align QR code within the frame', style: TextStyle(color: Colors.white70)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
              child: ShiftleyButton(
                label: 'Cancel',
                onPressed: () => Navigator.pop(context),
                isPrimary: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoShowDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShiftleyTokens.paperWhite,
        shape: RoundedRectangleBorder(
          side: ShiftleyTokens.primaryBorderSide,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        title: const Text('Mark No-Show', style: ShiftleyTokens.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Marking $name as No-Show. This will penalize the professional and open a slot for emergency hiring.'),
            const SizedBox(height: ShiftleyTokens.spaceL),
            Container(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
              decoration: BoxDecoration(
                color: ShiftleyTokens.secondaryCyan,
                border: ShiftleyTokens.primaryBorder,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: ShiftleyTokens.primaryRed),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Activate Emergency Hire to fill this slot immediately?', style: ShiftleyTokens.caption)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ShiftleyButton(label: 'Confirm & Emergency Hire', onPressed: () => Navigator.pop(context), size: ShiftleyButtonSize.small),
        ],
      ),
    );
  }

  void _showUnhireDialog(String applicationId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShiftleyTokens.paperWhite,
        shape: RoundedRectangleBorder(
          side: ShiftleyTokens.primaryBorderSide,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        title: const Text('Unhire Professional?', style: ShiftleyTokens.h2),
        content: Text('Are you sure you want to unhire $name? This slot will become available for other applicants.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ShiftleyButton(
            label: 'Yes, Unhire', 
            onPressed: () {
              Navigator.pop(context);
              _updateAppStatus(applicationId, 'APPLIED');
            }, 
            size: ShiftleyButtonSize.small, 
            isPrimary: true
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantProfileView() {
    final applicant = _selectedApplicant!;
    final bool isHired = applicant.status == 'APPROVED';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _subView = ManageGigSubView.applications),
              ),
              const SizedBox(width: 8),
              const Text('Professional Profile', style: ShiftleyTokens.h2),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          _buildProfileHeader(applicant),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShiftleyButton(
                  label: isHired ? 'Mark No-Show' : 'Hire Professional',
                  onPressed: () {
                    if (!isHired) {
                      _updateAppStatus(applicant.id, 'APPROVED');
                      setState(() => _subView = ManageGigSubView.applications);
                    } else {
                      _showNoShowDialog(applicant.employeeName ?? 'Professional');
                    }
                  },
                  isPrimary: !isHired,
                ),
                if (isHired) ...[
                  const SizedBox(width: 12),
                  ShiftleyButton(
                    label: 'Unhire',
                    onPressed: () {
                      _showUnhireDialog(applicant.id, applicant.employeeName ?? 'Professional');
                      setState(() => _subView = ManageGigSubView.applications);
                    },
                    isPrimary: false,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          _buildReliabilityStats(applicant),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          const Text('ABOUT / BIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Experienced hospitality professional with over 3 years of experience in banquet service and F&B operations. Highly reliable and verified.', style: ShiftleyTokens.bodyMedium),
          const SizedBox(height: ShiftleyTokens.spaceL),
          const Text('SKILLS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Skills info not available', style: ShiftleyTokens.caption),
          const SizedBox(height: ShiftleyTokens.spaceL),
          const Text('CERTIFICATIONS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _buildCertificationItem('Food Safety & Hygiene (FSSAI)', 'Valid until 2026'),
          _buildCertificationItem('Advanced Mixology Level 2', 'Issued by BSI'),
          const SizedBox(height: ShiftleyTokens.spaceL),
          const Text('WORK HISTORY & RATINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _buildWorkHistoryItem('Novotel Hyderabad', 'Mar 2024', '4.9 ★'),
          _buildWorkHistoryItem('Park Hyatt', 'Jan 2024', '4.7 ★'),
          _buildWorkHistoryItem('ITC Kohenur', 'Dec 2023', '5.0 ★'),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(GigApplication applicant) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: ShiftleyTokens.secondaryCyan,
            child: Text(applicant.employeeName?[0] ?? '?', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Text(applicant.employeeName ?? 'Professional', style: ShiftleyTokens.h1),
          Text('${applicant.employeeRating ?? 0.0} ★', style: const TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReliabilityStats(GigApplication applicant) {
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
          _buildStatBox('GIGS WORKED', '---'),
          Container(width: 2, height: 40, color: ShiftleyTokens.background),
          _buildStatBox('NO-SHOWS', '---'),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, {bool isAlert = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.mutedText)),
        const SizedBox(height: 4),
        Text(value, style: ShiftleyTokens.h2.copyWith(color: isAlert ? ShiftleyTokens.primaryRed : ShiftleyTokens.inkBlack)),
      ],
    );
  }

  Widget _buildWorkHistoryItem(String company, String date, String rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: 12),
      decoration: BoxDecoration(
        color: ShiftleyTokens.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: ShiftleyTokens.inkBlack.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(company, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text(date, style: ShiftleyTokens.caption),
            ],
          ),
          Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, color: ShiftleyTokens.inkBlack)),
        ],
      ),
    );
  }

  Widget _buildCertificationItem(String name, String detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: ShiftleyTokens.inkBlack.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text(detail, style: ShiftleyTokens.caption),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _subView = ManageGigSubView.list),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Manage: $_selectedGigTitle', style: ShiftleyTokens.h2, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          _buildDetailInfo('STATUS', 'Active & Publishing'),
          _buildDetailInfo('CATEGORY', 'Hospitality / Waitstaff'),
          _buildDetailInfo('WORKERS NEEDED', '5 Professionals'),
          _buildDetailInfo('LOCATION', 'Taj Banjara, Road No 1, Hyderabad'),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          ShiftleyButton(
            label: 'Cancel GIG', 
            onPressed: _showCancelGigDialog,
            isPrimary: true,
            isFullWidth: true,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  void _showCancelGigDialog() {
    bool otpSent = false;
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              backgroundColor: ShiftleyTokens.paperWhite,
              shape: RoundedRectangleBorder(
                side: ShiftleyTokens.primaryBorderSide,
                borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
              ),
              title: const Text('Cancel GIG?', style: ShiftleyTokens.h2),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cancellation Fees are calculated based on the time remaining before the GIG starts:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildPolicyRow('< 1 Hour', '50% Fee'),
                    _buildPolicyRow('< 2 Hours', '30% Fee'),
                    _buildPolicyRow('> 2 Hours', '10% Fee'),
                    const SizedBox(height: ShiftleyTokens.spaceM),
                    Container(
                      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: ShiftleyTokens.primaryRed),
                      ),
                      child: Column(
                        children: [
                          _buildRefundRow('Base Refund:', '₹ 2,400'),
                          _buildRefundRow('Cancellation Fine (30%):', '- ₹ 720'),
                          const Divider(color: ShiftleyTokens.primaryRed),
                          _buildRefundRow('Total Refund:', '₹ 1,680', isBold: true),
                        ],
                      ),
                    ),
                    if (otpSent) ...[
                      const SizedBox(height: ShiftleyTokens.spaceL),
                      const Text('Enter OTP sent to your registered mobile:', style: ShiftleyTokens.caption),
                      const SizedBox(height: 8),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'X X X X',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        autofocus: true,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('KEEP GIG')),
                if (!otpSent)
                  ShiftleyButton(
                    label: 'Send OTP to Cancel', 
                    onPressed: () => setDialogState(() => otpSent = true), 
                    size: ShiftleyButtonSize.small,
                  )
                else
                  ShiftleyButton(
                    label: 'Verify & Confirm', 
                    onPressed: () async {
                      try {
                        final repository = ref.read(employerRepositoryProvider);
                        await repository.cancelGig(_selectedGigId, 'User Requested');
                        ref.invalidate(employerGigsProvider('ACTIVE'));
                        if (!context.mounted) return;
                        
                        Navigator.pop(context);
                        setState(() => _subView = ManageGigSubView.list);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GIG Cancelled Successfully')));
                      } catch (e) {
                         if (!context.mounted) return;
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel GIG: $e'), backgroundColor: Colors.red));
                      }
                    }, 
                    size: ShiftleyButtonSize.small,
                    isPrimary: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyRow(String time, String fee) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(time, style: ShiftleyTokens.caption),
          Text(fee, style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRefundRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildDetailInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
          Text(value, style: ShiftleyTokens.bodyLarge),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status == 'RUNNING' ? Colors.green.shade100 : status == 'UPCOMING' ? ShiftleyTokens.secondaryCyan : ShiftleyTokens.background,
        border: Border.all(color: ShiftleyTokens.inkBlack, width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}
