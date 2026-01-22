import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../state/user_provider.dart';
import '../state/theme_provider.dart';
import '../config/theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final user = userProvider.user;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.9),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // Header
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.mountainDarkBlue
                      : AppTheme.mountainLightBlue,
                  image: DecorationImage(
                    image: AssetImage(
                      isDark
                          ? 'assets/images/theme_dark.jpg'
                          : 'assets/images/theme_light.jpg',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.4),
                      BlendMode.darken,
                    ),
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage:
                      user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user?.avatarUrl == null || user!.avatarUrl.isEmpty
                      ? Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 24,
                            color: isDark
                                ? Colors.black
                                : AppTheme.mountainOrange,
                          ),
                        )
                      : null,
                ),
                accountName: Text(
                  user?.name ?? 'Guest',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text(user?.email ?? ''),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.person_search,
                      title: 'Search People',
                      onTap: () {
                        context.pop(); // Close drawer
                        context.go('/shell/roommate-search');
                      },
                      isDark: isDark,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.download,
                      title: 'My Downloads',
                      onTap: () {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('My Downloads feature coming soon!'),
                          ),
                        );
                      },
                      isDark: isDark,
                    ),
                    const Divider(),
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        context.pop();
                        context.push('/shell/settings');
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: isDark ? Colors.white10 : Colors.black12,
    );
  }
}
