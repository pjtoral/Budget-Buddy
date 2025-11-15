import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserDoc(cred.user);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendly(e));
    }
  }

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? username,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
      }
      await _ensureUserDoc(
        cred.user,
        extraData: {
          if (username != null && username.isNotEmpty) 'username': username,
        },
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendly(e));
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Mobile/Desktop Google Sign-In
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      await _ensureUserDoc(cred.user);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendly(e));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendly(e));
    }
  }

  Future<void> signOut() async {
    try {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _ensureUserDoc(
    User? user, {
    Map<String, dynamic>? extraData,
  }) async {
    if (user == null) return;
    final doc = _db.collection('users').doc(user.uid);
    final snap = await doc.get();
    final now = FieldValue.serverTimestamp();
    if (!snap.exists) {
      await doc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'balance': 0.0,
        'createdAt': now,
        'updatedAt': now,
        ...?extraData,
      }, SetOptions(merge: true));
    } else {
      await doc.update({'updatedAt': now});
    }
  }

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
