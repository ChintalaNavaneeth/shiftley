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
  static const double _headerFontSize = 12.5;
  static const double _bodyFontSize = 16.0;
  static const double _subcatFontSize = 14.0;
  static const double _statusFontSize = 11.0;

  @override
  Widget build(BuildContext context) {
    final taxonomyAsync = ref.watch(adminTaxonomyProvider);

    return taxonomyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: ShiftleyTokens.primaryRed)),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (categories) {
        final filteredCategories = categories.where((cat) {
          final matchesCat = cat.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
          final matchesSub = cat.skills.any(
            (sub) => sub.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
          return matchesCat || matchesSub;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShiftleyButton(
                  label: 'Add Taxonomy',
                  icon: Icons.add,
                  onPressed: () => _showTaxonomyDialog(),
                  size: ShiftleyButtonSize.medium,
                ),
              ],
            ),
            const SizedBox(height: ShiftleyTokens.spaceL),

            // Search Bar
            _buildSearchBar(),

            const SizedBox(height: ShiftleyTokens.spaceXL),

            // Horizontal Scrollable Table
            LayoutBuilder(
              builder: (context, constraints) {
                double tableWidth = constraints.maxWidth > 900
                    ? constraints.maxWidth
                    : 900;
                return Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: _buildTable(filteredCategories),
                    ),
                  ),
                );
              },
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

  Widget _buildTable(List<Category> categories) {
    return Container(
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTableHeader(),
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(ShiftleyTokens.spaceXL),
              child: Text('No entries found.', style: ShiftleyTokens.bodyMedium),
            )
          else
            ...categories.expand(
              (cat) => [
                _buildCategoryRow(cat),
                if (_expandedCategories.contains(cat.id))
                  _buildSubcategoryList(cat),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: ShiftleyTokens.background,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
      decoration: const BoxDecoration(
        color: ShiftleyTokens.secondaryCyan,
        border: Border(
          bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 30),
          _vDivider(),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: _headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: ShiftleyTokens.mutedText,
                  fontFamily: 'Figtree',
                ),
              ),
            ),
          ),
          _vDivider(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'SUB - CATEGORY',
                style: TextStyle(
                  fontSize: _headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: ShiftleyTokens.mutedText,
                  fontFamily: 'Figtree',
                ),
              ),
            ),
          ),
          _vDivider(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'STATUS',
                style: TextStyle(
                  fontSize: _headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: ShiftleyTokens.mutedText,
                  fontFamily: 'Figtree',
                ),
              ),
            ),
          ),
          _vDivider(),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'ACTIONS',
                style: TextStyle(
                  fontSize: _headerFontSize,
                  fontWeight: FontWeight.bold,
                  color: ShiftleyTokens.mutedText,
                  fontFamily: 'Figtree',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(
      height: 18,
      width: 1,
      color: ShiftleyTokens.inkBlack.withValues(alpha: 0.1),
    );
  }

  Widget _buildCategoryRow(Category cat) {
    final bool isExpanded = _expandedCategories.contains(cat.id);
    final bool isActive = cat.isActive;

    return InkWell(
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
        padding: const EdgeInsets.symmetric(
          vertical: ShiftleyTokens.spaceL,
          horizontal: ShiftleyTokens.spaceM,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
            ),
            _vDivider(),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  cat.name,
                  style: ShiftleyTokens.bodyLarge.copyWith(
                    fontSize: _bodyFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _vDivider(),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  '${cat.skills.length}',
                  style: ShiftleyTokens.bodyMedium.copyWith(
                    fontSize: _bodyFontSize,
                  ),
                ),
              ),
            ),
            _vDivider(),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildStatusChip(isActive),
                ),
              ),
            ),
            _vDivider(),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: ShiftleyTokens.inkBlack,
                      ),
                      onPressed: () => _showTaxonomyDialog(cat: cat),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Edit Category',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryList(Category cat) {
    final List<Skill> subcats = cat.skills;
    return Container(
      color: ShiftleyTokens.background.withValues(alpha: 0.3),
      padding: const EdgeInsets.only(
        left: 45,
        right: ShiftleyTokens.spaceM,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        children: [
          ...subcats.map(
            (sub) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(
                    Icons.subdirectory_arrow_right,
                    size: 16,
                    color: ShiftleyTokens.mutedText,
                  ),
                  const SizedBox(width: ShiftleyTokens.spaceS),
                  Expanded(
                    flex: 3,
                    child: Text(
                      sub.name,
                      style: ShiftleyTokens.bodyMedium.copyWith(
                        fontSize: _subcatFontSize,
                      ),
                    ),
                  ),
                  const SizedBox(width: ShiftleyTokens.spaceM),
                  _vDivider(),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: _buildStatusChip(sub.isActive, small: true),
                      ),
                    ),
                  ),
                  const SizedBox(width: ShiftleyTokens.spaceM),
                  _vDivider(),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: ShiftleyTokens.mutedText,
                          ),
                          onPressed: () =>
                              _showTaxonomyDialog(cat: cat, sub: sub),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 1.0,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Disabled',
        style: ShiftleyTokens.caption.copyWith(
          color: isActive ? Colors.green[700] : Colors.red[700],
          fontWeight: FontWeight.w700,
          fontSize: small ? _statusFontSize : _statusFontSize + 1,
        ),
      ),
    );
  }

  void _showTaxonomyDialog({
    Category? cat,
    Skill? sub,
  }) {
    final nameController = TextEditingController(
      text: sub != null ? sub.name : (cat != null ? cat.name : ''),
    );
    final subNameController = TextEditingController();
    bool isActive = sub != null
        ? sub.isActive
        : (cat != null ? cat.isActive : true);

    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ShiftleyTokens.paperWhite,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
            side: const BorderSide(color: ShiftleyTokens.inkBlack, width: 2),
          ),
          title: Text(
            sub != null
                ? 'Edit Subcategory'
                : (cat != null ? 'Edit Category' : 'Add New Taxonomy'),
            style: ShiftleyTokens.h2,
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sub == null) ...[
                    Text('Category Name', style: ShiftleyTokens.bodyLarge),
                    const SizedBox(height: ShiftleyTokens.spaceS),
                    TextField(
                      controller: nameController,
                      enabled: cat == null,
                      style: ShiftleyTokens.bodyLarge.copyWith(
                        color: cat == null
                            ? ShiftleyTokens.inkBlack
                            : ShiftleyTokens.mutedText,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter category name',
                        filled: cat != null,
                        fillColor: cat != null
                            ? ShiftleyTokens.background
                            : Colors.transparent,
                        border: ShiftleyTokens.primaryInputBorder,
                        focusedBorder: ShiftleyTokens.focusInputBorder,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Editing Subcategory under: ${cat!.name}',
                      style: ShiftleyTokens.caption,
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceM),
                    Text('Subcategory Name', style: ShiftleyTokens.bodyLarge),
                    const SizedBox(height: ShiftleyTokens.spaceS),
                    TextField(
                      controller: nameController,
                      style: ShiftleyTokens.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Enter subcategory name',
                        border: ShiftleyTokens.primaryInputBorder,
                        focusedBorder: ShiftleyTokens.focusInputBorder,
                      ),
                    ),
                  ],
                  const SizedBox(height: ShiftleyTokens.spaceL),

                  Container(
                    decoration: BoxDecoration(
                      border: ShiftleyTokens.thinBorder,
                      borderRadius: BorderRadius.circular(
                        ShiftleyTokens.borderRadiusVal,
                      ),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Status (Active)',
                        style: ShiftleyTokens.bodyMedium,
                      ),
                      value: isActive,
                      onChanged: (val) => setDialogState(() => isActive = val),
                      activeThumbColor: ShiftleyTokens.primaryRed,
                    ),
                  ),

                  if (sub == null && cat != null) ...[
                    const SizedBox(height: ShiftleyTokens.spaceXL),
                    const Divider(color: ShiftleyTokens.inkBlack, thickness: 1),
                    const SizedBox(height: ShiftleyTokens.spaceM),
                    const Text(
                      'Manage Subcategories',
                      style: ShiftleyTokens.h2,
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceM),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: subNameController,
                            decoration: InputDecoration(
                              hintText: 'Add Subcategory...',
                              border: ShiftleyTokens.primaryInputBorder,
                              focusedBorder: ShiftleyTokens.focusInputBorder,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: ShiftleyTokens.spaceM,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: ShiftleyTokens.spaceM),
                        ShiftleyButton(
                          label: 'ADD',
                          onPressed: () async {
                            if (subNameController.text.isNotEmpty) {
                              try {
                                await ref.read(adminTaxonomyProvider.notifier).createSkill(cat.id, subNameController.text);
                                subNameController.clear();
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            }
                          },
                          size: ShiftleyButtonSize.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceM),

                    ...cat.skills.map(
                      (s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(ShiftleyTokens.spaceS),
                          decoration: BoxDecoration(
                            color: ShiftleyTokens.background,
                            borderRadius: BorderRadius.circular(
                              ShiftleyTokens.borderRadiusVal,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.subdirectory_arrow_right,
                                size: 14,
                              ),
                              const SizedBox(width: ShiftleyTokens.spaceM),
                              Expanded(
                                child: Text(
                                  s.name,
                                  style: ShiftleyTokens.bodyMedium,
                                ),
                              ),
                              _buildStatusChip(s.isActive, small: true),
                              const SizedBox(width: ShiftleyTokens.spaceS),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showTaxonomyDialog(cat: cat, sub: s);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

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
              label: 'SAVE CHANGES',
              isLoading: isSubmitting,
              onPressed: () async {
                setDialogState(() => isSubmitting = true);
                try {
                  if (sub != null) {
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
