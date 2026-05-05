import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:url_launcher/url_launcher.dart';

class GigDetails {
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

  GigDetails({
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
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ShiftleyTokens.inkBlack.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
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
                              ),
                              child: const Icon(Icons.business, size: 32),
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildLocationCard(context),
                          ),
                          const SizedBox(width: ShiftleyTokens.spaceM),
                          Expanded(
                            child: _buildInfoCard(Icons.access_time, 'Shift Time', gig.time),
                          ),
                        ],
                      ),
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
        const GigDetailsActionOverlay(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: ShiftleyTokens.mutedText),
              GestureDetector(
                onTap: () async {
                  final googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${gig.latitude},${gig.longitude}");
                  if (await canLaunchUrl(googleMapsUrl)) {
                    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ShiftleyTokens.secondaryCyan,
                    border: ShiftleyTokens.thinBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.map, size: 16, color: ShiftleyTokens.inkBlack),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Location', style: ShiftleyTokens.caption),
          const SizedBox(height: 4),
          Text(gig.location, style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
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
}

class GigDetailsActionOverlay extends StatelessWidget {
  const GigDetailsActionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: ShiftleyButton(
          label: 'Apply for this Shift',
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Application Submitted Successfully!')),
            );
          },
          isFullWidth: true,
          size: ShiftleyButtonSize.large,
        ),
      ),
    );
  }
}
