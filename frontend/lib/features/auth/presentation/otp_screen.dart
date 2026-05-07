import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';
import 'providers/auth_provider.dart';
import '../domain/models/auth_models.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String role;
  final bool isSignUp;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.role,
    required this.isSignUp,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  int _secondsLeft = 60;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onVerify() async {
    if (_isVerifying) return;
    if (_otpController.text.length == 6) {
      setState(() => _isVerifying = true);
      try {
        final response = await ref.read(authProvider.notifier).verifyOtp(
          widget.phoneNumber,
          'PHONE',
          _otpController.text,
        );

        if (mounted) {
          final authData = AuthData.fromJson(response.data as Map<String, dynamic>);
          if (authData.isNewUser) {
            // Navigate to onboarding
            if (widget.role == 'WORKER') {
              context.go('/onboarding/employee');
            } else {
              context.go('/onboarding/employer');
            }
          } else {
            // Navigate to dashboard based on role
            if (widget.role == 'WORKER') {
              context.go('/employee');
            } else if (widget.role == 'EMPLOYER') {
              context.go('/employer');
            } else {
              if (authData.isInitialSetupComplete == false) {
                context.go('/admin/setup');
              } else {
                context.go('/admin');
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Otp Verification Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: ShiftleyTokens.primaryRed,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _onResend() async {
    try {
      await ref.read(authProvider.notifier).sendOtp(
        widget.phoneNumber,
        'PHONE',
        widget.role,
      );
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Resent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ShiftleyTokens.primaryRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Neo-brutalism pinput theme
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: ShiftleyTokens.h2.copyWith(fontWeight: FontWeight.bold),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 2.5)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ShiftleyTokens.primaryRed, width: 3.5)),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: ShiftleyTokens.background,
        appBar: AppBar(
          backgroundColor: ShiftleyTokens.background,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back, color: ShiftleyTokens.inkBlack),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: ShiftleyTokens.spaceL),

                    // ── Header ──────────────────────────────────────────
                    const Text('Verify Phone', style: ShiftleyTokens.h1),
                    const SizedBox(height: ShiftleyTokens.spaceS),
                    Text(
                      'OTP sent to ${widget.phoneNumber}',
                      style: ShiftleyTokens.caption,
                    ),

                    const SizedBox(height: ShiftleyTokens.spaceXL),

                    // ── OTP Input ────────────────────────────────────────
                    Center(
                      child: Pinput(
                        length: 6,
                        controller: _otpController,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        onCompleted: (_) => _onVerify(),
                      ),
                    ),

                    const SizedBox(height: ShiftleyTokens.spaceXL),

                    // ── Verify Button ────────────────────────────────────
                    SButton(
                      text: 'Verify OTP',
                      isLoading: _isVerifying,
                      onPressed: _onVerify,
                    ),

                    const SizedBox(height: ShiftleyTokens.spaceL),

                    // ── Resend Timer ─────────────────────────────────────
                    Center(
                      child: _secondsLeft > 0
                          ? Text(
                              'Resend OTP in ${_secondsLeft}s',
                              style: ShiftleyTokens.caption,
                            )
                          : GestureDetector(
                              onTap: _onResend,
                              child: Text(
                                'Resend OTP',
                                style: ShiftleyTokens.caption.copyWith(
                                  color: ShiftleyTokens.primaryRed,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
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
}
