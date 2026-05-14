import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class AdminAuthScreen extends ConsumerStatefulWidget {
  const AdminAuthScreen({super.key});

  @override
  ConsumerState<AdminAuthScreen> createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends ConsumerState<AdminAuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
        // Admin portal usually allows both ADMIN and SUPER_ADMIN
        const role = 'ADMIN'; 
        
        await ref.read(authProvider.notifier).sendOtp(
          phoneNumber,
          'PHONE',
          role,
        );

        if (mounted) {
          context.push('/otp', extra: {
            'phone': phoneNumber,
            'role': role,
            'isSignUp': false, // Admin login only, no public signup
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
                        'Shiftley Admin.',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: ShiftleyTokens.inkBlack,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: ShiftleyTokens.spaceXL),
                      
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
                        text: 'Get Admin OTP →',
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
