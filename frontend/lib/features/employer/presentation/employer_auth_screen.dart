import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class EmployerAuthScreen extends ConsumerStatefulWidget {
  const EmployerAuthScreen({super.key});

  @override
  ConsumerState<EmployerAuthScreen> createState() => _EmployerAuthScreenState();
}

class _EmployerAuthScreenState extends ConsumerState<EmployerAuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSignUp = true;
  bool _isWorker = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onGetOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final phoneNumber = '+91${_phoneController.text.trim()}';
        final role = _isWorker ? 'WORKER' : 'EMPLOYER';
        
        await ref.read(authProvider.notifier).sendOtp(
          phoneNumber,
          'PHONE',
          role,
        );

        if (mounted) {
          context.push('/otp', extra: {
            'phone': phoneNumber,
            'role': role,
            'isSignUp': _isSignUp,
          });
        }
      } catch (e) {
        String errorMsg = e.toString();
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map<String, dynamic> && data['error'] != null) {
            errorMsg = data['error']['message'] ?? errorMsg;
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: ShiftleyTokens.primaryRed,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        appBar: AppBar(
          backgroundColor: ShiftleyTokens.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ShiftleyTokens.inkBlack),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shiftley Business.',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: ShiftleyTokens.inkBlack,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceXL),
                      
                      // Toggle
                      Container(
                        decoration: BoxDecoration(
                          border: ShiftleyTokens.primaryBorder,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          children: [
                            _TabButton(
                              label: 'Sign In',
                              isActive: !_isSignUp,
                              onTap: () => setState(() => _isSignUp = false),
                            ),
                            _TabButton(
                              label: 'Sign Up',
                              isActive: _isSignUp,
                              onTap: () => setState(() => _isSignUp = true),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceXL),
                      
                      // Role Picker (SignUp only)
                      if (_isSignUp) ...[
                        const Text('I want to', style: ShiftleyTokens.h2),
                        const SizedBox(height: ShiftleyTokens.spaceM),
                        Row(
                          children: [
                            Expanded(
                              child: SButton(
                                text: 'Work',
                                type: _isWorker ? SButtonType.primary : SButtonType.secondary,
                                onPressed: () => setState(() => _isWorker = true),
                              ),
                            ),
                            const SizedBox(width: ShiftleyTokens.spaceM),
                            Expanded(
                              child: SButton(
                                text: 'Hire',
                                type: !_isWorker ? SButtonType.primary : SButtonType.secondary,
                                onPressed: () => setState(() => _isWorker = false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: ShiftleyTokens.spaceXL),
                      ],

                      // Removed heading and subtext
                      const SizedBox(height: ShiftleyTokens.spaceXL),
                      
                      // Input
                      const Text('Phone Number', style: ShiftleyTokens.bodyLarge),
                      const SizedBox(height: ShiftleyTokens.spaceS),
                      Center(
                        child: Pinput(
                          length: 10,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          defaultPinTheme: PinTheme(
                            width: 32,
                            height: 48,
                            textStyle: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 2.5)),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 32,
                            height: 48,
                            textStyle: ShiftleyTokens.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: ShiftleyTokens.primaryRed, width: 3.5)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceXL),
                      SButton(
                        text: 'Get Started →',
                        isLoading: _isLoading,
                        onPressed: _onGetOtp,
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceL),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceM),
          decoration: BoxDecoration(
            color: isActive ? ShiftleyTokens.inkBlack : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              label,
              style: ShiftleyTokens.buttonLabel.copyWith(
                color: isActive ? ShiftleyTokens.paperWhite : ShiftleyTokens.inkBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
