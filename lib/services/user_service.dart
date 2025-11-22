
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionPath = 'users';

  // Create a new user document
  Future<void> createUser(UserModel user) async {
    await _db.collection(_collectionPath).doc(user.uid).set(user.toMap());
  }

  // Get a single user by UID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(_collectionPath).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Update a user's profile
  Future<void> updateUser(UserModel user) async {
    await _db.collection(_collectionPath).doc(user.uid).update(user.toMap());
  }

  // Get a stream of all users (for the roommate grid)
  Stream<List<UserModel>> getUsersStream() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }
}
