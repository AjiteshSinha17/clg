import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/theme_provider.dart';
import '../../state/auth_provider.dart';
import '../../config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection(context, 'Appearance', [
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark/light theme'),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => themeProvider.toggleTheme(),
              secondary: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: AppTheme.mountainOrange,
              ),
            ),
          ]),
          const Divider(),
          _buildSection(context, 'Account', [
            ListTile(
              leading: Icon(Icons.person, color: AppTheme.mountainOrange),
              title: const Text('Edit Profile'),
              subtitle: const Text('Update your personal information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to edit profile
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile feature coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.verified, color: AppTheme.mountainGold),
              title: const Text('Verification'),
              subtitle: const Text('Verify your college ID'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to verification
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification feature coming soon!'),
                  ),
                );
              },
            ),
          ]),
          const Divider(),
          _buildSection(context, 'Notifications', [
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications for new messages'),
              value: true,
              onChanged: (value) {
                // Handle notification toggle
              },
              secondary: Icon(
                Icons.notifications,
                color: AppTheme.mountainOrange,
              ),
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive email updates'),
              value: false,
              onChanged: (value) {
                // Handle email toggle
              },
              secondary: Icon(Icons.email, color: AppTheme.mountainOrange),
            ),
          ]),
          const Divider(),
          _buildSection(context, 'Privacy', [
            ListTile(
              leading: Icon(Icons.lock, color: AppTheme.mountainOrange),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show privacy policy
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: AppTheme.mountainOrange),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show terms
              },
            ),
          ]),
          const Divider(),
          _buildSection(context, 'About', [
            ListTile(
              leading: Icon(Icons.info, color: AppTheme.mountainOrange),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: Icon(Icons.help, color: AppTheme.mountainOrange),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show help
              },
            ),
          ]),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await authProvider.signOut();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.mountainOrange,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
