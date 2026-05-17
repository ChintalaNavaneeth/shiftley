import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_text_field.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/features/employee/presentation/widgets/gig_details_sheet.dart';
import 'package:shiftley_frontend/shared/widgets/s_refreshable.dart';
import 'package:shiftley_frontend/features/employee/data/employee_repository.dart';
import 'package:shiftley_frontend/shared/domain/models/gig_models.dart';
import 'package:geolocator/geolocator.dart';

class ExploreGigsView extends ConsumerStatefulWidget {
  const ExploreGigsView({super.key});

  @override
  ConsumerState<ExploreGigsView> createState() => _ExploreGigsViewState();
}

class _ExploreGigsViewState extends ConsumerState<ExploreGigsView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'Distance: Near to Far';

  @override
  void initState() {
    super.initState();
    // Initialize controller with current search query if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = ref.read(gigSearchQueryProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationProvider);
    final gigsAsync = ref.watch(exploreGigsProvider);
    final selectedRadius = ref.watch(gigSearchRadiusProvider);

    return SRefreshable(
      onRefresh: () async {
        final _ = await ref.refresh(userLocationProvider.future);
        return ref.refresh(exploreGigsProvider.future);
      },
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filters
            STextField(
              hint: 'Search gigs, locations, or roles...',
              controller: _searchController,
              prefix: const Icon(Icons.search),
              onSubmitted: (val) {
                ref.read(gigSearchQueryProvider.notifier).state = val;
              },
              onChanged: (val) {
                if (val.isEmpty) {
                  ref.read(gigSearchQueryProvider.notifier).state = '';
                }
              },
            ),
            const SizedBox(height: ShiftleyTokens.spaceM),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('5 km', selectedRadius == 5.0, onTap: () => ref.read(gigSearchRadiusProvider.notifier).state = 5.0),
                  _buildFilterChip('10 km', selectedRadius == 10.0, onTap: () => ref.read(gigSearchRadiusProvider.notifier).state = 10.0),
                  _buildFilterChip('25 km', selectedRadius == 25.0, onTap: () => ref.read(gigSearchRadiusProvider.notifier).state = 25.0),
                  _buildFilterChip('50 km', selectedRadius == 50.0, onTap: () => ref.read(gigSearchRadiusProvider.notifier).state = 50.0),
                ],
              ),
            ),
            const SizedBox(height: ShiftleyTokens.spaceL),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gigs Near You', style: ShiftleyTokens.h2),
                _buildSortDropdown(),
              ],
            ),
            const SizedBox(height: ShiftleyTokens.spaceM),

            locationAsync.when(
              data: (pos) {
                if (pos == null) {
                  return _buildLocationPrompt(ref);
                }
                
                return gigsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text('Error: $err')),
                  ),
                  data: (gigs) {
                    if (gigs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.search_off, size: 48, color: ShiftleyTokens.mutedText),
                              SizedBox(height: 16),
                              Text('No gigs found in your current area.', style: ShiftleyTokens.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: gigs.map((gig) => _buildGigCard(context, gig)).toList(),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => _buildLocationPrompt(ref, error: 'Please enable location to find gigs'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPrompt(WidgetRef ref, {String? error}) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.location_off_rounded, size: 64, color: ShiftleyTokens.primaryRed),
            const SizedBox(height: 24),
            const Text(
              'Location Required',
              style: ShiftleyTokens.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'To find gigs near you, please enable location services and allow access.',
              style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ShiftleyButton(
              label: 'Grant Permission / Enable GPS',
              onPressed: () async {
                final enabled = await Geolocator.isLocationServiceEnabled();
                if (!enabled) {
                  await Geolocator.openLocationSettings();
                } else {
                  ref.refresh(userLocationProvider);
                }
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSortDropdown() {
    final List<String> options = [
      'Distance: Near to Far',
      'Payout: High to Low',
      'Payout: Low to High',
      'Employer Ratings',
    ];

    return Container(
      width: 190, // Explicit fixed width to prevent disappearing in Row
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSort,
          isExpanded: true, 
          icon: const Icon(Icons.sort, size: 16),
          style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold, color: ShiftleyTokens.inkBlack, fontSize: 11),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSort = newValue!;
            });
          },
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2), // Proper internal padding
        selected: isSelected,
        onSelected: (val) => onTap(),
        backgroundColor: ShiftleyTokens.paperWhite,
        selectedColor: ShiftleyTokens.secondaryCyan,
        checkmarkColor: ShiftleyTokens.inkBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: ShiftleyTokens.primaryBorderSide,
        ),
        labelStyle: ShiftleyTokens.caption.copyWith(
          color: ShiftleyTokens.inkBlack,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildGigCard(BuildContext context, Gig gig) {
    final payFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('MMM dd, hh:mm a');
    
    const rating = '4.8'; // Mocking rating for now
    final distance = gig.distanceMeters != null 
        ? '${(gig.distanceMeters! / 1000).toStringAsFixed(1)} km' 
        : '0.0 km';
    
    final employer = gig.businessName ?? 'Shiftley Partner';
    final industry = gig.businessType ?? 'Services';

    final timeString = "${dateFormatter.format(gig.startTime)} - ${DateFormat('hh:mm a').format(gig.endTime)}";

    return Container(
      margin: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
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
              Expanded(child: Text(gig.title, style: ShiftleyTokens.h2, overflow: TextOverflow.ellipsis)),
              Text('₹${payFormatter.format(gig.wagePerWorker / 100)}', style: ShiftleyTokens.h2.copyWith(color: Colors.green)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(gig.address, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.primaryRed)),
              const Spacer(),
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              const Text(rating, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text(timeString, style: ShiftleyTokens.caption),
              const Spacer(),
              const Icon(Icons.near_me_outlined, size: 14, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text(distance, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(gig.description, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: ShiftleyTokens.spaceM),
          ShiftleyButton(
            label: 'View Details & Apply',
            onPressed: () {
              showGigDetailsSheet(
                context,
                GigDetails(
                  id: gig.id,
                  title: gig.title,
                  location: gig.address,
                  time: timeString,
                  pay: '₹${payFormatter.format(gig.wagePerWorker / 100)}',
                  description: gig.description,
                  distance: distance,
                  rating: rating,
                  employerName: employer,
                  employerIndustry: industry,
                  latitude: gig.lat,
                  longitude: gig.lng,
                  photoUrls: gig.photoUrls,
                  businessType: gig.businessType,
                  myApplicationStatus: gig.myApplicationStatus,
                ),
              );
            },
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
