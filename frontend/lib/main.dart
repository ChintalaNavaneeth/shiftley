import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/landing_screen.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/otp_screen.dart';
import 'features/admin/presentation/super_admin_screen.dart';
import 'features/verifier/presentation/verifier_screen.dart';
import 'features/employer/presentation/employer_screen.dart';
import 'features/employee/presentation/employee_screen.dart';
import 'features/debug/presentation/dev_navigation_screen.dart';


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
      path: '/otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const SuperAdminScreen(),
    ),
    GoRoute(
      path: '/verifier',
      builder: (context, state) => const VerifierScreen(),
    ),
    GoRoute(
      path: '/employer',
      builder: (context, state) => const EmployerScreen(),
    ),
    GoRoute(
      path: '/employee',
      builder: (context, state) => const EmployeeScreen(),
    ),
  ],
);

void main() {
  runApp(const ProviderScope(child: ShiftleyApp()));
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
