
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String college;
  final List<String> hobbies;
  final String? avatarUrl;
  final String verificationStatus; // e.g., "none", "pending", "verified"

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.college,
    required this.hobbies,
    this.avatarUrl,
    this.verificationStatus = 'none',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'college': college,
      'hobbies': hobbies,
      'avatarUrl': avatarUrl,
      'verificationStatus': verificationStatus,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      college: map['college'] ?? '',
      hobbies: List<String>.from(map['hobbies'] ?? []),
      avatarUrl: map['avatarUrl'] as String?,
      verificationStatus: map['verificationStatus'] ?? 'none',
    );
  }
}
