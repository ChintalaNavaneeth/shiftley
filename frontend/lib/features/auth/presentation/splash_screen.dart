import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shiftley_frontend/core/design_system/shiftley_tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charCountAnim;
  late Animation<double> _opacityAnim;
  
  final String _fullText = 'Shiftley.';

  @override
  void initState() {
    super.initState();
    // Total duration: 2 seconds. 
    // 0.0 -> 0.6: Typewriter effect
    // 0.6 -> 0.8: Hold
    // 0.8 -> 1.0: Fade out
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _charCountAnim = StepTween(begin: 0, end: _fullText.length).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.linear),
      ),
    );

    _opacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) context.go('/landing');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftleyTokens.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            String displayedText = _fullText.substring(0, _charCountAnim.value);
            return Opacity(
              opacity: _opacityAnim.value,
              child: Text(
                displayedText,
                style: ShiftleyTokens.displayLogo,
              ),
            );
          },
        ),
      ),
    );
  }
}
