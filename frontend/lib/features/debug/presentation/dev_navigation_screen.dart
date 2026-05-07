import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class DevNavigationScreen extends StatelessWidget {
  const DevNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Shiftley.',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: ShiftleyTokens.inkBlack,
                      letterSpacing: -2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ShiftleyTokens.spaceS),
                  Text(
                    'Dev Navigation & Implementation Check',
                    style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.primaryRed),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ShiftleyTokens.spaceXXL),
                  
                  _DevButton(
                    label: 'Launch App Flow (Wireframe)',
                    path: '/',
                    icon: Icons.rocket_launch,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: ShiftleyTokens.spaceL),

                  _DevButton(
                    label: 'Splash Screen',
                    path: '/',
                    icon: Icons.flash_on,
                  ),
                  _DevButton(
                    label: 'Landing Page',
                    path: '/landing',
                    icon: Icons.home_outlined,
                  ),
                  _DevButton(
                    label: 'Authentication (Sign Up/In)',
                    path: '/auth',
                    icon: Icons.login,
                  ),
                  _DevButton(
                    label: 'OTP Screen (Direct)',
                    path: '/otp',
                    icon: Icons.pin_outlined,
                    extra: {'phone': '+919876543210', 'role': 'WORKER', 'isSignUp': true},
                  ),
                  const Divider(height: ShiftleyTokens.spaceXXL, thickness: 2, color: ShiftleyTokens.inkBlack),
                  _DevButton(
                    label: 'Super Admin Dashboard',
                    path: '/admin',
                    icon: Icons.admin_panel_settings_outlined,
                    color: ShiftleyTokens.secondaryCyan,
                  ),
                  _DevButton(
                    label: 'Super Admin Setup',
                    path: '/admin/setup',
                    icon: Icons.settings_suggest_outlined,
                    color: ShiftleyTokens.secondaryCyan,
                  ),
                  _DevButton(
                    label: 'Verifier Dashboard',
                    path: '/verifier',
                    icon: Icons.verified_user_outlined,
                    color: ShiftleyTokens.secondaryCyan,
                  ),
                  _DevButton(
                    label: 'Employer Dashboard',
                    path: '/employer',
                    icon: Icons.business_center_outlined,
                    color: ShiftleyTokens.secondaryCyan,
                  ),
                  _DevButton(
                    label: 'Employee Dashboard',
                    path: '/employee',
                    icon: Icons.person_outline,
                    color: ShiftleyTokens.secondaryCyan,
                  ),
                  _DevButton(
                    label: 'Support Dashboard (CS)',
                    path: '/support',
                    icon: Icons.support_agent_outlined,
                    color: ShiftleyTokens.secondaryCyan,
                  ),
                  const SizedBox(height: ShiftleyTokens.spaceXXL),
                  Text(
                    'Current Environment: Development',
                    style: ShiftleyTokens.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DevButton extends StatelessWidget {
  final String label;
  final String path;
  final IconData icon;
  final Color? color;
  final dynamic extra;

  const _DevButton({
    required this.label,
    required this.path,
    required this.icon,
    this.color,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ShiftleyTokens.spaceM),
      child: InkWell(
        onTap: () => context.push(path, extra: extra),
        child: Container(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
          decoration: BoxDecoration(
            color: color ?? ShiftleyTokens.paperWhite,
            border: ShiftleyTokens.primaryBorder,
            borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
            boxShadow: const [
              BoxShadow(
                color: ShiftleyTokens.inkBlack,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: ShiftleyTokens.inkBlack),
              const SizedBox(width: ShiftleyTokens.spaceM),
              Expanded(
                child: Text(
                  label,
                  style: ShiftleyTokens.h2,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: ShiftleyTokens.spaceM),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
