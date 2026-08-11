import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../state/theme_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final primaryColor = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Please login to view notifications',
            style: TextStyle(
              color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
            ),
          ),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Notifications',
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
        child: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                  ),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_rounded,
                      size: 48,
                      color: primaryColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final title = (data['title'] ?? 'Notification').toString();
                final body = (data['body'] ?? '').toString();
                final read = (data['read'] ?? false) as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AppTheme.liquidGlassDecoration(
                    isDark: isDark,
                    radius: 20,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: read
                            ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))
                            : primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        read ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                        color: read
                            ? (isDark ? AppTheme.darkOnSurfaceVariant : AppTheme.lightOnSurfaceVariant)
                            : primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: read ? FontWeight.w500 : FontWeight.bold,
                        color: isDark ? AppTheme.darkOnSurface : AppTheme.lightOnSurface,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: body.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              body,
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.darkOnSurfaceVariant
                                    : AppTheme.lightOnSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null,
                    trailing: read
                        ? Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: isDark ? AppTheme.darkOutline : AppTheme.lightOutline,
                          )
                        : TextButton(
                            onPressed: () async {
                              await doc.reference.update({
                                'read': true,
                                'readAt': FieldValue.serverTimestamp(),
                              });
                            },
                            child: Text(
                              'Mark read',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

