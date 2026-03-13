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

    final navBg = isDark
        ? AppTheme.darkSurface.withValues(alpha: 0.98)
        : AppTheme.pureWhite.withValues(alpha: 0.98);

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: navBg,
              border: Border(
                right: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                _DrawerHeader(isDark: isDark, user: user),

                // ── Menu Items ───────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    children: [

                      _DrawerItem(
                        icon: Icons.person_search_rounded,
                        title: 'Search People',
                        isDark: isDark,
                        onTap: () {
                          context.pop();
                          context.go('/shell/roommate-search');
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.handshake_rounded,
                        title: 'Connection Requests',
                        isDark: isDark,
                        onTap: () {
                          context.pop();
                          context.go('/shell/connection-requests');
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.download_rounded,
                        title: 'My Downloads',
                        isDark: isDark,
                        onTap: () {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'My Downloads feature coming soon!',
                              ),
                              backgroundColor: AppTheme.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                        isDark: isDark,
                        onTap: () {
                          context.pop();
                          context.push('/shell/notifications');
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.08),
                          height: 1,
                        ),
                      ),
                      _DrawerItem(
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        isDark: isDark,
                        onTap: () {
                          context.pop();
                          context.push('/shell/settings');
                        },
                      ),
                    ],
                  ),
                ),

                // ── Footer ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ClgJone v1.0.0',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header widget ──────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  final bool isDark;
  final dynamic user;

  const _DrawerHeader({required this.isDark, required this.user});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.deepBlack, AppTheme.darkSurface]
              : [AppTheme.orange, AppTheme.orangeDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: DecorationImage(
          image: AssetImage(
            isDark ? 'assets/images/theme_dark.jpg' : 'assets/images/lk.jpg',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            isDark
                ? Colors.black.withValues(alpha: 0.55)
                : AppTheme.orangeDark.withValues(alpha: 0.60),
            BlendMode.darken,
          ),
        ),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with clay ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.orange.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: AppTheme.orange, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: AppTheme.darkCard,
              backgroundImage:
                  user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                  ? NetworkImage(user.avatarUrl) as ImageProvider
                  : null,
              child: user?.avatarUrl == null || user!.avatarUrl.isEmpty
                  ? Text(
                      user?.name?.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.name ?? 'Guest',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 0.3,
              shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black45)],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Drawer Item ────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.orange.withValues(alpha: 0.15),
          highlightColor: AppTheme.orange.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: AppTheme.orange, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
