import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import '../employee_screen.dart';

class EmployeeSidebar extends StatelessWidget {
  final EmployeeTab activeTab;
  final Function(EmployeeTab) onTabChanged;

  const EmployeeSidebar({
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
                  'PROFESSIONAL',
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
            isActive: activeTab == EmployeeTab.overview,
            onTap: () => onTabChanged(EmployeeTab.overview),
          ),
          _SidebarItem(
            icon: Icons.search,
            label: 'Explore Gigs',
            isActive: activeTab == EmployeeTab.explore,
            onTap: () => onTabChanged(EmployeeTab.explore),
          ),
          _SidebarItem(
            icon: Icons.assignment_outlined,
            label: 'My Shifts',
            isActive: activeTab == EmployeeTab.myGigs,
            onTap: () => onTabChanged(EmployeeTab.myGigs),
          ),
          _SidebarItem(
            icon: Icons.receipt_long_outlined,
            label: 'Transactions',
            isActive: activeTab == EmployeeTab.transactions,
            onTap: () => onTabChanged(EmployeeTab.transactions),
          ),
          _SidebarItem(
            icon: Icons.person_outline,
            label: 'My Profile',
            isActive: activeTab == EmployeeTab.profile,
            onTap: () => onTabChanged(EmployeeTab.profile),
          ),
          _SidebarItem(
            icon: Icons.support_agent_outlined,
            label: 'Support Hub',
            isActive: activeTab == EmployeeTab.support,
            onTap: () => onTabChanged(EmployeeTab.support),
          ),
          _SidebarItem(
            icon: Icons.help_outline_rounded,
            label: 'Help & FAQ',
            isActive: activeTab == EmployeeTab.faq,
            onTap: () => onTabChanged(EmployeeTab.faq),
          ),
          _SidebarItem(
            icon: Icons.notifications_none_outlined,
            label: 'Notifications',
            isActive: activeTab == EmployeeTab.notifications,
            onTap: () => onTabChanged(EmployeeTab.notifications),
          ),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isActive: activeTab == EmployeeTab.settings,
            onTap: () => onTabChanged(EmployeeTab.settings),
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
