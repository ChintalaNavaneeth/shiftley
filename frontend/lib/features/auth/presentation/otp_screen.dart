import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';


class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
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

  void _onVerify() {
    if (_otpController.text.length == 6) {
      setState(() => _isVerifying = true);
      // Phase 4: wire up to auth_provider
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isVerifying = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Neo-brutalism pinput theme
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: ShiftleyTokens.h2,
      decoration: BoxDecoration(
        color: ShiftleyTokens.paperWhite,
        border: ShiftleyTokens.primaryBorder,
        borderRadius: BorderRadius.circular(ShiftleyTokens.borderRadiusVal),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: ShiftleyTokens.focusBorder,
      ),
    );

    return Scaffold(
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
        child: Padding(
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
                        onTap: _startTimer,
                        child: Text(
                          'Resend OTP',
                          style: ShiftleyTokens.caption.copyWith(
                            color: ShiftleyTokens.primaryRed,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
