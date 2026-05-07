import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';
import 'package:shiftley_frontend/features/admin/data/admin_repository.dart';
import 'package:shiftley_frontend/features/auth/presentation/providers/auth_provider.dart';

class SuperAdminSetupScreen extends ConsumerStatefulWidget {
  const SuperAdminSetupScreen({super.key});

  @override
  ConsumerState<SuperAdminSetupScreen> createState() => _SuperAdminSetupScreenState();
}

class _SuperAdminSetupScreenState extends ConsumerState<SuperAdminSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+91';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.updateSuperAdminSetup(name, email, phone);

      if (!mounted) return;
      
      // Auto logout and show success
      await ref.read(authProvider.notifier).logout();
      
      if (!mounted) return;
      
      // Success Animation Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: ShiftleyTokens.paperWhite,
          shape: const RoundedRectangleBorder(side: BorderSide(color: ShiftleyTokens.inkBlack, width: 3)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              const SizedBox(height: ShiftleyTokens.spaceL),
              const Text(
                'ACCOUNT SETUP COMPLETE',
                style: ShiftleyTokens.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ShiftleyTokens.spaceM),
              const Text(
                'Your credentials have been updated. Please login again from the home screen.',
                style: ShiftleyTokens.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ShiftleyTokens.spaceXL),
              SButton(
                text: 'CONTINUE',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/dev');
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Super Admin Setup Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: ShiftleyTokens.primaryRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: ShiftleyTokens.spaceXL),
                    const Text(
                      'INITIAL SETUP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: ShiftleyTokens.inkBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceM),
                      const Text(
                        'Welcome, Root Admin. Please update your default credentials before accessing the dashboard.',
                        style: ShiftleyTokens.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceXL),

                      _buildTextField(
                        label: 'FULL NAME',
                        controller: _nameController,
                        hint: 'Enter your full name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceL),

                      _buildTextField(
                        label: 'EMAIL ADDRESS',
                        controller: _emailController,
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceL),

                      _buildTextField(
                        label: 'PHONE NUMBER',
                        controller: _phoneController,
                        hint: '+91XXXXXXXXXX',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceXL),

                      SButton(
                        text: 'COMPLETE SETUP',
                        isLoading: _isLoading,
                        onPressed: _submit,
                      ),
                      
                      const SizedBox(height: ShiftleyTokens.spaceL),
                      const Text(
                        'Note: You will be automatically logged out after completing this setup to verify your new credentials.',
                        style: ShiftleyTokens.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ShiftleyTokens.caption.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: ShiftleyTokens.spaceS),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: ShiftleyTokens.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: ShiftleyTokens.mutedText),
            border: ShiftleyTokens.primaryInputBorder,
            focusedBorder: ShiftleyTokens.focusInputBorder,
            filled: true,
            fillColor: ShiftleyTokens.background,
          ),
        ),
      ],
    );
  }
}
