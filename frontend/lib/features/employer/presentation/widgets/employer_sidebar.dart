import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import '../employer_screen.dart';

class EmployerSidebar extends StatelessWidget {
  final EmployerTab activeTab;
  final Function(EmployerTab) onTabChanged;

  const EmployerSidebar({
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
                  'EMPLOYER',
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
          
          const Spacer(),
          
          // Subscription Usage Widget in Sidebar
          _buildSubscriptionStatus(),

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

  Widget _buildSubscriptionStatus() {
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
              const Text('MONTHLY PRO', style: TextStyle(color: ShiftleyTokens.secondaryCyan, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0)),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Expires: May 18, 2024', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('at 11:59 PM', style: TextStyle(color: ShiftleyTokens.utilityGrey, fontSize: 10)),
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
