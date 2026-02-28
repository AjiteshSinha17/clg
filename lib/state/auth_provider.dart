import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../services/onesignal_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        // Update last login timestamp
        await _userService.updateLastLogin(user.uid);
        // Initialize FCM token registration after login
        final notificationService = NotificationService();
        await notificationService.init();

        // Save OneSignal device id to Firestore for Render backend pushes
        try {
          await OneSignalService().syncCurrentUser();
        } catch (_) {}
      } else {
        _user = null;
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user immediately
      _user = userCredential.user;
      
      // Update last login timestamp
      if (_user != null) {
        await _userService.updateLastLogin(_user!.uid);
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user immediately
      _user = userCredential.user;

      // Update display name if provided
      if (displayName != null && _user != null) {
        await _user!.updateDisplayName(displayName);
        await _user!.reload();
        _user = _auth.currentUser;
      }

      // Create user profile in Firestore
      if (_user != null) {
        await _userService.createUserProfile(
          uid: _user!.uid,
          email: email,
          name: displayName ?? email.split('@')[0],
          avatarUrl: _user!.photoURL,
        );
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Configure GoogleSignIn with proper scopes
        final googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw FirebaseAuthException(
            code: 'popup-closed-by-user',
            message: 'Sign-in cancelled.',
          );
        }

        final googleAuth = await googleUser.authentication;
        
        if (googleAuth.idToken == null) {
          throw FirebaseAuthException(
            code: 'missing-id-token',
            message: 'Failed to get ID token from Google Sign-In. Please check Firebase Console configuration.',
          );
        }
        
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      _user = userCredential.user;
      if (_user == null) return;

      // Ensure user profile exists
      final existing = await _userService.getUserProfile(_user!.uid);
      if (existing == null) {
        await _userService.createUserProfile(
          uid: _user!.uid,
          email: _user!.email ?? '',
          name: _user!.displayName ?? (_user!.email?.split('@').first ?? 'User'),
          avatarUrl: _user!.photoURL,
        );
      } else {
        await _userService.updateLastLogin(_user!.uid);
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (_user != null) {
        if (displayName != null) {
          await _user!.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await _user!.updatePhotoURL(photoURL);
        }
        await _user!.reload();
        _user = _auth.currentUser;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
