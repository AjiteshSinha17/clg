
import 'package:flutter/material.dart';

import '../../../models/user.dart';

class RoommateCard extends StatelessWidget {
  final User user;

  const RoommateCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(user.name),
        subtitle: Text(user.bio ?? 'No bio yet.'),
        onTap: () {
          // Navigate to user profile details
        },
      ),
    );
  }
}
