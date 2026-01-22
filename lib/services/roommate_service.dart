import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roommate_profile.dart';

class RoommateFilter {
  final String? city;
  final String? area;
  final double? minBudget;
  final double? maxBudget;
  final List<String> selectedInterestTags;
  final bool onlyVerified;

  RoommateFilter({
    this.city,
    this.area,
    this.minBudget,
    this.maxBudget,
    this.selectedInterestTags = const [],
    this.onlyVerified = false,
  });
}

class RoommateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'roommate_profiles';

  // Create or Update Profile
  Future<void> createProfile(RoommateProfile profile) async {
    await _firestore
        .collection(_collection)
        .doc(profile.userId)
        .set(profile.toMap());
  }

  // Fetch Profiles with Filters
  Future<List<RoommateProfile>> fetchProfiles(RoommateFilter filter) async {
    Query query = _firestore.collection(_collection);

    // 1. Firestore Filters (Server-side)
    if (filter.city != null && filter.city!.isNotEmpty) {
      query = query.where('city', isEqualTo: filter.city);
    }

    if (filter.area != null && filter.area!.isNotEmpty) {
      query = query.where('area', isEqualTo: filter.area);
    }

    if (filter.onlyVerified) {
      query = query.where('userVerificationStatus', isEqualTo: 'verified');
    }

    if (filter.selectedInterestTags.isNotEmpty) {
      // Note: Requires composite index if combined with other equality filters
      query = query.where(
        'interestTags',
        arrayContainsAny: filter.selectedInterestTags,
      );
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    // 2. Client-side Filtering (Budget)
    List<RoommateProfile> profiles = docs
        .map((doc) => RoommateProfile.fromFirestore(doc))
        .toList();

    if (filter.minBudget != null || filter.maxBudget != null) {
      profiles = profiles.where((p) {
        return _budgetOverlaps(
          p.budgetMin,
          p.budgetMax,
          filter.minBudget,
          filter.maxBudget,
        );
      }).toList();
    }

    return profiles;
  }

  bool _budgetOverlaps(double pMin, double pMax, double? fMin, double? fMax) {
    if (fMin == null && fMax == null) return true;
    final min = fMin ?? pMin;
    final max = fMax ?? pMax;
    return pMax >= min && pMin <= max;
  }

  // Calculate Match Score (0-100)
  int calculateMatchScore(RoommateProfile current, RoommateProfile other) {
    int score = 0;

    // 1. City (+30)
    if (current.city.toLowerCase() == other.city.toLowerCase()) {
      score += 30;
    }

    // 2. College (+20)
    if (current.userCollege.toLowerCase() == other.userCollege.toLowerCase()) {
      score += 20;
    }

    // 3. Budget Overlap (+15)
    if (_budgetOverlaps(
      current.budgetMin,
      current.budgetMax,
      other.budgetMin,
      other.budgetMax,
    )) {
      score += 15;
    }

    // 4. Interests (+10 / +5)
    final commonInterests = current.interestTags
        .toSet()
        .intersection(other.interestTags.toSet())
        .length;
    if (commonInterests >= 2) {
      score += 10;
    } else if (commonInterests == 1) {
      score += 5;
    }

    // 5. Sleep Schedule (+10)
    if (current.sleepSchedule == other.sleepSchedule) {
      score += 10;
    }

    // 6. Cleanliness (+10 if diff <= 1)
    if ((current.cleanlinessLevel - other.cleanlinessLevel).abs() <= 1) {
      score += 10;
    }

    // 7. Smoking Mismatch (-25)
    // "no" vs "yes" is a strong mismatch
    if ((current.smoking == 'no' && other.smoking == 'yes') ||
        (current.smoking == 'yes' && other.smoking == 'no')) {
      score -= 25;
    }

    // 8. Gender Preference Mismatch (-20)
    // If current user has a preference and other user doesn't match it
    if (current.preferredGender != 'any' &&
        current.preferredGender != other.userGender) {
      score -= 20;
    }
    // If other user has a preference and current user doesn't match it
    if (other.preferredGender != 'any' &&
        other.preferredGender != current.userGender) {
      score -= 20;
    }

    // 9. Living Situation (+10)
    // Both live alone OR both looking for roommate (implied by being here, but checking flag)
    if (current.livesAlone == other.livesAlone) {
      score += 10;
    }

    return score.clamp(
      0,
      100,
    ); // Ensure score is within 0-100 range (or allow >100 if desired, but clamp is safer for UI)
  }
}
