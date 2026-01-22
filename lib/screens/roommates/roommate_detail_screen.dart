import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../state/theme_provider.dart';
import '../../config/theme.dart';

class RoommateDetailScreen extends StatelessWidget {
  final User profile;

  const RoommateDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image with overlay
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
                BlendMode.darken,
              ),
              child: Image.asset(
                'assets/images/mountain_dark.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // AppBar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: Text(profile.name),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                if (profile.verificationStatus == 'verified')
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.verified, color: Colors.blue),
                  ),
              ],
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glass card
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header avatar + name
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 52,
                                      backgroundImage:
                                          profile.avatarUrl.isNotEmpty
                                              ? NetworkImage(profile.avatarUrl)
                                              : null,
                                      child: profile.avatarUrl.isEmpty
                                          ? Text(
                                              profile.name.isNotEmpty
                                                  ? profile.name[0]
                                                      .toUpperCase()
                                                  : '?',
                                              style:
                                                  const TextStyle(fontSize: 36),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      profile.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profile.college.isNotEmpty
                                          ? profile.college
                                          : 'Unknown College',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[400]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bio
                              _buildSectionTitle(context, 'Bio'),
                              Text(
                                profile.bio.isNotEmpty
                                    ? profile.bio
                                    : 'No bio provided.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),

                              // Location & Budget
                              _buildSectionTitle(context, 'Details'),
                              _buildInfoRow(
                                context,
                                Icons.location_on,
                                '${profile.area}, ${profile.city}',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.currency_rupee,
                                '₹${profile.budgetMin.toInt()} - ₹${profile.budgetMax.toInt()}',
                              ),
                              const SizedBox(height: 16),

                              // Interests
                              if (profile.interestTags.isNotEmpty) ...[
                                _buildSectionTitle(context, 'Interests'),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: profile.interestTags.map((tag) {
                                    return Chip(
                                      label: Text(tag),
                                      backgroundColor: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Lifestyle
                              _buildSectionTitle(context, 'Lifestyle'),
                              _buildInfoRow(
                                context,
                                Icons.bedtime,
                                'Sleep: ${profile.sleepSchedule}',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.cleaning_services,
                                'Cleanliness: ${profile.cleanlinessLevel}/5',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.smoking_rooms,
                                'Smoking: ${profile.smoking}',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.local_drink,
                                'Drinking: ${profile.drinking}',
                              ),
                              _buildInfoRow(
                                context,
                                Icons.home,
                                profile.livesAlone
                                    ? 'Lives Alone'
                                    : 'Looking for place',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to chat
          // context.push('/chat/${profile.userId}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat feature coming soon!')),
          );
        },
        label: const Text('Connect & Chat'),
        icon: const Icon(Icons.chat),
        backgroundColor: isDark
            ? AppTheme.mountainGold
            : AppTheme.mountainOrange,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
