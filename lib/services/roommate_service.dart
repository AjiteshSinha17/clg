
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roommate_profile.dart';

class RoommateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'roommate_profiles';

  // Create or update a roommate profile
  Future<void> saveRoommateProfile(RoommateProfile profile) async {
    await _db.collection(_collectionPath).doc(profile.userId).set(profile.toMap());
  }

  // Get a single roommate profile
  Future<RoommateProfile?> getRoommateProfile(String userId) async {
    final doc = await _db.collection(_collectionPath).doc(userId).get();
    if (doc.exists) {
      return RoommateProfile.fromMap(doc.data()!);
    }
    return null;
  }

  // Get a stream of all roommate profiles
  Stream<List<RoommateProfile>> getRoommateProfilesStream() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => RoommateProfile.fromMap(doc.data())).toList();
    });
  }
}
