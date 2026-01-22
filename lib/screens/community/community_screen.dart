import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_provider.dart';
import '../chats/chats_wrapper_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    // Community tab now focuses on chat experience (Personal + Community)
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.05),
      ),
      child: const ChatsWrapperScreen(),
    );
  }
}
