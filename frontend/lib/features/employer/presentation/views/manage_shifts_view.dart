import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/features/employer/data/employer_repository.dart';
import 'package:shiftley_frontend/features/employer/domain/models/employer_models.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';
import 'package:intl/intl.dart';

enum ManageGigSubView { list, applications, details, profile, cancellationSuccess }

class ManageGigsView extends ConsumerStatefulWidget {
  final VoidCallback? onGoToSubscription;
  const ManageGigsView({super.key, this.onGoToSubscription});

  @override
  ConsumerState<ManageGigsView> createState() => _ManageGigsViewState();
}

class _ManageGigsViewState extends ConsumerState<ManageGigsView> {
  ManageGigSubView _subView = ManageGigSubView.list;
  Gig? _selectedGig;
  GigApplication? _selectedApplicant;
  double? _lastRefundAmount;

  @override
  Widget build(BuildContext context) {
    switch (_subView) {
      case ManageGigSubView.list:
        return _buildWithGate();
      case ManageGigSubView.applications:
        return _buildApplicationsView();
      case ManageGigSubView.details:
        return _buildDetailsView();
      case ManageGigSubView.profile:
        return _buildApplicantProfileView();
      case ManageGigSubView.cancellationSuccess:
        return _buildCancellationSuccessView();
    }
  }

  Widget _buildWithGate() {
    final dashboardAsync = ref.watch(employerDashboardProvider);
    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed)),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (EmployerDashboardData data) {
        final bool isVerified = data.profile.verificationStatus == 'VERIFIED';
        final bool hasSubscription = data.stats.activePlan != 'NONE';
        final bool hasCredits = data.stats.freeGigsRemaining > 0;
        final bool hasHistory = data.stats.totalGigsPosted > 0;

        if (!isVerified) {
          return _buildLockScreen(
            Icons.verified_user_outlined,
            'Verification Required',
            'Your business is pending verification. Once a verifier approves your profile, you can post and manage GIGs here.',
          );
        }

        // Show lock screen if no plan OR no credits left (and no history to manage)
        if ((!hasSubscription || !hasCredits) && !hasHistory) {
          return _buildLockScreen(
            Icons.card_membership_outlined,
            !hasSubscription ? 'Subscription Required' : 'No Credits Remaining',
            !hasSubscription 
              ? 'You need an active subscription plan to manage GIGs. Purchase a plan to unlock this section.'
              : 'You have used all GIG posts in your current plan. Please upgrade or top-up your subscription to post more GIGs.',
            actionLabel: !hasSubscription ? 'GO TO SUBSCRIPTION' : 'UPGRADE PLAN',
            onAction: widget.onGoToSubscription,
          );
        }

        return _buildListView();
      },
    );
  }

  Widget _buildLockScreen(IconData icon, String title, String message, {String? actionLabel, VoidCallback? onAction}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
              decoration: BoxDecoration(
                color: ShiftleyTokens.background,
                border: ShiftleyTokens.primaryBorder,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: ShiftleyTokens.primaryRed),
            ),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            Text(title, style: ShiftleyTokens.h1, textAlign: TextAlign.center),
            const SizedBox(height: ShiftleyTokens.spaceM),
            Text(
              message,
              style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.mutedText),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: ShiftleyTokens.spaceXXL),
              ShiftleyButton(
                label: actionLabel,
                onPressed: onAction ?? () {},
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final allGigsAsync = ref.watch(employerGigsProvider(null));

    return allGigsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(employerGigsProvider(null));
          return ref.read(employerGigsProvider(null).future).then((_) => null);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(child: Text('Error: $err')),
          ),
        ),
      ),
      data: (allGigs) {
        final activeGigs = allGigs.where((g) => ['DRAFT', 'OPEN', 'FILLED', 'RUNNING'].contains(g.status)).toList();
        final historyGigs = allGigs.where((g) => ['COMPLETED', 'CANCELLED'].contains(g.status)).toList();

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
                tabs: [
                  Tab(text: 'Active (${activeGigs.length})'),
                  Tab(text: 'History (${historyGigs.length})'),
                ],
              ),
              const SizedBox(height: ShiftleyTokens.spaceL),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildLocalGigList(activeGigs, 'Active'),
                    _buildLocalGigList(historyGigs, 'History'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocalGigList(List<Gig> gigs, String label) {
    Future<void> onRefresh() async {
      ref.invalidate(employerGigsProvider(null));
      // Optionally also invalidate dashboard if needed
      ref.invalidate(employerDashboardProvider);
      return ref.read(employerGigsProvider(null).future).then((_) => null);
    }

    if (gigs.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_off_outlined, size: 64, color: ShiftleyTokens.mutedText.withValues(alpha: 0.2)),
                    const SizedBox(height: ShiftleyTokens.spaceM),
                    Text('No $label Gigs Found', style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.mutedText)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: gigs.length,
        padding: const EdgeInsets.only(bottom: 80, top: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildGigCard(gigs[index], label.toUpperCase());
        },
      ),
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
                  Text('₹ ${gig.wagePerWorker / 100}', style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
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
          if (gig.status == 'DRAFT') ...[
            // Draft: show a prominent Publish Now action
            Container(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('This GIG is saved as a draft. Pay to publish it.', style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ShiftleyTokens.spaceM),
            ShiftleyButton(
              label: 'Publish Now',
              icon: Icons.payment,
              onPressed: () => _publishDraftGig(gig),
              isFullWidth: true,
              size: ShiftleyButtonSize.small,
            ),
          ] else if (listStatus != 'HISTORY') ...[
            const Divider(color: ShiftleyTokens.inkBlack, thickness: 1),
            const SizedBox(height: ShiftleyTokens.spaceM),
            Row(
              children: [
                Expanded(
                  child: ShiftleyButton(
                    label: 'Applicants',
                    onPressed: () => setState(() {
                      _subView = ManageGigSubView.applications;
                      _selectedGig = gig;
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
                      _selectedGig = gig;
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

  Future<void> _publishDraftGig(Gig gig) async {
    final totalAmount = (gig.wagePerWorker / 100.0) * gig.workersNeeded;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DraftPublishPaymentModal(
        gig: gig,
        totalAmount: totalAmount,
        onSuccess: (paymentId) async {
          Navigator.pop(ctx);
          try {
            await ref.read(employerRepositoryProvider).confirmGigPayment(gig.id);
            ref.invalidate(employerGigsProvider(null));
            ref.invalidate(employerDashboardProvider);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('GIG Published Successfully!'), backgroundColor: Colors.green),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to publish GIG: $e'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  Widget _buildApplicationsView() {
    final applicationsAsync = ref.watch(gigApplicationsProvider(_selectedGig!.id));

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
                  Expanded(child: Text('Applicants: ${_selectedGig!.title}', style: ShiftleyTokens.h2, overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: ShiftleyTokens.spaceL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('HIRED PROFESSIONALS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.mutedText)),
                  Text('${hired.length}/${_selectedGig!.workersNeeded}'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.primaryRed)),
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
    final bool isGigRunning = _selectedGig!.status == 'RUNNING';

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
      ref.invalidate(gigApplicationsProvider(_selectedGig!.id));
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
    final gig = _selectedGig!;
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
              Expanded(child: Text('Manage: ${gig.title}', style: ShiftleyTokens.h2, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          _buildDetailInfo('STATUS', gig.status),
          _buildDetailInfo('WAGE PER WORKER', '₹ ${gig.wagePerWorker / 100}'),
          _buildDetailInfo('WORKERS NEEDED', '${gig.workersNeeded} Professionals'),
          _buildDetailInfo('LOCATION', gig.address),
          _buildDetailInfo('START TIME', DateFormat('MMM dd, yyyy hh:mm a').format(gig.startTime)),
          _buildDetailInfo('END TIME', DateFormat('MMM dd, yyyy hh:mm a').format(gig.endTime)),
          const SizedBox(height: ShiftleyTokens.spaceXL),
          ShiftleyButton(
            label: 'Cancel GIG', 
            onPressed: () => _showCancelGigDialog(gig.id),
            isPrimary: true,
            isFullWidth: true,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  void _showCancelGigDialog(String gigId) {
    final gig = _selectedGig;
    if (gig == null) return;

    try {
      final dashboardData = ref.read(employerDashboardProvider).value;
      final config = dashboardData?.config;
      
      final totalEscrow = gig.wagePerWorker * gig.workersNeeded;
      final timeUntilStart = gig.startTime.difference(DateTime.now());
      
      String otpCode = '';
      bool otpSent = false;
      bool isSendingOtp = false;
      bool isVerifyingOtp = false;
      
      double penaltyPercent = 0;
      if (config != null) {
        if (timeUntilStart.inHours < 1) {
          penaltyPercent = config.employerCancelPenalty1h ?? 50.0;
        } else if (timeUntilStart.inHours < 3) {
          penaltyPercent = config.employerCancelPenalty3h ?? 25.0;
        } else if (timeUntilStart.inHours < 6) {
          penaltyPercent = config.employerCancelPenalty6h ?? 10.0;
        }
      } else {
        if (timeUntilStart.inHours < 1) {
          penaltyPercent = 50.0;
        } else if (timeUntilStart.inHours < 3) {
          penaltyPercent = 25.0;
        } else if (timeUntilStart.inHours < 6) {
          penaltyPercent = 10.0;
        }
      }

      final baseFine = (config?.employerCancelBaseFine ?? 100.0) * 100; // in Paise
      var penaltyAmount = (totalEscrow * (penaltyPercent / 100)).round() + baseFine.round();
      if (penaltyAmount > totalEscrow) penaltyAmount = totalEscrow;

      final refundAmount = totalEscrow - penaltyAmount;
      final formatter = NumberFormat('#,###');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: ShiftleyTokens.paperWhite,
            shape: RoundedRectangleBorder(
              side: ShiftleyTokens.primaryBorderSide,
              borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
            ),
            title: const Text('Cancel GIG?', style: ShiftleyTokens.h2),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.99,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Cancellation Fees include a fixed base fine plus a time-based penalty:', 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),
                    _buildPolicyRow('Base Fine (Fixed)', '₹ ${(config?.employerCancelBaseFine ?? 100.0).toInt()}'),
                    _buildPolicyRow('< 1 Hour', '${(config?.employerCancelPenalty1h ?? 50.0).toInt()}% Fee'),
                    _buildPolicyRow('< 3 Hours', '${(config?.employerCancelPenalty3h ?? 25.0).toInt()}% Fee'),
                    _buildPolicyRow('< 6 Hours', '${(config?.employerCancelPenalty6h ?? 10.0).toInt()}% Fee'),
                    _buildPolicyRow('> 6 Hours', '0% Fee'),
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
                          _buildRefundRow('Total Paid:', '₹ ${formatter.format(totalEscrow / 100)}'),
                          _buildRefundRow('Base Fine:', '- ₹ ${(config?.employerCancelBaseFine ?? 100.0).toInt()}'),
                          _buildRefundRow('Penalty ($penaltyPercent%):', '- ₹ ${formatter.format(((totalEscrow * (penaltyPercent / 100)).round()) / 100)}'),
                          const Divider(color: ShiftleyTokens.primaryRed),
                          _buildRefundRow('Total Refund:', '₹ ${formatter.format(refundAmount / 100)}', isBold: true),
                        ],
                      ),
                    ),
                    if (otpSent) ...[
                      const SizedBox(height: ShiftleyTokens.spaceL),
                      const Text('Enter OTP sent to your registered mobile:', style: ShiftleyTokens.caption),
                      const SizedBox(height: ShiftleyTokens.spaceM),
                      Center(
                        child: Pinput(
                          length: 6,
                          onChanged: (val) => setDialogState(() => otpCode = val),
                          autofocus: true,
                          defaultPinTheme: PinTheme(
                            width: 40,
                            height: 48,
                            textStyle: ShiftleyTokens.h2.copyWith(fontWeight: FontWeight.bold),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 2)),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 40,
                            height: 48,
                            textStyle: ShiftleyTokens.h2.copyWith(fontWeight: FontWeight.bold),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: ShiftleyTokens.primaryRed, width: 3)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: (isSendingOtp || isVerifyingOtp) ? null : () => Navigator.pop(context), 
                child: const Text('KEEP GIG')
              ),
              if (!otpSent)
                ShiftleyButton(
                  label: 'Send OTP', 
                  isLoading: isSendingOtp,
                  onPressed: isSendingOtp ? null : () async {
                    setDialogState(() => isSendingOtp = true);
                    try {
                        await ref.read(employerRepositoryProvider).requestCancelOTP(gig.id);
                        setDialogState(() {
                          otpSent = true;
                          isSendingOtp = false;
                        });
                    } catch (e) {
                        setDialogState(() => isSendingOtp = false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP: $e')));
                    }
                  }, 
                  size: ShiftleyButtonSize.small,
                )
              else
                ShiftleyButton(
                  label: 'Verify & Confirm', 
                  isLoading: isVerifyingOtp,
                  onPressed: (isVerifyingOtp || otpCode.length < 6) ? null : () async {
                    setDialogState(() => isVerifyingOtp = true);
                    try {
                      final repository = ref.read(employerRepositoryProvider);
                      await repository.verifyCancelAndConfirm(gig.id, otpCode, 'User Requested via App');
                      
                      ref.invalidate(employerGigsProvider(null));
                      ref.invalidate(employerDashboardProvider);
                      
                      if (!context.mounted) return;
                      
                      setState(() {
                        _lastRefundAmount = refundAmount / 100;
                        _subView = ManageGigSubView.cancellationSuccess;
                      });
                      Navigator.pop(context);
                    } catch (e) {
                       setDialogState(() => isVerifyingOtp = false);
                       if (!context.mounted) return;
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
                    }
                  }, 
                  size: ShiftleyButtonSize.small,
                  isPrimary: true,
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error preparing dialog: $e')));
    }
  }

  Widget _buildCancellationSuccessView() {
    return Padding(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          const SizedBox(height: ShiftleyTokens.spaceL),
          const Text('GIG Cancelled Successfully', style: ShiftleyTokens.h1, textAlign: TextAlign.center),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Text(
            'A refund of ₹${_lastRefundAmount?.toStringAsFixed(2) ?? "0.00"} will be credited to your original payment method within 24 working hours.',
            style: ShiftleyTokens.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          const Text(
            '1 Active GIG post credit has been added back to your subscription.',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ShiftleyTokens.spaceXXL),
          ShiftleyButton(
            label: 'BACK TO DASHBOARD',
            onPressed: () => setState(() => _subView = ManageGigSubView.list),
            isFullWidth: true,
          ),
        ],
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
    Color bgColor = ShiftleyTokens.background;
    Color textColor = ShiftleyTokens.inkBlack;

    switch (status) {
      case 'OPEN':
        bgColor = const Color(0xFFE3F2FD);
        textColor = Colors.blue.shade900;
        break;
      case 'FILLED':
        bgColor = const Color(0xFFE8F5E9);
        textColor = Colors.green.shade900;
        break;
      case 'RUNNING':
        bgColor = const Color(0xFFFFF3E0);
        textColor = Colors.orange.shade900;
        break;
      case 'COMPLETED':
        bgColor = const Color(0xFFF5F5F5);
        textColor = Colors.grey.shade700;
        break;
      case 'CANCELLED':
        bgColor = const Color(0xFFFFEBEE);
        textColor = ShiftleyTokens.primaryRed;
        break;
      case 'DRAFT':
        bgColor = ShiftleyTokens.background;
        textColor = ShiftleyTokens.mutedText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textColor),
      ),
    );
  }
}

// ──────────────────────────────────────────
// DRAFT PUBLISH PAYMENT MODAL
// ──────────────────────────────────────────
class _DraftPublishPaymentModal extends StatelessWidget {
  final Gig gig;
  final double totalAmount;
  final Function(String paymentId) onSuccess;

  const _DraftPublishPaymentModal({
    required this.gig,
    required this.totalAmount,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Dark header
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
                      const Text('RAZORPAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13)),
                      Text('Escrow for: ${gig.title}', style: const TextStyle(color: Colors.white60, fontSize: 11), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          // Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            color: const Color(0xFF02042B),
            child: Column(
              children: [
                const Text('TOTAL ESCROW AMOUNT', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text('₹ ${totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                Text('${gig.workersNeeded} worker${gig.workersNeeded > 1 ? 's' : ''} • Held in secure escrow until GIG completes', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          // Info + actions
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildRow('GIG Title', gig.title),
                      _buildRow('Workers Needed', '${gig.workersNeeded}'),
                      _buildRow('Pay per Worker', '₹ ${(gig.wagePerWorker / 100).toStringAsFixed(0)}'),
                      _buildRow('Status', 'DRAFT → will become OPEN after payment'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Center(child: Text('TEST MODE — No real payment charged', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_outline, size: 18, color: Colors.white),
                label: Text('PAY ₹ ${totalAmount.toStringAsFixed(0)} & PUBLISH', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShiftleyTokens.primaryRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
                ),
                onPressed: () => onSuccess('pay_mock_${DateTime.now().millisecondsSinceEpoch}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
