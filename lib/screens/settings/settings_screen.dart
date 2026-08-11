import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../state/auth_provider.dart';
import '../../state/theme_provider.dart';
import '../../config/theme.dart';
import '../../services/notification_preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefsService = NotificationPreferencesService();
  late Stream<NotificationPreferences> _prefsStream;

  @override
  void initState() {
    super.initState();
    _prefsStream = _prefsService.preferencesStream();
  }

  Future<void> _updatePreference({
    bool? personalChat,
    bool? communityChat,
    bool? roommateRequest,
    required bool value,
  }) async {
    final currentPrefs = await _prefsService.getPreferences();
    final updated = currentPrefs.copyWith(
      personalChatEnabled: personalChat != null ? value : currentPrefs.personalChatEnabled,
      communityChatEnabled: communityChat != null ? value : currentPrefs.communityChatEnabled,
      roommateRequestEnabled: roommateRequest != null ? value : currentPrefs.roommateRequestEnabled,
    );
    await _prefsService.setPreferences(updated);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: context.canPop()
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                ),
                onPressed: () => context.pop(),
              )
            : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Appearance', isDark),
            Container(
              decoration: AppTheme.liquidGlassDecoration(
                isDark: isDark,
                radius: 20,
              ),
              child: SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                  ),
                ),
                subtitle: Text(
                  'Enable dark theme',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                value: isDark,
                onChanged: (value) => themeProvider.toggleTheme(),
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: primaryColor,
                ),
                activeTrackColor: primaryColor,
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Notifications', isDark),
            StreamBuilder<NotificationPreferences>(
              stream: _prefsStream,
              builder: (context, snapshot) {
                final prefs = snapshot.data ?? NotificationPreferences.defaults();
                return Container(
                  decoration: AppTheme.liquidGlassDecoration(
                    isDark: isDark,
                    radius: 20,
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          'Personal Chat Notifications',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Receive notifications for personal messages',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        value: prefs.personalChatEnabled,
                        onChanged: (value) => _updatePreference(
                          personalChat: true,
                          value: value,
                        ),
                        secondary: Icon(Icons.chat_bubble_rounded, color: primaryColor),
                        activeTrackColor: primaryColor,
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppTheme.darkOutline.withValues(alpha: 0.15)
                            : AppTheme.lightOutline.withValues(alpha: 0.15),
                      ),
                      SwitchListTile(
                        title: Text(
                          'Community Chat Notifications',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Receive notifications for community messages',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        value: prefs.communityChatEnabled,
                        onChanged: (value) => _updatePreference(
                          communityChat: true,
                          value: value,
                        ),
                        secondary: Icon(Icons.forum_rounded, color: primaryColor),
                        activeTrackColor: primaryColor,
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppTheme.darkOutline.withValues(alpha: 0.15)
                            : AppTheme.lightOutline.withValues(alpha: 0.15),
                      ),
                      SwitchListTile(
                        title: Text(
                          'Roommate Request Alerts',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Get notified when someone sends a connection request',
                          style: TextStyle(
                            color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        value: prefs.roommateRequestEnabled,
                        onChanged: (value) => _updatePreference(
                          roommateRequest: true,
                          value: value,
                        ),
                        secondary: Icon(Icons.handshake_rounded, color: primaryColor),
                        activeTrackColor: primaryColor,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Account', isDark),
            Container(
              decoration: AppTheme.liquidGlassDecoration(
                isDark: isDark,
                radius: 20,
              ),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: Color(0xFFFF5252)),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFFF5252),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).signOut();
                },
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: Text(
                'ClgJone v1.0.0 • Aquatic Nebula',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
