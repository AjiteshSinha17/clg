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
        ? AppTheme.darkContainer.withValues(alpha: 0.88)
        : const Color(0xFFF3FBFA).withValues(alpha: 0.92);

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: navBg,
              border: Border(
                right: BorderSide(
                  color: isDark
                      ? AppTheme.darkPrimary.withValues(alpha: 0.25)
                      : const Color(0xFF18D8D0).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              boxShadow: AppTheme.neumorphicShadows(isDark),
            ),
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                _DrawerHeader(isDark: isDark, user: user),

                // ── Menu Items ───────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                    children: [
                      _DrawerItem(
                        icon: Icons.event_available_rounded,
                        title: 'Events & Hackathons',
                        isDark: isDark,
                        onTap: () {
                          context.pop();
                          context.push('/shell/events');
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.person_search_rounded,
                        title: 'Search People',
                        isDark: isDark,
                        onTap: () {
                          context.pop();
                          context.push('/shell/roommate-search');
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
                              backgroundColor: isDark
                                  ? AppTheme.darkPrimaryContainer
                                  : AppTheme.lightPrimary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: isDark
                              ? AppTheme.darkOutline.withValues(alpha: 0.2)
                              : AppTheme.lightOutline.withValues(alpha: 0.2),
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
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkPrimary
                              : AppTheme.lightPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.aquaGlow.withValues(alpha: 0.8),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ClgJone v1.0.0 • Aquatic Nebula',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.darkOnSurfaceVariant
                              : AppTheme.lightOnSurfaceVariant,
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
        color: isDark ? AppTheme.darkContainer : AppTheme.lightContainerHigh,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(32)),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppTheme.goldenBorder.withValues(alpha: 0.35)
                : AppTheme.lightPrimary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        boxShadow: AppTheme.neumorphicShadows(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar with refined Golden glow ring
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.goldenBorder : AppTheme.aquaGlow)
                          .withValues(alpha: isDark ? 0.45 : 0.6),
                      blurRadius: 18,
                      spreadRadius: 1.5,
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? AppTheme.goldenBorder : Colors.white,
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: isDark
                      ? AppTheme.darkSurface
                      : AppTheme.lightContainer,
                  backgroundImage:
                      user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl) as ImageProvider
                      : null,
                  child: user?.avatarUrl == null || user!.avatarUrl.isEmpty
                      ? Text(
                          user?.name?.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.softBeige : AppTheme.lightPrimary,
                          ),
                        )
                      : null,
                ),
              ),
              // App Logo Emblem
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/clglogo.png',
                    height: 56,
                    width: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            user?.name ?? 'Guest',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w400,
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
    final iconColor = isDark ? AppTheme.darkPrimary : const Color(0xFF006A66);
    final textColor = isDark ? AppTheme.darkOnSurface : const Color(0xFF021429);
    final cardBg = isDark ? AppTheme.darkContainer : Colors.white;
    final borderCol = isDark
        ? AppTheme.darkPrimary.withValues(alpha: 0.15)
        : const Color(0xFF18D8D0).withValues(alpha: 0.25);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: const Color(0xFF18D8D0).withValues(alpha: 0.2),
          highlightColor: const Color(0xFF18D8D0).withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: cardBg,
              border: Border.all(color: borderCol, width: 1),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark
                      ? AppTheme.darkOutline
                      : AppTheme.lightOutline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

