import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_text_field.dart';

class ExploreGigsView extends StatefulWidget {
  const ExploreGigsView({super.key});

  @override
  State<ExploreGigsView> createState() => _ExploreGigsViewState();
}

class _ExploreGigsViewState extends State<ExploreGigsView> {
  final TextEditingController _searchController = TextEditingController();

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
              _buildFilterChip('Nearby', true),
              _buildFilterChip('High Pay', false),
              _buildFilterChip('Housekeeping', false),
              _buildFilterChip('Hospitality', false),
              _buildFilterChip('Retail', false),
            ],
          ),
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),

        const Text('Available Gigs Near You', style: ShiftleyTokens.h2),
        const SizedBox(height: ShiftleyTokens.spaceM),

        Expanded(
          child: ListView(
            children: [
              _buildGigCard(
                'Kitchen Assistant',
                'ITC Kohenur, HITEC City',
                'Today, 06:00 PM - 11:00 PM',
                '₹600',
                'Immediate requirement. Must have basic kitchen skills.',
              ),
              _buildGigCard(
                'Front Desk Support',
                'Park Hyatt, Banjara Hills',
                'May 07, 10:00 AM - 06:00 PM',
                '₹900',
                'Professional attire required. Excellent communication.',
              ),
              _buildGigCard(
                'Event Staff',
                'Novotel, Airport',
                'May 08, 04:00 PM - 12:00 AM',
                '₹1,200',
                'Helping with corporate event setup and guest handling.',
              ),
              _buildGigCard(
                'Delivery Partner',
                'Local Hub, Jubilee Hills',
                'Ongoing • Flexible',
                '₹400/shift',
                'Bicycle or Two-wheeler required. Local area knowledge.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
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

  Widget _buildGigCard(String title, String location, String time, String pay, String description) {
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
          Text(location, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.primaryRed)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: ShiftleyTokens.mutedText),
              const SizedBox(width: 4),
              Text(time, style: ShiftleyTokens.caption),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.mutedText), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: ShiftleyTokens.spaceM),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: ShiftleyTokens.primaryBorderSide,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('View Details & Apply', style: TextStyle(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
