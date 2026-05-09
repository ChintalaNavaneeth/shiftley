import 'package:flutter/material.dart';
import '../../auth/presentation/auth_screen.dart';

class VerifierAuthScreen extends StatelessWidget {
  const VerifierAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen(isVerifierFlow: true);
  }
}
