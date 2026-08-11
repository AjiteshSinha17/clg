import 'package:flutter/material.dart';
import '../models/user.dart';
import '../config/theme.dart';

class RoommateCard extends StatelessWidget {
  final User profile;
  final int matchScore;
  final VoidCallback onTap;
  final bool isDark;

  const RoommateCard({
    super.key,
    required this.profile,
    required this.matchScore,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: AppTheme.liquidGlassDecoration(
          isDark: isDark,
          radius: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // ── Avatar with bioluminescent ring ────────────────────────────────
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient(isDark),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.aquaGlow.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: isDark
                    ? AppTheme.darkContainer
                    : AppTheme.lightContainer,
                backgroundImage: profile.avatarUrl.isNotEmpty
                    ? NetworkImage(profile.avatarUrl)
                    : null,
                child: profile.avatarUrl.isEmpty
                    ? Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            // ── Name ──────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                profile.name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (profile.verificationStatus == 'verified')
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: isDark ? AppTheme.darkOlive : AppTheme.oliveGreen,
                ),
              ),

            // ── College ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Text(
                profile.college.isNotEmpty
                    ? profile.college
                    : 'College Community',
                style: TextStyle(
                  color: isDark
                      ? AppTheme.darkOnSurfaceVariant
                      : AppTheme.lightOnSurfaceVariant,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Spacer(),

            // ── Interest Tag ──────────────────────────────────────────────────
            if (profile.interestTags.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.darkOlive : AppTheme.oliveGreen)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isDark ? AppTheme.darkOlive : AppTheme.oliveGreen,
                    width: 1,
                  ),
                ),
                child: Text(
                  profile.interestTags.first,
                  style: TextStyle(
                    color: isDark ? AppTheme.darkOlive : AppTheme.oliveGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // ── View Profile bar ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkContainerHigh.withValues(alpha: 0.8)
                    : AppTheme.lightContainerHigh,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppTheme.goldenBorder.withValues(alpha: 0.25)
                        : AppTheme.lightPrimary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    size: 13,
                    color: isDark ? AppTheme.softBeige : AppTheme.lightPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'View Profile',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.softBeige : AppTheme.lightPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

