import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Shown while auth is initializing. Animation + app-specific loading text.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.paletteCharcoal : AppTheme.paletteCream;
    final primaryColor =
        isDark ? AppTheme.mountainGold : AppTheme.paletteViolet;
    final textColor = isDark ? Colors.white : const Color(0xFF372F37);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo / icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'ClgJone',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 12),
              AnimatedLoadingText(color: textColor),
              const SizedBox(height: 48),
              // Subtle progress indicator
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: primaryColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedLoadingText extends StatefulWidget {
  final Color color;

  const AnimatedLoadingText({super.key, required this.color});

  @override
  State<AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _index = 0;
  static const _messages = [
    'Connecting your campus...',
    'Loading ClgJone...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _controller.addListener(() {
      final i = (_controller.value * _messages.length).floor() % _messages.length;
      if (i != _index && mounted) setState(() => _index = i);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _messages[_index],
        key: ValueKey<int>(_index),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: widget.color.withValues(alpha: 0.85),
            ),
      ),
    );
  }
}
