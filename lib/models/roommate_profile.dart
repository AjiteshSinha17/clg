
class RoommateProfile {
  final String userId;
  final String city;
  final String area;
  final double budget;
  final List<String> interests;
  final bool livesAlone;
  final bool lookingForRoommate;

  RoommateProfile({
    required this.userId,
    required this.city,
    required this.area,
    required this.budget,
    required this.interests,
    required this.livesAlone,
    required this.lookingForRoommate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'city': city,
      'area': area,
      'budget': budget,
      'interests': interests,
      'livesAlone': livesAlone,
      'lookingForRoommate': lookingForRoommate,
    };
  }

  factory RoommateProfile.fromMap(Map<String, dynamic> map) {
    return RoommateProfile(
      userId: map['userId'] ?? '',
      city: map['city'] ?? '',
      area: map['area'] ?? '',
      budget: (map['budget'] ?? 0).toDouble(),
      interests: List<String>.from(map['interests'] ?? []),
      livesAlone: map['livesAlone'] ?? false,
      lookingForRoommate: map['lookingForRoommate'] ?? false,
    );
  }
}
