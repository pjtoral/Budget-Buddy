import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Signup: create auth user, set displayName, then write users/{uid} doc
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final UserCredential uc =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = uc.user!;
      final uid = user.uid;

      // update display name on auth profile
      await user.updateDisplayName(username);
      await user.reload();

      // write Firestore user document (must match rules: doc id == uid)
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'categories': ['School', 'Motorcycle', 'Computer', 'Shabu'],
        'balance': 0.0,
      });

      return {'success': true, 'user': user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? e.code};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Sign in existing user
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential uc =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return {'success': true, 'user': uc.user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? e.code};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}