import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/features/employer/data/employer_repository.dart';
import 'package:shiftley_frontend/features/employer/domain/models/employer_models.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';
import 'package:intl/intl.dart';
import 'attendance_view.dart';

class OverviewView extends ConsumerWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(employerDashboardProvider);

    return dashboardAsync.when(
      data: (data) {
        if (data.profile.verificationStatus == 'PENDING') {
          return _buildPendingScreen();
        }
        if (data.profile.verificationStatus == 'REJECTED') {
          return _buildRejectedScreen();
        }
        return _buildDashboard(context, ref, data);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, EmployerDashboardData data) {
    final gigsAsync = ref.watch(employerGigsProvider('OPEN'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: ShiftleyTokens.spaceM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Upcoming Shifts', style: ShiftleyTokens.h2),
            TextButton(
              onPressed: () {},
              child: const Text('View All', style: TextStyle(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceM),
        gigsAsync.when(
          data: (gigs) {
            if (gigs.isEmpty) {
              return const Center(child: Text('No upcoming shifts', style: ShiftleyTokens.caption));
            }
            return Column(
              children: gigs.take(5).map((gig) => _buildGigItem(context, gig)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading gigs: $err'),
        ),
      ],
    );
  }

  Widget _buildGigItem(BuildContext context, Gig gig) {
    final startTime = DateFormat('MMM dd, hh:mm a').format(gig.startTime);
    final workers = '${gig.workersNeeded} Worker${gig.workersNeeded > 1 ? 's' : ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendanceView(gigId: gig.id, shiftTitle: gig.title, shiftTime: startTime),
            ),
          );
        },
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        child: Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: ShiftleyTokens.paperWhite,
            border: ShiftleyTokens.primaryBorder,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ShiftleyTokens.spaceS),
                decoration: BoxDecoration(
                  color: ShiftleyTokens.background,
                  border: Border.all(color: ShiftleyTokens.inkBlack, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work_outline, size: 20),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gig.title, style: ShiftleyTokens.bodyLarge),
                    Text('$startTime • $workers', style: ShiftleyTokens.caption),
                  ],
                ),
              ),
              _buildStatusChip(gig.status),
              const SizedBox(width: ShiftleyTokens.spaceM),
              const Icon(Icons.chevron_right, color: ShiftleyTokens.mutedText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 80, color: ShiftleyTokens.primaryRed),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            const Text('VERIFICATION PENDING', style: ShiftleyTokens.h2, textAlign: TextAlign.center),
            const SizedBox(height: ShiftleyTokens.spaceM),
            const Text(
              'Your business profile is currently being reviewed by our auditors. This usually takes 24-48 hours.',
              style: ShiftleyTokens.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            Container(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
              decoration: BoxDecoration(
                color: ShiftleyTokens.secondaryCyan.withValues(alpha: 0.1),
                border: Border.all(color: ShiftleyTokens.secondaryCyan, width: 2),
                borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: ShiftleyTokens.secondaryCyan),
                  SizedBox(width: ShiftleyTokens.spaceM),
                  Expanded(
                    child: Text(
                      'You will be notified once your account is activated.',
                      style: TextStyle(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: ShiftleyTokens.primaryRed),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            const Text('VERIFICATION REJECTED', style: ShiftleyTokens.h2, textAlign: TextAlign.center),
            const SizedBox(height: ShiftleyTokens.spaceM),
            const Text(
              'Unfortunately, your business verification was not successful. Please review the comments below or contact support.',
              style: ShiftleyTokens.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ShiftleyTokens.spaceXL),
            SButton(
              text: 'CONTACT SUPPORT',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStatusChip(String status) {
    Color bgColor = ShiftleyTokens.background;
    if (status == 'OPEN') bgColor = const Color(0xFFE3F2FD);
    if (status == 'FILLED') bgColor = const Color(0xFFE8F5E9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
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
