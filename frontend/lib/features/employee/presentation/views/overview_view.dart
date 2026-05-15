import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/features/employee/data/employee_repository.dart';
import 'package:shiftley_frontend/features/employee/domain/models/employee_models.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';

class OverviewView extends ConsumerWidget {
  const OverviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(employeeDashboardProvider);
    final formatter = NumberFormat('#,###');

    return RefreshIndicator(
      onRefresh: () => ref.refresh(employeeDashboardProvider.future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Next Shift Section
              const Text('Next Shift', style: ShiftleyTokens.h2),
              const SizedBox(height: ShiftleyTokens.spaceM),
              if (data.nextShift != null)
                _buildNextShiftCard(context, data.nextShift!)
              else
                _buildEmptyShiftCard(),
              const SizedBox(height: ShiftleyTokens.spaceXL),

              // Stats Table Section
              const Text('Performance Stats', style: ShiftleyTokens.h2),
              const SizedBox(height: ShiftleyTokens.spaceM),
              _buildStatsTable(data, formatter),
              const SizedBox(height: ShiftleyTokens.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyShiftCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 48, color: ShiftleyTokens.mutedText),
          const SizedBox(height: ShiftleyTokens.spaceM),
          Text('No upcoming shifts', style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.mutedText)),
          const SizedBox(height: ShiftleyTokens.spaceS),
          const Text('Explore and apply for gigs to get started!', style: ShiftleyTokens.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStatsTable(EmployeeDashboardData data, NumberFormat formatter) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        children: [
          _buildTablePair(
            'Total Gigs', '${data.totalGigs}', 
            'Total Earned', '₹${formatter.format(data.totalEarnedPaise / 100)}'
          ),
          const Divider(height: 1, color: ShiftleyTokens.inkBlack),
          _buildTablePair(
            'This Month', '₹${formatter.format(data.thisMonthEarnedPaise / 100)}', 
            'No Shows', '${data.noShows}'
          ),
          const Divider(height: 1, color: ShiftleyTokens.inkBlack),
          _buildTablePair(
            'Fines', '₹${formatter.format(data.activeFinePaise / 100)}', 
            'Avg Rating', '${data.overallRating} ★'
          ),
        ],
      ),
    );
  }

  Widget _buildTablePair(String label1, String value1, String label2, String value2) {
    return Row(
      children: [
        Expanded(child: _buildTableCell(label1, value1)),
        Container(width: 1, height: 60, color: ShiftleyTokens.inkBlack),
        Expanded(child: _buildTableCell(label2, value2)),
      ],
    );
  }

  Widget _buildTableCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShiftleyTokens.caption.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNextShiftCard(BuildContext context, Gig gig) {
    final timeFormatter = DateFormat('MMM dd, hh:mm a');
    final payFormatter = NumberFormat('#,###');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
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
              Expanded(child: Text(gig.title, style: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              Text('₹${payFormatter.format(gig.wagePerWorker / 100)}', style: ShiftleyTokens.h2.copyWith(color: Colors.green)),
            ],
          ),
          const SizedBox(height: ShiftleyTokens.spaceS),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Expanded(child: Text(gig.address, style: ShiftleyTokens.caption, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text('${timeFormatter.format(gig.startTime)} - ${DateFormat('hh:mm a').format(gig.endTime)}', style: ShiftleyTokens.caption),
            ],
          ),
          const Divider(height: ShiftleyTokens.spaceXL, color: ShiftleyTokens.inkBlack),
          
          const Text('JOB DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: ShiftleyTokens.primaryRed)),
          const SizedBox(height: 4),
          Text(gig.description, style: ShiftleyTokens.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: ShiftleyTokens.spaceM),
          ShiftleyButton(
            label: 'Check-In Details',
            onPressed: () => _showQrDialog(context, gig),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context, Gig gig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ShiftleyTokens.paperWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          side: ShiftleyTokens.primaryBorderSide,
          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        ),
        title: const Text('Check-In QR Code', style: ShiftleyTokens.h2),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Show this QR code to the employer at the shift location.', style: ShiftleyTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: ShiftleyTokens.spaceXL),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: ShiftleyTokens.primaryBorder,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: QrImageView(
                      data: 'shiftley://scan?gig=${gig.id}&action=CLOCK_IN',
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

