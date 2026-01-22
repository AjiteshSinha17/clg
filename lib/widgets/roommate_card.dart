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
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Profile Picture
            CircleAvatar(
              radius: 30,
              backgroundColor: isDark
                  ? AppTheme.mountainGold
                  : AppTheme.mountainOrange,
              backgroundImage: profile.avatarUrl.isNotEmpty
                  ? NetworkImage(profile.avatarUrl)
                  : null,
              child: profile.avatarUrl.isEmpty
                  ? Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(height: 8),

            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                profile.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (profile.verificationStatus == 'verified')
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.verified, size: 14, color: Colors.blue),
              ),

            // College
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                profile.college.isNotEmpty
                    ? profile.college
                    : 'Unknown College',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Spacer(),

            // Main Interest Tag
            if (profile.interestTags.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.mountainGold.withValues(alpha: 0.2)
                      : AppTheme.mountainOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  profile.interestTags.first,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppTheme.mountainGold
                        : AppTheme.mountainOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // View Profile Hint
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility,
                    size: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'View Profile',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white70 : Colors.black54,
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
