import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/auth_provider.dart';
import '../../state/user_provider.dart';
import '../../state/theme_provider.dart';
import '../../config/theme.dart';
import '../../widgets/theme_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header with Avatar ─────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Banner with rounded bottom + gradient overlay
              Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurface
                      : AppTheme.lightSurface,
                  image: user.bannerUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(user.bannerUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(36),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(36),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        (isDark ? AppTheme.darkSurface : AppTheme.lightSurface)
                            .withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Avatar ring with cyan/sapphire glow
              Positioned(
                bottom: -58,
                child: Stack(
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient(isDark),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.aquaGlow.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppTheme.darkContainer
                              : Colors.white,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: user.avatarUrl.isNotEmpty
                              ? Image.network(user.avatarUrl, fit: BoxFit.cover)
                              : Container(
                                  color: isDark
                                      ? AppTheme.darkContainerHigh
                                      : const Color(0xFFE6F5F3),
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: primaryColor,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => context.push('/shell/edit-profile'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient(isDark),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.aquaGlow.withValues(alpha: 0.40),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 72),

          // ── Name + Email ───────────────────────────────────────────────────
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkOnSurfaceVariant
                  : AppTheme.lightOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),

          // ── College Info Card (Liquid Glass) ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ClayCard(
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      isDark,
                      Icons.school_rounded,
                      'College',
                      user.college,
                    ),
                    Divider(
                      color: isDark
                          ? AppTheme.darkOutline.withValues(alpha: 0.15)
                          : AppTheme.lightOutline.withValues(alpha: 0.2),
                      height: 1,
                    ),
                    _buildInfoRow(
                      context,
                      isDark,
                      Icons.book_rounded,
                      'Branch',
                      user.branch,
                    ),
                    Divider(
                      color: isDark
                          ? AppTheme.darkOutline.withValues(alpha: 0.15)
                          : AppTheme.lightOutline.withValues(alpha: 0.2),
                      height: 1,
                    ),
                    _buildInfoRow(
                      context,
                      isDark,
                      Icons.calendar_month_rounded,
                      'Year',
                      user.year,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Action Buttons ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildGradientButton(
                  context,
                  isDark,
                  'Edit Profile',
                  Icons.edit_rounded,
                  () => context.push('/shell/edit-profile'),
                ),
                const SizedBox(height: 14),
                _buildSecondaryButton(
                  context,
                  isDark,
                  'Verify College ID',
                  Icons.verified_user_rounded,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Verification coming soon!'),
                        backgroundColor: isDark
                            ? AppTheme.darkPrimaryContainer
                            : AppTheme.lightPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Settings Clay Card ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ClayCard(
              isDark: isDark,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient(isDark),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.aquaGlow.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Theme',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark
                                    ? AppTheme.darkOnSurface
                                    : AppTheme.lightOnSurface,
                              ),
                            ),
                          ],
                        ),
                        const ThemeToggleButton(),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppTheme.darkOutline.withValues(alpha: 0.15)
                        : AppTheme.lightOutline.withValues(alpha: 0.15),
                  ),
                  _buildSettingTile(
                    context,
                    isDark,
                    Icons.logout_rounded,
                    'Logout',
                    const Color(0xFFFF4D4D),
                    () async {
                      await Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).signOut();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient(isDark),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.aquaGlow.withValues(alpha: 0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not set',
              style: TextStyle(
                color: value.isNotEmpty
                    ? (isDark
                          ? AppTheme.darkOnSurface
                          : AppTheme.lightOnSurface)
                    : (isDark
                          ? AppTheme.darkOutline
                          : AppTheme.lightOutline),
                fontStyle: value.isNotEmpty ? null : FontStyle.italic,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(
    BuildContext context,
    bool isDark,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient(isDark),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.aquaGlow.withValues(alpha: isDark ? 0.4 : 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    bool isDark,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: AppTheme.liquidGlassDecoration(
          isDark: isDark,
          radius: 24,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? AppTheme.darkOnSurface
                    : AppTheme.lightOnSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Clay Card widget ────────────────────────────────────────────────────
class _ClayCard extends StatelessWidget {
  final bool isDark;
  final Widget child;
  const _ClayCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.liquidGlassDecoration(
        isDark: isDark,
        radius: 26,
      ),
      child: child,
    );
  }
}

