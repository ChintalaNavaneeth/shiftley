import 'package:flutter/material.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import '../support_agent_screen.dart';

class SupportSidebar extends StatelessWidget {
  final SupportTab activeTab;
  final Function(SupportTab) onTabChanged;

  const SupportSidebar({
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(ShiftleyTokens.spaceXL, 64, ShiftleyTokens.spaceXL, ShiftleyTokens.spaceXL),
            decoration: const BoxDecoration(
              color: ShiftleyTokens.inkBlack,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shiftley.',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: ShiftleyTokens.paperWhite,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: ShiftleyTokens.spaceXL),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ShiftleyTokens.secondaryCyan,
                        border: Border.all(color: ShiftleyTokens.paperWhite, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 24, color: ShiftleyTokens.inkBlack),
                    ),
                    const SizedBox(width: ShiftleyTokens.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sarah K.',
                            style: TextStyle(color: ShiftleyTokens.paperWhite, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Figtree'),
                          ),
                          Text(
                            'Senior Support Agent',
                            style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.secondaryCyan, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          
          // Quick Stats Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY PERFORMANCE',
                  style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 10),
                ),
                const SizedBox(height: ShiftleyTokens.spaceM),
                Column(
                  children: [
                    Row(
                      children: [
                        _buildMiniStat('24', 'OPEN', Colors.blue),
                        const SizedBox(width: 8),
                        _buildMiniStat('08', 'NEW', ShiftleyTokens.primaryRed),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMiniStat('12m', 'AVG', Colors.green),
                        const SizedBox(width: 8),
                        _buildMiniStat('42', 'COMPLETED', ShiftleyTokens.secondaryCyan),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ShiftleyTokens.spaceL),
          const Divider(color: ShiftleyTokens.inkBlack, thickness: 1, indent: 16, endIndent: 16),
          const SizedBox(height: ShiftleyTokens.spaceM),
          _SidebarItem(
            icon: Icons.analytics_outlined,
            label: 'Overview',
            isActive: activeTab == SupportTab.overview,
            onTap: () => onTabChanged(SupportTab.overview),
          ),
          _SidebarItem(
            icon: Icons.history_outlined,
            label: 'Ticket History',
            isActive: activeTab == SupportTab.history,
            onTap: () => onTabChanged(SupportTab.history),
          ),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Agent Settings',
            isActive: activeTab == SupportTab.settings,
            onTap: () => onTabChanged(SupportTab.settings),
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

  Widget _buildMiniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: ShiftleyTokens.inkBlack, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Figtree')),
            Text(label, style: const TextStyle(color: ShiftleyTokens.inkBlack, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
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
