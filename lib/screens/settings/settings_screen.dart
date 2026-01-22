import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../state/theme_provider.dart';
import '../../config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  isDark
                      ? 'assets/images/theme_dark.jpg'
                      : 'assets/images/theme_light.jpg',
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(
                    alpha: 0.6,
                  ), // Darken background for readability
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader(context, 'Appearance', isDark),
                Card(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: isDark,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark
                          ? AppTheme.mountainGold
                          : AppTheme.mountainOrange,
                    ),
                    activeColor: AppTheme.mountainGold,
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Account', isDark),
                Card(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          await Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).signOut();
                          // Router will handle redirection
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'CampusConnect v1.0.0',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.mountainGold : Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
