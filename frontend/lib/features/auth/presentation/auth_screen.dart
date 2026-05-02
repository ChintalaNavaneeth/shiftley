import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';
import 'package:shiftley_frontend/shared/widgets/s_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = true;
  bool _isWorker = true;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onGetOtp() {
    if (_formKey.currentState!.validate()) {
      context.push('/otp', extra: '+91${_phoneController.text.trim()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ShiftleyTokens.spaceL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shiftley',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: ShiftleyTokens.inkBlack,
                    letterSpacing: -1.0,
                  ),
                ),

                const SizedBox(height: ShiftleyTokens.spaceXL),

                // ── Sign In / Sign Up Toggle ───────────────────────
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

                // ── Role Picker (Sign Up only) ────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _isSignUp
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          key: const ValueKey('signup_roles'),
                          children: [
                            const Text('I want to', style: ShiftleyTokens.h2),
                            const SizedBox(height: ShiftleyTokens.spaceM),
                            Row(
                              children: [
                                Expanded(
                                  child: SButton(
                                    text: 'Employee',
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
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),

                // ── Phone Input ───────────────────────────────────
                const Text('Phone Number', style: ShiftleyTokens.bodyLarge),
                const SizedBox(height: ShiftleyTokens.spaceS),
                STextField(
                  hint: '9876543210',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  prefix: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ShiftleyTokens.spaceM,
                      vertical: ShiftleyTokens.spaceM,
                    ),
                    child: const Text('+91', style: ShiftleyTokens.bodyMedium),
                  ),
                  validator: (v) {
                    if (v == null || v.length != 10) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: ShiftleyTokens.spaceXL),

                // ── CTA Button ────────────────────────────────────
                SButton(
                  text: 'Get OTP →',
                  onPressed: _onGetOtp,
                ),
              ],
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
