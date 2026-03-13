import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../state/auth_provider.dart';
import '../../state/user_provider.dart';
import '../../state/theme_provider.dart';
import '../../widgets/theme_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Soft orange-white gradient (less saturated, cream-orange) ─────────────
  static const _softOrange = Color(0xFFFF8C38); // muted warm orange
  static const _softOrangeLight = Color(0xFFFFB870); // very light orange-cream
  static const _softOrangeGlow = Color(0x33FF8C38); // soft glow

  static const _editBtnGradient = LinearGradient(
    colors: [_softOrangeLight, _softOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Clay shadow stack for buttons
  static List<BoxShadow> _clayBtnShadow() => [
    BoxShadow(
      color: _softOrange.withValues(alpha: 0.35),
      blurRadius: 18,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
    const BoxShadow(
      color: Colors.white,
      blurRadius: 0,
      spreadRadius: -2,
      offset: Offset(0, -2),
    ),
  ];

  static List<BoxShadow> _clayCardShadow(bool isDark) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.80),
      blurRadius: 0,
      spreadRadius: 0,
      offset: const Offset(0, -2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFF0EDE8),
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
                // Gradient overlay at bottom of banner
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
                        (isDark ? Colors.black : Colors.white).withValues(
                          alpha: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Clay avatar ring
              Positioned(
                bottom: -58,
                child: Stack(
                  children: [
                    // Outer glow ring
                    Container(
                      width: 132,
                      height: 132,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_softOrangeLight, _softOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _softOrangeGlow,
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    // Inner white ring + avatar
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1A1A1A)
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
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFF5F0EB),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: _softOrange,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Edit badge
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => context.push('/shell/edit-profile'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_softOrangeLight, _softOrange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: _softOrange.withValues(alpha: 0.40),
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 28),

          // ── College Info Card (clay glass) ─────────────────────────────────
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
                      color: Colors.grey.withValues(alpha: isDark ? 0.15 : 0.2),
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
                      color: Colors.grey.withValues(alpha: isDark ? 0.15 : 0.2),
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
                      const SnackBar(
                        content: Text('Verification coming soon!'),
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_softOrangeLight, _softOrange],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: _softOrange.withValues(alpha: 0.3),
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
                            const Text(
                              'Theme',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                  _buildSettingTile(
                    context,
                    isDark,
                    Icons.logout_rounded,
                    'Logout',
                    Colors.red,
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
              gradient: const LinearGradient(
                colors: [_softOrangeLight, _softOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _softOrange.withValues(alpha: 0.30),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not set',
              style: TextStyle(
                color: value.isNotEmpty
                    ? (isDark
                          ? Colors.white.withValues(alpha: 0.85)
                          : Colors.black87)
                    : Colors.grey,
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
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _editBtnGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _clayBtnShadow(),
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
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _softOrange.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: _clayCardShadow(isDark),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _softOrange, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.85)
                    : Colors.black87,
                fontSize: 16,
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
      borderRadius: BorderRadius.circular(8),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.90),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.70),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
