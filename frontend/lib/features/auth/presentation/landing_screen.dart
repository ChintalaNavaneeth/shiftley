import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';
import 'package:shiftley_frontend/shared/widgets/s_button.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isWorkerFlow = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftleyTokens.background,
      appBar: _buildNavBar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Support team work in development')),
          );
        },
        backgroundColor: ShiftleyTokens.inkBlack,
        shape: const CircleBorder(),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        disabledElevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.chat_bubble_outline, color: ShiftleyTokens.paperWhite),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero Section (With Animated Wave Background) ─────────
              Stack(
                children: [
                  Positioned.fill(child: const _WaveBackground()),

                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Padding(
                        padding: const EdgeInsets.all(ShiftleyTokens.spaceXL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: ShiftleyTokens.spaceXL),
                            const Text(
                              'Connecting reliable employees with verified businesses. Seamlessly.',
                              style: ShiftleyTokens.heroLarge,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: ShiftleyTokens.spaceM),
                            Text(
                              'We built Shiftley because finding gigs—and reliable people—shouldn\'t be complicated. No hidden fees. Complete transparency. Just a system that works.',
                              style: ShiftleyTokens.bodyLarge.copyWith(height: 1.5, color: ShiftleyTokens.mutedText),
                            ),
                            const SizedBox(height: ShiftleyTokens.spaceXL),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Animated Dotted Stepper (Full Width Container) ─────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ShiftleyTokens.secondaryCyan.withValues(alpha: 0.3),
                  border: const Border(top: BorderSide(color: ShiftleyTokens.inkBlack, width: 2.0)),
                ),
                padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceXL),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceXL),
                      child: Column(
                        children: [
                          // ── Toggle Flow Section ──────────────────────────────────
                          Center(
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 400),
                              decoration: BoxDecoration(
                                color: ShiftleyTokens.paperWhite,
                                border: ShiftleyTokens.primaryBorder,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _ToggleButton(
                                      label: 'To Work',
                                      isActive: _isWorkerFlow,
                                      onTap: () => setState(() => _isWorkerFlow = true),
                                    ),
                                  ),
                                  Expanded(
                                    child: _ToggleButton(
                                      label: 'To Hire',
                                      isActive: !_isWorkerFlow,
                                      onTap: () => setState(() => _isWorkerFlow = false),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: ShiftleyTokens.spaceXL),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: <Widget>[
                                  ...previousChildren,
                                  ?currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              // Sideways transition based on the key
                              final isWorker = (child.key as ValueKey<String>).value == 'worker';
                              final offsetBegin = isWorker ? const Offset(-0.5, 0) : const Offset(0.5, 0);
                              
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(begin: offsetBegin, end: Offset.zero).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _isWorkerFlow ? _buildWorkerFlow() : _buildEmployerFlow(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Escrow Details (Full Width Container) ──────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ShiftleyTokens.paperWhite,
                  border: Border(top: BorderSide(color: ShiftleyTokens.inkBlack, width: 2.0)),
                ),
                padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceXL),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceXL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: ShiftleyTokens.h1,
                              children: const [
                                TextSpan(text: 'Razorpay ', style: TextStyle(color: Colors.blue)),
                                TextSpan(text: 'Secure Payments: Because Trust Matters'),
                              ],
                            ),
                          ),

                          const SizedBox(height: ShiftleyTokens.spaceM),

                          RichText(
                            text: TextSpan(
                              style: ShiftleyTokens.bodyLarge.copyWith(height: 1.5, color: ShiftleyTokens.mutedText, fontFamily: 'Figtree'),
                              children: [
                                const TextSpan(text: 'When a gig is confirmed, the employer pays upfront into a secure Razorpay holding account. \n\n'),
                                TextSpan(
                                  text: 'For Employees: ',
                                  style: TextStyle(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: 'You know the money is locked and waiting for you. No more chasing payments after a long day of work.\n\n'),
                                TextSpan(
                                  text: 'For Employers: ',
                                  style: TextStyle(color: ShiftleyTokens.inkBlack, fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: 'You have the security of knowing the professional is committed. \n\nOnce the shift is completed, the funds are instantly released to the bank account. Simple, secure, and fully automated.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Customer Service Details (Full Width Container) ────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ShiftleyTokens.utilityGrey.withValues(alpha: 0.2),
                  border: const Border(top: BorderSide(color: ShiftleyTokens.inkBlack, width: 2.0)),
                ),
                padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceXL),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceXL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Real Support, Reliably fast', style: ShiftleyTokens.h1),
                          const SizedBox(height: ShiftleyTokens.spaceM),
                          Text(
                            'Got a dispute? Payment issue? Need help verifying your business? Our dedicated support team is available to step in.\n\nJust tap the chat button to get connected immediately. We are here to make sure your experience is seamless.',
                            style: ShiftleyTokens.bodyLarge.copyWith(height: 1.5, color: ShiftleyTokens.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Footer / About ───────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ShiftleyTokens.primaryRed,
                  border: Border(top: BorderSide(color: ShiftleyTokens.inkBlack, width: 2.0)),
                ),
                padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceXXL),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        const Text(
                          'Shiftley.',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: ShiftleyTokens.paperWhite,
                            letterSpacing: -1.0,
                          ),
                        ),

                        const SizedBox(height: ShiftleyTokens.spaceS),
                        Text(
                          'Built for India. Operating with transparency and speed.',
                          style: ShiftleyTokens.bodyMedium.copyWith(color: ShiftleyTokens.paperWhite.withValues(alpha: 0.9)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: ShiftleyTokens.spaceL),
                        Text('© 2026 Shiftley. All rights reserved.', style: ShiftleyTokens.caption.copyWith(color: ShiftleyTokens.paperWhite.withValues(alpha: 0.7))),
                      ],
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

  PreferredSizeWidget _buildNavBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(96), 
      child: Container(
        height: 96,
        decoration: const BoxDecoration(
          color: ShiftleyTokens.background,
          border: Border(bottom: BorderSide(color: ShiftleyTokens.inkBlack, width: 2.0)), 
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: ShiftleyTokens.spaceL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: const Text(
                        'Shiftley.',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          color: ShiftleyTokens.inkBlack,
                          letterSpacing: -1.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(
                      width: 120,
                      height: 36,
                      child: SButton(
                        text: 'Sign In / Up',
                        type: SButtonType.primary,
                        onPressed: () => context.push('/auth'),
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

  Widget _buildWorkerFlow() {
    return Column(
      key: const ValueKey('worker'),
      children: [
        _StepperItem(
          title: 'Verify Your Identity',
          description: 'Complete our fast KYC process. We keep the platform secure by only allowing verified individuals.',
          isLast: false,
        ),
        _StepperItem(
          title: 'Browse Local Gigs',
          description: 'Browse jobs happening right near you. Filter by your skills and apply in a tap.',
          isLast: false,
        ),
        _StepperItem(
          title: 'Apply & Confirm',
          description: 'Apply for gigs that match your skills, and get hired instantly by employers to lock in your slot.',
          isLast: false,
        ),
        _StepperItem(
          title: 'Arrive & Check-In',
          description: 'Arrive at the location, check in, and get the job done.',
          isLast: false,
        ),
        _StepperItem(
          title: 'Receive Payment Instantly',
          description: 'Once the shift is marked complete, your wage drops straight into your account. Zero platform fees taken from you.',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildEmployerFlow() {
    return Column(
      key: const ValueKey('employer'),
      children: [
        _StepperItem(
          title: 'Business Registration',
          description: 'Provide your GST details. Our team verifies your physical location to build trust with employees.',
          isLast: false,
        ),
        _StepperItem(
          title: 'Post Job Requirements',
          description: 'Pay a small flat subscription fee. Tell us what you need, when, and what it pays.',
          isLast: false,
        ),
        _StepperItem(
          title: 'Review & Select Candidates',
          description: 'Review applicants based on their reliability scores and past mutual ratings.',
          isLast: false,
        ),
        _StepperItem(
          title: 'Deposit Funds Securely',
          description: 'Accept an employee and deposit their wage into a secure holding account. They know you are serious.',
          isLast: false,
        ),
        _StepperItem(
          title: 'Shift Completion',
          description: 'Mark the shift complete, and the funds release automatically to the employee. Seamless.',
          isLast: true,
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceM),
        decoration: BoxDecoration(
          color: isActive ? ShiftleyTokens.secondaryCyan : Colors.transparent, // Replaced inkBlack with light cyan for active
          borderRadius: BorderRadius.circular(50),
          border: isActive ? ShiftleyTokens.primaryBorder : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: ShiftleyTokens.buttonLabel.copyWith(
              color: ShiftleyTokens.inkBlack, // Text is always black now as requested
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperItem extends StatelessWidget {
  final String title;
  final String description;
  final bool isLast;

  const _StepperItem({
    required this.title,
    required this.description,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Dotted Line & Circle Column ───────────────────
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(top: ShiftleyTokens.spaceS),
              decoration: const BoxDecoration(
                color: ShiftleyTokens.inkBlack,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: ShiftleyTokens.spaceXS),
                color: ShiftleyTokens.inkBlack.withValues(alpha: 0.2), 
              ),
          ],
        ),
        const SizedBox(width: ShiftleyTokens.spaceL),
        // ── Text Column ───────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: ShiftleyTokens.spaceXS, bottom: ShiftleyTokens.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ShiftleyTokens.h2),
                const SizedBox(height: ShiftleyTokens.spaceXS),
                Text(description, style: ShiftleyTokens.bodyLarge.copyWith(color: ShiftleyTokens.mutedText, height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Background Wave Animation ──────────────────────────────────────────

class _WaveBackground extends StatefulWidget {
  const _WaveBackground();

  @override
  State<_WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<_WaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;

  _WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final List<Color> baseColors = [
      ShiftleyTokens.primaryRed,
      ShiftleyTokens.secondaryCyan,
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      ShiftleyTokens.inkBlack,
    ];

    const numWaves = 12; // More waves for a richer feel
    for (int w = 0; w < numWaves; w++) {
      final path = Path();
      final colorIndex = w % baseColors.length;
      final baseColor = baseColors[colorIndex];
      
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 // Thinner lines
        ..shader = LinearGradient(
          colors: [
            baseColor.withValues(alpha: 0.0),
            baseColor.withValues(alpha: 0.15), // Lighter colors
            baseColor.withValues(alpha: 0.3),  // Lighter peak
            baseColor.withValues(alpha: 0.15),
            baseColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: GradientRotation(animationValue * 2 * pi + w), 
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      // Increase randomness for an organic look
      final yCenter = size.height * (0.1 + (0.8 * (w / (numWaves - 1))));
      final freqMultiplier = 0.8 + sin(w * 1.4) * 0.5 + (w * 0.1);
      final phaseOffset = (w * pi / 3) + cos(w * 0.8) * pi;
      final amplitude = 30.0 + sin(w * 2.1) * 20.0 + (w * 5.0);

      for (double i = 0; i <= size.width; i += 3) {
        final x = i;
        final y = yCenter + sin((i / size.width * freqMultiplier * pi) + (animationValue * 2 * pi + phaseOffset)) * amplitude;
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.animationValue != animationValue;
}


