import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../config/theme.dart';
import '../../state/theme_provider.dart';
import '../../screens/roommates/roommate_search_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/community/community_screen.dart';
import '../../widgets/app_drawer.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _pages = <Widget>[
    const CommunityScreen(),
    const RoommateSearchScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: const AppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: AppTheme.liquidGlassDecoration(
                  isDark: isDark,
                  radius: 24,
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkPrimary.withValues(alpha: 0.15)
                              : const Color(0xFF006A66).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkPrimary.withValues(alpha: 0.4)
                                : const Color(0xFF18D8D0),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Image.network(
                          'https://cdn-icons-png.flaticon.com/512/3523/3523063.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.menu,
                            color: isDark
                                ? AppTheme.darkPrimary
                                : AppTheme.lightPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/clglogo.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ClgJone',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: isDark
                              ? AppTheme.darkOnSurface
                              : AppTheme.lightOnSurface,
                          shadows: isDark
                              ? [
                                  Shadow(
                                    color: AppTheme.aquaGlow.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => context.push('/shell/flux'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.darkAquaticBg
                                  : AppTheme.lightPrimaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.goldenBorder
                                    : AppTheme.lightPrimary,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? AppTheme.goldenBorder : AppTheme.aquaGlow)
                                      .withValues(alpha: isDark ? 0.35 : 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: isDark ? AppTheme.softBeige : Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Flux AI',
                                  style: TextStyle(
                                    color: isDark ? AppTheme.softBeige : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
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
      body: Container(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        child: SafeArea(bottom: false, child: _pages[_selectedIndex]),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(44, 0, 44, 18),
        decoration: AppTheme.liquidGlassDecoration(
          isDark: isDark,
          radius: 32,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: NavigationBar(
              height: 60,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: Colors.transparent,
              indicatorColor: isDark
                  ? AppTheme.darkAquaticBg
                  : const Color(0xFF006A66).withValues(alpha: 0.15),
              elevation: 0,
              destinations: [
                NavigationDestination(
                  icon: FaIcon(
                    FontAwesomeIcons.comments,
                    size: 18,
                    color: isDark
                        ? AppTheme.darkOutline
                        : AppTheme.lightOutline,
                  ),
                  selectedIcon: FaIcon(
                    FontAwesomeIcons.comments,
                    size: 18,
                    color: isDark
                        ? AppTheme.softBeige
                        : AppTheme.lightPrimary,
                  ),
                  label: 'Community',
                ),
                NavigationDestination(
                  icon: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 18,
                    color: isDark
                        ? AppTheme.darkOutline
                        : AppTheme.lightOutline,
                  ),
                  selectedIcon: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 18,
                    color: isDark
                        ? AppTheme.softBeige
                        : AppTheme.lightPrimary,
                  ),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: FaIcon(
                    FontAwesomeIcons.user,
                    size: 18,
                    color: isDark
                        ? AppTheme.darkOutline
                        : AppTheme.lightOutline,
                  ),
                  selectedIcon: FaIcon(
                    FontAwesomeIcons.user,
                    size: 18,
                    color: isDark
                        ? AppTheme.softBeige
                        : AppTheme.lightPrimary,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

