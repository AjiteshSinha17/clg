import 'package:cloud_firestore/cloud_firestore.dart';

class RoommateProfile {
  final String userId;
  final String bio;
  final String city;
  final String area;
  final double budgetMin;
  final double budgetMax;
  final List<String> interestTags;
  final String sleepSchedule; // "early", "late", "flexible"
  final int cleanlinessLevel; // 1-5
  final String smoking; // "no", "occasionally", "yes"
  final String drinking; // "no", "occasionally", "yes"
  final bool livesAlone;
  final bool lookingForRoommate;
  final String preferredGender; // "male", "female", "any"

  // Denormalized User Data
  final String userName;
  final String userCollege;
  final String userAvatarUrl;
  final String userVerificationStatus; // "not_verified", "pending", "verified"
  final String userGender; // "male", "female"

  final DateTime createdAt;
  final DateTime updatedAt;

  RoommateProfile({
    required this.userId,
    required this.bio,
    required this.city,
    required this.area,
    required this.budgetMin,
    required this.budgetMax,
    required this.interestTags,
    required this.sleepSchedule,
    required this.cleanlinessLevel,
    required this.smoking,
    required this.drinking,
    required this.livesAlone,
    required this.lookingForRoommate,
    required this.preferredGender,
    required this.userName,
    required this.userCollege,
    required this.userAvatarUrl,
    required this.userVerificationStatus,
    required this.userGender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoommateProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoommateProfile(
      userId: data['userId'] ?? '',
      bio: data['bio'] ?? '',
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
      lookingForRoommate: data['lookingForRoommate'] ?? true,
      preferredGender: data['preferredGender'] ?? 'any',
      userName: data['userName'] ?? 'Unknown',
      userCollege: data['userCollege'] ?? 'Unknown College',
      userAvatarUrl: data['userAvatarUrl'] ?? '',
      userVerificationStatus: data['userVerificationStatus'] ?? 'not_verified',
      userGender: data['userGender'] ?? 'any',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bio': bio,
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
      'lookingForRoommate': lookingForRoommate,
      'preferredGender': preferredGender,
      'userName': userName,
      'userCollege': userCollege,
      'userAvatarUrl': userAvatarUrl,
      'userVerificationStatus': userVerificationStatus,
      'userGender': userGender,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
