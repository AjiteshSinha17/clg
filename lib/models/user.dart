import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String avatarUrl;
  final String bannerUrl;
  final String bio;

  // Academic Info
  final String college;
  final String branch;
  final String year;
  final String gender;

  // Verification
  final String verificationStatus; // "not_verified", "pending", "verified"
  final String collegeIdImageUrl;

  // Roommate Preferences (Consolidated)
  final bool isLookingForRoommate;
  final String city;
  final String area;
  final double budgetMin;
  final double budgetMax;
  final List<String> interestTags;
  final String sleepSchedule; // 'early', 'late', 'flexible'
  final int cleanlinessLevel; // 1-5
  final String smoking; // 'no', 'occasionally', 'yes'
  final String drinking; // 'no', 'occasionally', 'yes'
  final bool livesAlone;
  final String preferredGender; // 'any', 'male', 'female'

  // Profile Status
  final bool profileCompleted;
  final bool isActive;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  User({
    required this.uid,
    required this.email,
    required this.name,
    this.avatarUrl = '',
    this.bannerUrl = '',
    this.bio = '',
    this.college = '',
    this.branch = '',
    this.year = '',
    this.gender = 'prefer_not_to_say',
    this.verificationStatus = 'not_verified',
    this.collegeIdImageUrl = '',

    // Roommate Defaults
    this.isLookingForRoommate = false,
    this.city = '',
    this.area = '',
    this.budgetMin = 0,
    this.budgetMax = 0,
    this.interestTags = const [],
    this.sleepSchedule = 'flexible',
    this.cleanlinessLevel = 3,
    this.smoking = 'no',
    this.drinking = 'no',
    this.livesAlone = false,
    this.preferredGender = 'any',

    this.profileCompleted = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      bio: data['bio'] ?? '',
      college: data['college'] ?? '',
      branch: data['branch'] ?? '',
      year: data['year'] ?? '',
      gender: data['gender'] ?? 'prefer_not_to_say',
      verificationStatus: data['verificationStatus'] ?? 'not_verified',
      collegeIdImageUrl: data['collegeIdImageUrl'] ?? '',

      // Roommate Fields
      isLookingForRoommate: data['isLookingForRoommate'] ?? false,
      city: data['city'] ?? '',
      area: data['area'] ?? '',
      budgetMin: (data['budgetMin'] ?? 0).toDouble(),
      budgetMax: (data['budgetMax'] ?? 0).toDouble(),
      interestTags: List<String>.from(data['interestTags'] ?? []),
      sleepSchedule: data['sleepSchedule'] ?? 'flexible',
      cleanlinessLevel: data['cleanlinessLevel'] ?? 3,
      smoking: data['smoking'] ?? 'no',
      drinking: data['drinking'] ?? 'no',
      livesAlone: data['livesAlone'] ?? false,
      preferredGender: data['preferredGender'] ?? 'any',

      profileCompleted: data['profileCompleted'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'bannerUrl': bannerUrl,
      'bio': bio,
      'college': college,
      'branch': branch,
      'year': year,
      'gender': gender,
      'verificationStatus': verificationStatus,
      'collegeIdImageUrl': collegeIdImageUrl,

      // Roommate Fields
      'isLookingForRoommate': isLookingForRoommate,
      'city': city,
      'area': area,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'interestTags': interestTags,
      'sleepSchedule': sleepSchedule,
      'cleanlinessLevel': cleanlinessLevel,
      'smoking': smoking,
      'drinking': drinking,
      'livesAlone': livesAlone,
      'preferredGender': preferredGender,

      'profileCompleted': profileCompleted,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
    };
  }

  // For backward compatibility with existing code
  String get id => uid;
  String? get profileImageUrl => avatarUrl.isNotEmpty ? avatarUrl : null;
}
