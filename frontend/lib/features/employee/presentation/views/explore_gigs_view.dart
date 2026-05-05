import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_text_field.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import 'package:shiftley_frontend/features/employee/presentation/widgets/gig_details_sheet.dart';

class ExploreGigsView extends StatefulWidget {
  const ExploreGigsView({super.key});

  @override
  State<ExploreGigsView> createState() => _ExploreGigsViewState();
}

class _ExploreGigsViewState extends State<ExploreGigsView> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedRadius = 5;
  String _selectedSort = 'Distance: Near to Far';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and Filters
        STextField(
          hint: 'Search gigs, locations, or roles...',
          controller: _searchController,
          prefix: const Icon(Icons.search),
        ),
        const SizedBox(height: ShiftleyTokens.spaceM),
        
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('5 km', _selectedRadius == 5, onTap: () => setState(() => _selectedRadius = 5)),
              _buildFilterChip('10 km', _selectedRadius == 10, onTap: () => setState(() => _selectedRadius = 10)),
              _buildFilterChip('25 km', _selectedRadius == 25, onTap: () => setState(() => _selectedRadius = 25)),
              _buildFilterChip('50 km', _selectedRadius == 50, onTap: () => setState(() => _selectedRadius = 50)),
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

        Expanded(
          child: ListView(
            children: [
              _buildGigCard(
                context,
                'Kitchen Assistant',
                'ITC Kohenur, HITEC City',
                'Today, 06:00 PM - 11:00 PM',
                '₹600',
                'Immediate requirement. Must have basic kitchen skills.',
                '1.2 km',
                '4.8',
                'ITC Limited',
                'Hospitality',
              ),
              _buildGigCard(
                context,
                'Front Desk Support',
                'Park Hyatt, Banjara Hills',
                'May 07, 10:00 AM - 06:00 PM',
                '₹900',
                'Professional attire required. Excellent communication.',
                '3.5 km',
                '4.9',
                'Hyatt Hotels',
                'Hospitality',
              ),
              _buildGigCard(
                context,
                'Event Staff',
                'Novotel, Airport',
                'May 08, 04:00 PM - 12:00 AM',
                '₹1,200',
                'Helping with corporate event setup and guest handling.',
                '12.0 km',
                '4.7',
                'Accor Hotels',
                'Events',
              ),
              _buildGigCard(
                context,
                'Delivery Partner',
                'Local Hub, Jubilee Hills',
                'Ongoing • Flexible',
                '₹400/shift',
                'Bicycle or Two-wheeler required. Local area knowledge.',
                '0.8 km',
                '4.5',
                'QuickShip',
                'Logistics',
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildGigCard(BuildContext context, String title, String location, String time, String pay, String description, String distance, String rating, String employer, String industry) {
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
              Expanded(child: Text(title, style: ShiftleyTokens.h2, overflow: TextOverflow.ellipsis)),
              Text(pay, style: ShiftleyTokens.h2.copyWith(color: Colors.green)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(location, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.primaryRed)),
              const Spacer(),
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(rating, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text(time, style: ShiftleyTokens.caption),
              const Spacer(),
              const Icon(Icons.near_me_outlined, size: 14, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text(distance, style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: ShiftleyTokens.spaceM),
          ShiftleyButton(
            label: 'View Details & Apply',
            onPressed: () {
              showGigDetailsSheet(
                context,
                GigDetails(
                  title: title,
                  location: location,
                  time: time,
                  pay: pay,
                  description: description,
                  distance: distance,
                  rating: rating,
                  employerName: employer,
                  employerIndustry: industry,
                  latitude: 17.4435, // Mock coordinates (Hyderabad area)
                  longitude: 78.3772,
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
