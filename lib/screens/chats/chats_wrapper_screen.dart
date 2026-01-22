import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../state/theme_provider.dart';
import '../../config/theme.dart';
import 'chats_list_screen.dart';
import 'community_chat_screen.dart';

class ChatsWrapperScreen extends StatefulWidget {
  const ChatsWrapperScreen({super.key});

  @override
  State<ChatsWrapperScreen> createState() => _ChatsWrapperScreenState();
}

class _ChatsWrapperScreenState extends State<ChatsWrapperScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _index = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Column(
      children: [
        // Custom Toggle / Tab Bar
        // Custom Bubble Switch
        Container(
          height: 50,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: _index == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5 - 32,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.mountainGold
                        : AppTheme.mountainOrange,
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isDark
                                    ? AppTheme.mountainGold
                                    : AppTheme.mountainOrange)
                                .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _tabController.animateTo(0);
                      },
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          'Personal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _index == 0
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _tabController.animateTo(1);
                      },
                      child: Container(
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          'Community',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _index == 1
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _index == 0
                ? const ChatsListScreen(key: ValueKey('personal'))
                : const CommunityChatScreen(key: ValueKey('community')),
          ),
        ),
      ],
    );
  }
}
