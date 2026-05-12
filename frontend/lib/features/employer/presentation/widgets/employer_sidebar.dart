import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';
import 'package:shiftley_frontend/features/auth/data/auth_repository_provider.dart';
import 'package:shiftley_frontend/features/employer/data/employer_repository.dart';
import '../employer_screen.dart';

class EmployerSidebar extends ConsumerWidget {
  final EmployerTab activeTab;
  final Function(EmployerTab) onTabChanged;

  const EmployerSidebar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: ShiftleyTokens.paperWhite,
      child: SafeArea(
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
                  const SizedBox(height: 4),
                  Text(
                    'EMPLOYER',
                    style: ShiftleyTokens.caption.copyWith(
                      color: ShiftleyTokens.primaryRed,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: ShiftleyTokens.spaceL),
                  ref.watch(employerDashboardProvider).when(
                    loading: () => const LinearProgressIndicator(color: ShiftleyTokens.primaryRed),
                    error: (err, stack) => Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Failed to load profile', 
                            style: ShiftleyTokens.caption.copyWith(color: Colors.red, fontSize: 10)
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 16, color: ShiftleyTokens.secondaryCyan),
                          onPressed: () => ref.invalidate(employerDashboardProvider),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    data: (data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.profile.fullName, 
                          style: ShiftleyTokens.bodyMedium.copyWith(fontWeight: FontWeight.w900, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          data.profile.phoneNumber, 
                          style: ShiftleyTokens.caption.copyWith(fontSize: 10, color: ShiftleyTokens.mutedText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _SidebarItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                      isActive: activeTab == EmployerTab.overview,
                      onTap: () => onTabChanged(EmployerTab.overview),
                    ),
                    _SidebarItem(
                      icon: Icons.add_box_outlined,
                      label: 'Post a GIG',
                      isActive: activeTab == EmployerTab.post,
                      onTap: () => onTabChanged(EmployerTab.post),
                    ),
                    _SidebarItem(
                      icon: Icons.assignment_outlined,
                      label: 'Manage GIGS',
                      isActive: activeTab == EmployerTab.shifts,
                      onTap: () => onTabChanged(EmployerTab.shifts),
                    ),
                    _SidebarItem(
                      icon: Icons.card_membership_outlined,
                      label: 'Subscription',
                      isActive: activeTab == EmployerTab.subscription,
                      onTap: () => onTabChanged(EmployerTab.subscription),
                    ),
                    _SidebarItem(
                      icon: Icons.business_outlined,
                      label: 'Business Profile',
                      isActive: activeTab == EmployerTab.profile,
                      onTap: () => onTabChanged(EmployerTab.profile),
                    ),
                    _SidebarItem(
                      icon: Icons.support_agent_outlined,
                      label: 'Customer Support',
                      isActive: activeTab == EmployerTab.support,
                      onTap: () => onTabChanged(EmployerTab.support),
                    ),
                    _SidebarItem(
                      icon: Icons.help_outline,
                      label: 'Help & FAQ',
                      isActive: activeTab == EmployerTab.faq,
                      onTap: () => onTabChanged(EmployerTab.faq),
                    ),
                    _SidebarItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      isActive: activeTab == EmployerTab.settings,
                      onTap: () => onTabChanged(EmployerTab.settings),
                    ),
                    const SizedBox(height: ShiftleyTokens.spaceL),
                  ],
                ),
              ),
            ),
            
            // Bottom Section (Subscription + Logout)
            Column(
              children: [
                _buildSubscriptionStatus(ref),
                const Divider(color: ShiftleyTokens.inkBlack, thickness: 1, height: 1),
                _SidebarItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  isActive: false,
                  onTap: () async {
                    try {
                      await ref.read(authRepositoryProvider).logout();
                    } catch (e) {
                      debugPrint('Logout error: $e');
                    } finally {
                      await ref.read(tokenStorageProvider).clearTokens();
                      if (context.mounted) {
                        context.go('/landing');
                      }
                    }
                  },
                ),
                const SizedBox(height: ShiftleyTokens.spaceM),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionStatus(WidgetRef ref) {
    final dashboardAsync = ref.watch(employerDashboardProvider);
    
    return dashboardAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (data) {
        final bool hasPlan = data.stats.activePlan != 'NONE';
        if (!hasPlan) return const SizedBox.shrink();

        final String planLabel = data.stats.activePlan.replaceAll('_', ' ').toUpperCase();
        final DateTime? expiresAt = data.stats.planExpiresAt;
        
        return Container(
          margin: const EdgeInsets.all(ShiftleyTokens.spaceM),
          padding: const EdgeInsets.all(ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: ShiftleyTokens.inkBlack,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    planLabel, 
                    style: const TextStyle(color: ShiftleyTokens.secondaryCyan, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0)
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (expiresAt != null) ...[
                Text(
                  'Expires: ${expiresAt.day}/${expiresAt.month}/${expiresAt.year}', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                ),
                const SizedBox(height: 4),
                const Text('Active Plan', style: TextStyle(color: ShiftleyTokens.utilityGrey, fontSize: 10)),
              ] else ...[
                const Text('Active Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ],
          ),
        );
      },
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
