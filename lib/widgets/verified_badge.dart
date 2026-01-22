import 'package:flutter/material.dart';
import '../config/theme.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final Color? color;

  const VerifiedBadge({super.key, this.size = 16, this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified,
      size: size,
      color: color ?? AppTheme.mountainGold,
    );
  }
}
