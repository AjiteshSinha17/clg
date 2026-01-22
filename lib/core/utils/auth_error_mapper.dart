import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart';

class AuthErrorMapper {
  static String message(Object error, {String fallback = 'Something went wrong'}) {
    // Handle PlatformException (Google Sign-In errors)
    if (error is PlatformException) {
      final code = error.code;
      final message = error.message ?? '';
      
      // Google Sign-In error code 10 = DEVELOPER_ERROR
      if (code == 'sign_in_failed' || message.contains('ApiException: 10')) {
        return 'Google Sign-In not configured. Please add SHA-1 and SHA-256 fingerprints to Firebase Console.\n\nRun: .\\get_sha_fingerprints.ps1\nThen follow GOOGLE_SIGNIN_SETUP.md';
      }
      
      if (code == 'sign_in_cancelled' || message.contains('cancelled')) {
        return 'Sign-in cancelled.';
      }
      
      return 'Google Sign-In error: ${message.isNotEmpty ? message : code}';
    }
    
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'Password is too weak (min 6 characters).';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled in Firebase.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method.';
        case 'popup-closed-by-user':
          return 'Sign-in cancelled.';
        case 'sign_in_failed':
        case 'sign-in-failed':
          return 'Google Sign-In configuration error. Please add SHA-1 and SHA-256 fingerprints to Firebase Console. See GOOGLE_SIGNIN_SETUP.md for instructions.';
        default:
          return error.message ?? fallback;
      }
    }

    final text = error.toString();
    if (text.contains('failed-precondition') && text.toLowerCase().contains('index')) {
      return 'Database index missing for this query. Please create the required Firestore index (check the debug console link).';
    }
    
    // Check for Google Sign-In error in string
    if (text.contains('ApiException: 10') || text.contains('sign_in_failed')) {
      return 'Google Sign-In not configured. Please add SHA-1 and SHA-256 fingerprints to Firebase Console.\n\nRun: .\\get_sha_fingerprints.ps1\nThen follow GOOGLE_SIGNIN_SETUP.md';
    }

    return fallback;
  }
}

