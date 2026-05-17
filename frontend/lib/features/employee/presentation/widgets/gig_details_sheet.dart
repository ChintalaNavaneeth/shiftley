import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/features/employee/data/employee_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class GigDetails {
  final String id;
  final String title;
  final String location;
  final String time;
  final String pay;
  final String description;
  final String distance;
  final String rating;
  final String employerName;
  final String employerIndustry;
  final double latitude;
  final double longitude;
  final List<String>? photoUrls;
  final String? businessType;
  final String? myApplicationStatus;

  GigDetails({
    required this.id,
    required this.title,
    required this.location,
    required this.time,
    required this.pay,
    required this.description,
    required this.distance,
    required this.rating,
    required this.employerName,
    required this.employerIndustry,
    required this.latitude,
    required this.longitude,
    this.photoUrls,
    this.businessType,
    this.myApplicationStatus,
  });
}

void showGigDetailsSheet(BuildContext context, GigDetails gig) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => GigDetailsSheet(gig: gig),
  );
}

class GigDetailsSheet extends StatelessWidget {
  final GigDetails gig;

  const GigDetailsSheet({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              color: ShiftleyTokens.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: ShiftleyTokens.primaryBorderSide,
                left: ShiftleyTokens.primaryBorderSide,
                right: ShiftleyTokens.primaryBorderSide,
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ShiftleyTokens.inkBlack.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(height: ShiftleyTokens.spaceL),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(gig.title, style: ShiftleyTokens.heroLarge.copyWith(fontSize: 32)),
                                const SizedBox(height: ShiftleyTokens.spaceS),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ShiftleyTokens.secondaryCyan,
                                    border: ShiftleyTokens.primaryBorder,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    gig.pay,
                                    style: ShiftleyTokens.h2.copyWith(color: ShiftleyTokens.inkBlack),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceXL),

                      // Employer Section
                      _buildSectionTitle('Employer Details'),
                      const SizedBox(height: ShiftleyTokens.spaceM),
                      Container(
                        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
                        decoration: BoxDecoration(
                          color: ShiftleyTokens.paperWhite,
                          border: ShiftleyTokens.primaryBorder,
                          borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: ShiftleyTokens.utilityGrey,
                                border: ShiftleyTokens.primaryBorder,
                                borderRadius: BorderRadius.circular(8),
                                image: (gig.photoUrls != null && gig.photoUrls!.isNotEmpty)
                                    ? DecorationImage(
                                        image: NetworkImage(_getImageUrl(gig.photoUrls!.first)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (gig.photoUrls == null || gig.photoUrls!.isEmpty)
                                  ? const Icon(Icons.business, size: 32)
                                  : null,
                            ),
                            const SizedBox(width: ShiftleyTokens.spaceM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(gig.employerName, style: ShiftleyTokens.h2),
                                  Text(gig.employerIndustry, style: ShiftleyTokens.caption),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 18),
                                    const SizedBox(width: 4),
                                    Text(gig.rating, style: ShiftleyTokens.bodyLarge),
                                  ],
                                ),
                                const Text('Verified', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceM),

                      // Business Photos under Employer Details
                      if (gig.photoUrls != null && gig.photoUrls!.isNotEmpty)
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: gig.photoUrls!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 240,
                                margin: const EdgeInsets.only(right: ShiftleyTokens.spaceM),
                                decoration: BoxDecoration(
                                  border: ShiftleyTokens.primaryBorder,
                                  borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                                  image: DecorationImage(
                                    image: NetworkImage(_getImageUrl(gig.photoUrls![index])),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: ShiftleyTokens.spaceXL),

                      // Description
                      _buildSectionTitle('Job Description'),
                      const SizedBox(height: ShiftleyTokens.spaceM),
                      Text(
                        "${gig.description}\n\nWe are looking for dedicated professionals to join our team for this shift. Responsibilities include maintaining high standards of service, collaborating with existing staff, and ensuring a seamless experience for guests.\n\nRequirements:\n• Punctuality is mandatory\n• Professional attire\n• Basic understanding of safety protocols",
                        style: ShiftleyTokens.bodyMedium.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceXL),

                      // Location and Time
                      _buildLocationCard(context),
                      const SizedBox(height: ShiftleyTokens.spaceM),
                      _buildInfoCard(Icons.access_time, 'Shift Timings', gig.time),
                      const SizedBox(height: ShiftleyTokens.spaceXL),

                      // Reviews
                      _buildSectionTitle('Employer Reviews'),
                      const SizedBox(height: ShiftleyTokens.spaceM),
                      _buildReviewItem('Rahul S.', 'Excellent employer, paid on time and the work environment was professional.', 5),
                      _buildReviewItem('Ananya K.', 'Good experience. The manager was helpful.', 4),
                      _buildReviewItem('Vikram M.', 'Clear instructions provided. Would love to work again.', 5),
                      
                      const SizedBox(height: 120), // Space for button
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        GigDetailsActionOverlay(gig: gig),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: ShiftleyTokens.caption.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: ShiftleyTokens.primaryRed,
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return InkWell(
      onTap: () async {
        final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${gig.latitude},${gig.longitude}";
        final Uri uri = Uri.parse(googleMapsUrl);
        
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            // Fallback for some configurations
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        } catch (e) {
          debugPrint('Error launching maps: $e');
        }
      },
      borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      child: Container(
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
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 20, color: ShiftleyTokens.mutedText),
                    const SizedBox(width: 8),
                    Text('Work Location', style: ShiftleyTokens.caption),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/2991/2991147.png',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.map, size: 20, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              gig.location, 
              style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold), 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Tap for Directions', 
                  style: ShiftleyTokens.caption.copyWith(color: Colors.blue, fontWeight: FontWeight.bold)
                ),
                const SizedBox(width: 4),
                const Icon(Icons.directions, size: 14, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: ShiftleyTokens.mutedText),
          const SizedBox(height: 8),
          Text(label, style: ShiftleyTokens.caption),
          const SizedBox(height: 4),
          Text(value, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String comment, int rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.thinBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: ShiftleyTokens.bodyLarge),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  size: 14,
                  color: Colors.amber,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText)),
        ],
      ),
    );
  }

  String _getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    // The backend returns paths like /api/v1/storage/...
    // We need to prepend the host part of the API URL.
    const String host = 'http://192.168.1.6:8080';
    return '$host${path.startsWith('/') ? '' : '/'}$path';
  }
}

class GigDetailsActionOverlay extends ConsumerWidget {
  final GigDetails gig;
  const GigDetailsActionOverlay({super.key, required this.gig});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasApplied = gig.myApplicationStatus != null && 
        (gig.myApplicationStatus == 'APPLIED' || gig.myApplicationStatus == 'SHORTLISTED');
    
    final bool isApproved = gig.myApplicationStatus == 'APPROVED';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
        decoration: BoxDecoration(
          color: ShiftleyTokens.background,
          border: Border(top: ShiftleyTokens.primaryBorderSide),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasApplied)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your application is waiting for acceptance by the employer.',
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ShiftleyButton(
              label: isApproved 
                  ? 'Shift Approved' 
                  : (hasApplied ? 'Applied' : 'Apply for this Shift'),
              onPressed: (hasApplied || isApproved) ? null : () async {
                try {
                  await ref.read(employeeRepositoryProvider).applyForGig(gig.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application Submitted Successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to apply: ${e.toString()}')),
                    );
                  }
                }
              },
              isFullWidth: true,
              size: ShiftleyButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}
