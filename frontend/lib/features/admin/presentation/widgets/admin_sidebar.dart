import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

enum AdminTab {
  overview,
  users,
  config,
  taxonomy,
  disputes,
  analytics,
}

class AdminSidebar extends StatelessWidget {
  final AdminTab activeTab;
  final Function(AdminTab) onTabChanged;

  const AdminSidebar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ShiftleyTokens.paperWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shiftley.',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: ShiftleyTokens.inkBlack,
                    letterSpacing: -1.0,
                  ),
                ),
                Text(
                  'Super Admin',
                  style: ShiftleyTokens.caption.copyWith(
                    color: ShiftleyTokens.primaryRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ShiftleyTokens.spaceM),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Overview',
            isActive: activeTab == AdminTab.overview,
            onTap: () => onTabChanged(AdminTab.overview),
          ),
          _SidebarItem(
            icon: Icons.people_outline,
            label: 'User Management',
            isActive: activeTab == AdminTab.users,
            onTap: () => onTabChanged(AdminTab.users),
          ),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Fees & Config',
            isActive: activeTab == AdminTab.config,
            onTap: () => onTabChanged(AdminTab.config),
          ),
          _SidebarItem(
            icon: Icons.category_outlined,
            label: 'Categories & Subcats',
            isActive: activeTab == AdminTab.taxonomy,
            onTap: () => onTabChanged(AdminTab.taxonomy),
          ),
          _SidebarItem(
            icon: Icons.gavel_outlined,
            label: 'Dispute Resolution',
            isActive: activeTab == AdminTab.disputes,
            onTap: () => onTabChanged(AdminTab.disputes),
          ),
          _SidebarItem(
            icon: Icons.analytics_outlined,
            label: 'Insights',
            isActive: activeTab == AdminTab.analytics,
            onTap: () => onTabChanged(AdminTab.analytics),
          ),
          const Spacer(),
          const Divider(color: ShiftleyTokens.inkBlack, thickness: 1),
          _SidebarItem(
            icon: Icons.logout,
            label: 'Logout',
            isActive: false,
            onTap: () {
              // Handle logout
            },
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ShiftleyTokens.spaceM,
        vertical: ShiftleyTokens.spaceXS,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: ShiftleyTokens.spaceM,
            vertical: ShiftleyTokens.spaceM,
          ),
          decoration: BoxDecoration(
            color: isActive ? ShiftleyTokens.secondaryCyan : Colors.transparent,
            border: isActive ? ShiftleyTokens.primaryBorder : null,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? ShiftleyTokens.inkBlack : ShiftleyTokens.mutedText,
                size: 20,
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Text(
                label,
                style: ShiftleyTokens.bodyMedium.copyWith(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? ShiftleyTokens.inkBlack : ShiftleyTokens.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
