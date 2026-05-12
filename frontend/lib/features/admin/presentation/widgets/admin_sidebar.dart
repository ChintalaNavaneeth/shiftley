import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:shiftley_frontend/features/auth/presentation/providers/profile_provider.dart';

enum AdminTab {
  overview,
  users,
  config,
  taxonomy,
  disputes,
  analytics,
  settings,
}

class AdminSidebar extends ConsumerWidget {
  final AdminTab activeTab;
  final Function(AdminTab) onTabChanged;

  const AdminSidebar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                const SizedBox(height: ShiftleyTokens.spaceL),
                ref.watch(userProfileProvider).when(
                  loading: () => const LinearProgressIndicator(color: ShiftleyTokens.primaryRed),
                  error: (err, stack) => const SizedBox(),
                  data: (profile) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile['full_name'] ?? 'Super Admin', style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(profile['email'] ?? '', style: ShiftleyTokens.caption.copyWith(fontSize: 10)),
                    ],
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
            label: 'Taxonomy',
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
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'System Settings',
            isActive: activeTab == AdminTab.settings,
            onTap: () => onTabChanged(AdminTab.settings),
          ),
          const Spacer(),
          const Divider(color: ShiftleyTokens.inkBlack, thickness: 1),
          _SidebarItem(
            icon: Icons.logout,
            label: 'Logout',
            isActive: false,
            onTap: () async {
              // Confirm logout
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: ShiftleyTokens.paperWhite,
                  shape: const RoundedRectangleBorder(side: BorderSide(color: ShiftleyTokens.inkBlack, width: 2)),
                  title: const Text('Logout', style: ShiftleyTokens.h2),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel', style: TextStyle(color: ShiftleyTokens.inkBlack)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: ShiftleyTokens.primaryRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/dev');
                }
              }
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
