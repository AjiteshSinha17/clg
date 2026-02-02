import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view notifications')),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = (data['title'] ?? 'Notification').toString();
              final body = (data['body'] ?? '').toString();
              final read = (data['read'] ?? false) as bool;

              return ListTile(
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: read ? FontWeight.w500 : FontWeight.w800,
                  ),
                ),
                subtitle: body.isNotEmpty ? Text(body) : null,
                trailing: read
                    ? const Icon(Icons.check, size: 18)
                    : TextButton(
                        onPressed: () async {
                          await doc.reference.update({
                            'read': true,
                            'readAt': FieldValue.serverTimestamp(),
                          });
                        },
                        child: const Text('Mark read'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

