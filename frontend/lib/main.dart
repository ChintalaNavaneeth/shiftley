import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftley_frontend/core/network/api_providers.dart';

import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/landing_screen.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/otp_screen.dart';
import 'features/admin/presentation/super_admin_screen.dart';
import 'features/admin/presentation/super_admin_setup_screen.dart';
import 'features/verifier/presentation/verifier_screen.dart';
import 'features/employer/presentation/employer_screen.dart';
import 'features/employee/presentation/employee_screen.dart';
import 'features/debug/presentation/dev_navigation_screen.dart';
import 'features/support/presentation/support_agent_screen.dart';
import 'features/verifier/presentation/verifier_auth_screen.dart';
import 'features/verifier/presentation/verifier_setup_screen.dart';
import 'features/admin/presentation/admin_auth_screen.dart';
import 'features/employer/presentation/employer_auth_screen.dart';


import 'features/auth/presentation/onboarding_screen.dart';

final _router = GoRouter(
  initialLocation: '/dev', // Temporary dev entry point
  routes: [
    GoRoute(
      path: '/dev',
      builder: (context, state) => const DevNavigationScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/admin/auth',
      builder: (context, state) => const AdminAuthScreen(),
    ),
    GoRoute(
      path: '/employer/auth',
      builder: (context, state) => const EmployerAuthScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return OtpScreen(
          phoneNumber: data['phone'] as String,
          role: data['role'] as String,
          isSignUp: data['isSignUp'] as bool,
        );
      },
    ),
    GoRoute(
      path: '/onboarding/employee',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '';
        return OnboardingScreen(role: 'WORKER', phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/onboarding/employer',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '';
        return OnboardingScreen(role: 'EMPLOYER', phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const SuperAdminScreen(),
    ),
    GoRoute(
      path: '/admin/setup',
      builder: (context, state) => const SuperAdminSetupScreen(),
    ),
    GoRoute(
      path: '/verifier',
      builder: (context, state) => const VerifierScreen(),
    ),
    GoRoute(
      path: '/verifier/auth',
      builder: (context, state) => const VerifierAuthScreen(),
    ),
    GoRoute(
      path: '/verifier/setup',
      builder: (context, state) => const VerifierSetupScreen(),
    ),
    GoRoute(
      path: '/employer',
      builder: (context, state) => const EmployerScreen(),
    ),
    GoRoute(
      path: '/employee',
      builder: (context, state) => const EmployeeScreen(),
    ),
    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportAgentScreen(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ShiftleyApp(),
    ),
  );
}

class ShiftleyApp extends StatelessWidget {
  const ShiftleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shiftley',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Figtree',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(elevation: 0),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(elevation: 0),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0000),
          surface: const Color(0xFFF5F5F5),
        ),
      ),
      routerConfig: _router,
    );
  }
}
