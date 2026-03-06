import 'package:flutter/material.dart';
import '../models/user.dart';

// Soft orange-white gradient palette (muted/creamy, not harsh saturated)
const _softOrange = Color(0xFFFF8C38);
const _softOrangeLight = Color(0xFFFFB870);

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
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFFFF9F4),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : _softOrange.withValues(alpha: 0.15),
            width: 1.2,
          ),
          boxShadow: [
            // Main depth shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.10),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            // Inner highlight (skeuomorphism)
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.75),
              blurRadius: 0,
              spreadRadius: 0,
              offset: const Offset(0, -2),
            ),
            // Orange tint glow
            BoxShadow(
              color: _softOrange.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 16,
              spreadRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // ── Avatar with clay ring ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_softOrangeLight, _softOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _softOrange.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: isDark
                    ? const Color(0xFF1C1C1C)
                    : Colors.white,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (profile.verificationStatus == 'verified')
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.verified_rounded,
                  size: 13,
                  color: Colors.blue,
                ),
              ),

            // ── College ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Text(
                profile.college.isNotEmpty
                    ? profile.college
                    : 'Unknown College',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.45),
                  fontSize: 12,
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
                  gradient: LinearGradient(
                    colors: [
                      _softOrangeLight.withValues(alpha: 0.25),
                      _softOrange.withValues(alpha: 0.20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _softOrange.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  profile.interestTags.first,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _softOrange,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // ── View Profile bar ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _softOrangeLight.withValues(alpha: isDark ? 0.12 : 0.08),
                    _softOrange.withValues(alpha: isDark ? 0.14 : 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
                border: Border(
                  top: BorderSide(
                    color: _softOrange.withValues(alpha: isDark ? 0.15 : 0.12),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    size: 13,
                    color: _softOrange.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'View Profile',
                    style: TextStyle(
                      fontSize: 10,
                      color: _softOrange.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
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
