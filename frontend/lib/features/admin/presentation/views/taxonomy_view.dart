import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_button.dart';
import '../providers/admin_providers.dart';
import '../../domain/admin_models.dart';

class TaxonomyView extends ConsumerStatefulWidget {
  const TaxonomyView({super.key});

  @override
  ConsumerState<TaxonomyView> createState() => _TaxonomyViewState();
}

class _TaxonomyViewState extends ConsumerState<TaxonomyView> {
  String _searchQuery = '';
  final Set<String> _expandedCategories = {};

  // Font Size Adjustments
  static const double _bodyFontSize = 16.0;
  static const double _statusFontSize = 11.0;

  @override
  Widget build(BuildContext context) {
    final taxonomyAsync = ref.watch(adminTaxonomyProvider);

    return taxonomyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed)),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (categories) {
        final filteredCategories = categories.where((cat) {
          final name = cat.name ?? '';
          final matchesCat = name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
          final matchesSub = cat.skills.any(
            (sub) => (sub.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase()),
          );
          return matchesCat || matchesSub;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Taxonomy', style: ShiftleyTokens.h2),
                ShiftleyButton(
                  label: 'Add New',
                  icon: Icons.add,
                  onPressed: () => _showTaxonomyDialog(),
                  size: ShiftleyButtonSize.small,
                ),
              ],
            ),
            const SizedBox(height: ShiftleyTokens.spaceL),

            // Search Bar
            _buildSearchBar(),

            const SizedBox(height: ShiftleyTokens.spaceL),

            if (filteredCategories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(ShiftleyTokens.spaceXL),
                  child: Text('No categories found.', style: ShiftleyTokens.bodyMedium),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCategories.length,
                separatorBuilder: (context, index) => const SizedBox(height: ShiftleyTokens.spaceM),
                itemBuilder: (context, index) => _buildCategoryCard(filteredCategories[index]),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 2.0),
        ),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        style: ShiftleyTokens.bodyMedium.copyWith(fontSize: _bodyFontSize),
        decoration: const InputDecoration(
          hintText: 'Search taxonomy...',
          prefixIcon: Icon(
            Icons.search,
            color: ShiftleyTokens.inkBlack,
            size: 22,
          ),
          border: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: ShiftleyTokens.primaryRed, width: 2.0),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: ShiftleyTokens.spaceS,
            vertical: ShiftleyTokens.spaceM,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category cat) {
    final bool isExpanded = _expandedCategories.contains(cat.id);
    
    return Container(
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCategories.remove(cat.id);
                } else {
                  _expandedCategories.add(cat.id);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (cat.name ?? '').toUpperCase(),
                          style: ShiftleyTokens.bodyLarge.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cat.skills.length} SUB-CATEGORIES',
                          style: ShiftleyTokens.caption.copyWith(
                            color: ShiftleyTokens.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(cat.isActive),
                  const SizedBox(width: ShiftleyTokens.spaceM),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showTaxonomyDialog(cat: cat),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: ShiftleyTokens.inkBlack,
                  ),
                ],
              ),
            ),
          ),
          
          if (isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: ShiftleyTokens.inkBlack),
            Container(
              color: ShiftleyTokens.background.withAlpha(50),
              child: Column(
                children: [
                  ...cat.skills.map((sub) => _buildSubcategoryRow(cat, sub)),
                  // Add Subcategory quick action
                  _buildAddSubcategoryRow(cat),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubcategoryRow(Category cat, Skill sub) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ShiftleyTokens.spaceM,
        vertical: ShiftleyTokens.spaceS,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ShiftleyTokens.utilityGrey, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.subdirectory_arrow_right, size: 16, color: ShiftleyTokens.mutedText),
          const SizedBox(width: ShiftleyTokens.spaceS),
          Expanded(
            child: Text(
              sub.name ?? '',
              style: ShiftleyTokens.bodyMedium,
            ),
          ),
          _buildStatusChip(sub.isActive, small: true),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: ShiftleyTokens.mutedText),
            onPressed: () => _showTaxonomyDialog(cat: cat, sub: sub),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSubcategoryRow(Category cat) {
    return InkWell(
      onTap: () => _showTaxonomyDialog(cat: cat, isAddingSub: true),
      child: Padding(
        padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, size: 16, color: ShiftleyTokens.primaryRed),
            const SizedBox(width: ShiftleyTokens.spaceS),
            Text(
              'ADD SUB-CATEGORY',
              style: ShiftleyTokens.caption.copyWith(
                color: ShiftleyTokens.primaryRed,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? ShiftleyTokens.secondaryCyan
            : ShiftleyTokens.primaryRed.withAlpha(26),
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isActive ? ShiftleyTokens.inkBlack : ShiftleyTokens.primaryRed,
          width: 1.0,
        ),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'DISABLED',
        style: ShiftleyTokens.caption.copyWith(
          color: isActive ? ShiftleyTokens.inkBlack : ShiftleyTokens.primaryRed,
          fontWeight: FontWeight.w700,
          fontSize: small ? _statusFontSize : _statusFontSize + 1,
        ),
      ),
    );
  }

  void _showTaxonomyDialog({
    Category? cat,
    Skill? sub,
    bool isAddingSub = false,
  }) {
    final nameController = TextEditingController(
      text: sub != null ? (sub.name ?? '') : (cat != null && !isAddingSub ? (cat.name ?? '') : ''),
    );
    bool isActive = sub != null
        ? sub.isActive
        : (cat != null && !isAddingSub ? cat.isActive : true);

    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ShiftleyTokens.paperWhite,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: ShiftleyTokens.inkBlack, width: 2),
          ),
          title: Text(
            isAddingSub 
              ? 'Add Sub-Category' 
              : (sub != null ? 'Edit Sub-Category' : (cat != null ? 'Edit Category' : 'Add New Category')),
            style: ShiftleyTokens.h2,
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAddingSub) ...[
                    Text('Category: ${(cat!.name ?? '').toUpperCase()}', style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: ShiftleyTokens.spaceM),
                    Text('Sub-Category Name', style: ShiftleyTokens.bodyLarge),
                    const SizedBox(height: ShiftleyTokens.spaceS),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      decoration: InputDecoration(
                        border: ShiftleyTokens.primaryInputBorder,
                        hintText: 'e.g. Graphic Designer',
                      ),
                    ),
                  ] else if (sub != null) ...[
                    Text('Sub-Category Name', style: ShiftleyTokens.bodyLarge),
                    const SizedBox(height: ShiftleyTokens.spaceS),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: ShiftleyTokens.primaryInputBorder,
                      ),
                    ),
                  ] else if (cat != null) ...[
                    Text('Category Name', style: ShiftleyTokens.bodyLarge),
                    const SizedBox(height: ShiftleyTokens.spaceS),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: ShiftleyTokens.primaryInputBorder,
                      ),
                    ),
                  ] else ...[
                    Text('New Category Name', style: ShiftleyTokens.bodyLarge),
                    const SizedBox(height: ShiftleyTokens.spaceS),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: ShiftleyTokens.primaryInputBorder,
                      ),
                    ),
                  ],
                  const SizedBox(height: ShiftleyTokens.spaceL),

                  Container(
                    decoration: BoxDecoration(
                      border: ShiftleyTokens.thinBorder,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: SwitchListTile(
                      title: const Text('STATUS (ACTIVE)', style: ShiftleyTokens.bodyMedium),
                      value: isActive,
                      onChanged: (val) => setDialogState(() => isActive = val),
                      activeThumbColor: ShiftleyTokens.primaryRed,
                      activeTrackColor: ShiftleyTokens.primaryRed.withAlpha(50),
                    ),
                  ),

                  const SizedBox(height: ShiftleyTokens.spaceL),
                  Text(
                    'Note: Deletion is not permitted. Disable to hide.',
                    style: ShiftleyTokens.caption.copyWith(
                      color: ShiftleyTokens.errorRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ShiftleyButton(
              label: 'CANCEL',
              onPressed: () => Navigator.pop(context),
              isPrimary: false,
              size: ShiftleyButtonSize.small,
            ),
            const SizedBox(width: ShiftleyTokens.spaceS),
            ShiftleyButton(
              label: isAddingSub ? 'ADD SUB-CATEGORY' : 'SAVE CHANGES',
              isLoading: isSubmitting,
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                
                setDialogState(() => isSubmitting = true);
                try {
                  if (isAddingSub) {
                    await ref.read(adminTaxonomyProvider.notifier).createSkill(cat!.id, nameController.text);
                  } else if (sub != null) {
                    await ref.read(adminTaxonomyProvider.notifier).updateSkill(sub.id, name: nameController.text, isActive: isActive);
                  } else if (cat != null) {
                    await ref.read(adminTaxonomyProvider.notifier).updateCategory(cat.id, name: nameController.text, isActive: isActive);
                  } else {
                    await ref.read(adminTaxonomyProvider.notifier).createCategory(nameController.text);
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                } finally {
                  setDialogState(() => isSubmitting = false);
                }
              },
              size: ShiftleyButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }
}
