import 'package:auctify_dashboard/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Email & Password login
  Future<UserModel?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      // Check if user is admin
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data['role'] == 'admin') {
          // Add UID to map if missing before converting
          data['uid'] = uid;
          return UserModel.fromMap(data);
        }
      }

      // If we reach here, user is not admin or doc doesn't exist
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'not-admin',
        message: 'You are not an admin user',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
