
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String? bio;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.name,
    this.bio,
    this.profileImageUrl,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      bio: data['bio'],
      profileImageUrl: data['profileImageUrl'],
    );
  }
}
