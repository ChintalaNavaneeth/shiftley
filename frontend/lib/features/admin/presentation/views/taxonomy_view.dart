import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class TaxonomyView extends StatefulWidget {
  const TaxonomyView({super.key});

  @override
  State<TaxonomyView> createState() => _TaxonomyViewState();
}

class _TaxonomyViewState extends State<TaxonomyView> {
  String _searchQuery = '';
  final Set<String> _expandedCategories = {};

  // Mock data for UI development - In a real app, this would come from a Riverpod provider
  final List<Map<String, dynamic>> _categories = [
    {
      'id': '1',
      'name': 'Restaurant / F&B',
      'is_active': true,
      'subcategories': [
        {'id': 's1', 'name': 'Waiter / Server', 'is_active': true},
        {'id': 's2', 'name': 'Kitchen Helper', 'is_active': true},
        {'id': 's3', 'name': 'Dishwasher', 'is_active': false},
      ]
    },
    {
      'id': '2',
      'name': 'Retail / Store',
      'is_active': true,
      'subcategories': [
        {'id': 's4', 'name': 'Cashier', 'is_active': true},
        {'id': 's5', 'name': 'Sales Associate', 'is_active': true},
      ]
    },
    {
      'id': '3',
      'name': 'Logistics / Delivery',
      'is_active': false,
      'subcategories': [
        {'id': 's6', 'name': 'Delivery Partner', 'is_active': true},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _categories.where((cat) {
      final matchesCat = cat['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSub = (cat['subcategories'] as List).any((sub) => sub['name'].toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCat || matchesSub;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Taxonomy Management', style: ShiftleyTokens.h2),
            ElevatedButton.icon(
              onPressed: () => _showCategoryDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ShiftleyTokens.inkBlack,
                foregroundColor: ShiftleyTokens.paperWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
              ),
            ),
          ],
        ),
        const SizedBox(height: ShiftleyTokens.spaceL),
        _buildSearchBar(),
        const SizedBox(height: ShiftleyTokens.spaceL),
        _buildTable(filteredCategories),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: ShiftleyTokens.bodyMedium,
        decoration: const InputDecoration(
          hintText: 'Search categories or subcategories...',
          prefixIcon: Icon(Icons.search, color: ShiftleyTokens.inkBlack),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM, vertical: ShiftleyTokens.spaceM),
        ),
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> categories) {
    return Container(
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        child: Column(
          children: [
            // Header
            _buildTableHeader(),
            const Divider(height: 1, thickness: 2, color: ShiftleyTokens.inkBlack),
            // Rows
            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.all(ShiftleyTokens.spaceXL),
                child: Text('No categories found.', style: ShiftleyTokens.bodyMedium),
              )
            else
              ...categories.expand((cat) => [
                _buildCategoryRow(cat),
                if (_expandedCategories.contains(cat['id'])) _buildSubcategoryList(cat),
                const Divider(height: 1, thickness: 1, color: ShiftleyTokens.utilityGrey),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      color: ShiftleyTokens.secondaryCyan,
      child: Row(
        children: const [
          SizedBox(width: 40), // Expansion icon space
          Expanded(flex: 3, child: Text('CATEGORY NAME', style: ShiftleyTokens.buttonLabel)),
          Expanded(flex: 1, child: Text('SUBCATS', style: ShiftleyTokens.buttonLabel)),
          Expanded(flex: 1, child: Text('STATUS', style: ShiftleyTokens.buttonLabel)),
          Expanded(flex: 1, child: Text('ACTIONS', style: ShiftleyTokens.buttonLabel)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> cat) {
    final bool isExpanded = _expandedCategories.contains(cat['id']);
    final bool isActive = cat['is_active'];

    return InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedCategories.remove(cat['id']);
          } else {
            _expandedCategories.add(cat['id']);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        child: Row(
          children: [
            Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 20),
            const SizedBox(width: 20),
            Expanded(flex: 3, child: Text(cat['name'], style: ShiftleyTokens.bodyLarge)),
            Expanded(flex: 1, child: Text('${cat['subcategories'].length}', style: ShiftleyTokens.bodyMedium)),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildStatusChip(isActive),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: ShiftleyTokens.inkBlack),
                    onPressed: () => _showCategoryDialog(cat: cat),
                    tooltip: 'Edit Category',
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20, color: ShiftleyTokens.inkBlack),
                    onPressed: () => _showSubcategoryDialog(catID: cat['id']),
                    tooltip: 'Add Subcategory',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryList(Map<String, dynamic> cat) {
    final List subcats = cat['subcategories'];
    return Container(
      color: ShiftleyTokens.background.withOpacity(0.5),
      padding: const EdgeInsets.only(left: 60, right: ShiftleyTokens.spaceM, top: ShiftleyTokens.spaceS, bottom: ShiftleyTokens.spaceS),
      child: Column(
        children: [
          ...subcats.map((sub) => Padding(
            padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceXS),
            child: Row(
              children: [
                const Icon(Icons.subdirectory_arrow_right, size: 16, color: ShiftleyTokens.mutedText),
                const SizedBox(width: ShiftleyTokens.spaceM),
                Expanded(child: Text(sub['name'], style: ShiftleyTokens.bodyMedium)),
                const SizedBox(width: ShiftleyTokens.spaceM),
                _buildStatusChip(sub['is_active'], small: true),
                const SizedBox(width: ShiftleyTokens.spaceXL),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: ShiftleyTokens.mutedText),
                  onPressed: () => _showSubcategoryDialog(catID: cat['id'], sub: sub),
                ),
                const SizedBox(width: ShiftleyTokens.spaceXXL), // Align with actions column
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? ShiftleyTokens.spaceS : ShiftleyTokens.spaceM,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.green : Colors.red, width: 1.5),
      ),
      child: Text(
        isActive ? 'Active' : 'Disabled',
        style: ShiftleyTokens.caption.copyWith(
          color: isActive ? Colors.green[700] : Colors.red[700],
          fontWeight: FontWeight.w900,
          fontSize: small ? 9 : 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showCategoryDialog({Map<String, dynamic>? cat}) {
    final controller = TextEditingController(text: cat?['name'] ?? '');
    bool isActive = cat?['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ShiftleyTokens.paperWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
            side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 2),
          ),
          title: Text(cat == null ? 'Add New Category' : 'Edit Category', style: ShiftleyTokens.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: ShiftleyTokens.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: ShiftleyTokens.caption,
                  border: ShiftleyTokens.primaryInputBorder,
                  focusedBorder: ShiftleyTokens.focusInputBorder,
                ),
              ),
              const SizedBox(height: ShiftleyTokens.spaceM),
              Container(
                decoration: BoxDecoration(
                  border: ShiftleyTokens.thinBorder,
                  borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                ),
                child: SwitchListTile(
                  title: const Text('Status (Active)', style: ShiftleyTokens.bodyMedium),
                  value: isActive,
                  onChanged: (val) => setDialogState(() => isActive = val),
                  activeColor: ShiftleyTokens.primaryRed,
                ),
              ),
              if (cat != null)
                Padding(
                  padding: const EdgeInsets.only(top: ShiftleyTokens.spaceM),
                  child: Text(
                    'Note: Deleting is not permitted. Disable to hide.',
                    style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.errorRed, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: ShiftleyTokens.buttonLabel),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement API Call here
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ShiftleyTokens.inkBlack,
                foregroundColor: ShiftleyTokens.paperWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
              ),
              child: const Text('SAVE CHANGES', style: ShiftleyTokens.buttonLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubcategoryDialog({required String catID, Map<String, dynamic>? sub}) {
    final controller = TextEditingController(text: sub?['name'] ?? '');
    bool isActive = sub?['is_active'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ShiftleyTokens.paperWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
            side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 2),
          ),
          title: Text(sub == null ? 'Add Subcategory' : 'Edit Subcategory', style: ShiftleyTokens.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: ShiftleyTokens.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Subcategory Name',
                  labelStyle: ShiftleyTokens.caption,
                  border: ShiftleyTokens.primaryInputBorder,
                  focusedBorder: ShiftleyTokens.focusInputBorder,
                ),
              ),
              const SizedBox(height: ShiftleyTokens.spaceM),
              Container(
                decoration: BoxDecoration(
                  border: ShiftleyTokens.thinBorder,
                  borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
                ),
                child: SwitchListTile(
                  title: const Text('Status (Active)', style: ShiftleyTokens.bodyMedium),
                  value: isActive,
                  onChanged: (val) => setDialogState(() => isActive = val),
                  activeColor: ShiftleyTokens.primaryRed,
                ),
              ),
              if (sub != null)
                Padding(
                  padding: const EdgeInsets.only(top: ShiftleyTokens.spaceM),
                  child: Text(
                    'Note: Deleting is not permitted. Disable to hide.',
                    style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.errorRed, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: ShiftleyTokens.buttonLabel),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement API Call here
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ShiftleyTokens.inkBlack,
                foregroundColor: ShiftleyTokens.paperWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal)),
              ),
              child: const Text('SAVE CHANGES', style: ShiftleyTokens.buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
