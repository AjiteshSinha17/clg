import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';

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

    // Background Image Logic
    final String bgImage = isDark
        ? 'assets/images/dark_wallpaper.jpg'
        : 'assets/images/lk.jpg';

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      extendBody: true, // Allow body to extend behind bottom nav bar
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/3523/3523063.png',
                width: 28,
                height: 28,
              ),
            ),
          ),
        ),
        title: Text(
          'ClgJone',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: const [], // Removed Logout and Theme Toggle
      ),
      body: Stack(
        children: [
          // Background Wallpaper
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                BlendMode.darken,
              ),
              child: Image.asset(bgImage, fit: BoxFit.cover),
            ),
          ),

          // Content
          SafeArea(
            bottom: false, // Allow content to go behind nav bar
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: NavigationBar(
              height: 70,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: isDark
                  ? Colors.black.withValues(alpha: 0.6)
                  : Colors.white.withValues(
                      alpha: 0.6,
                    ), // Transparent in light mode
              indicatorColor: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              elevation: 0,
              destinations: const [
                NavigationDestination(
                  icon: FaIcon(FontAwesomeIcons.comments),
                  label: 'Community',
                ),
                NavigationDestination(
                  icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: FaIcon(FontAwesomeIcons.user),
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
