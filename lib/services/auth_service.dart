import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prepify/services/user_profile_service.dart';

/// Simple fire‑and‑forget authentication helper used throughout the app.
/// Keeps all the raw firebase API calls in one place so controllers can stay
/// focused on UI logic and error handling.
class AuthService {
  AuthService._(); // private ctor to prevent instantiation

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the current signed‑in user, or `null` if none.
  static User? get currentUser => _auth.currentUser;

  /// Creates a new account with [email] / [password] and writes user data to
  /// the `users` collection. The document id is the same as the Firebase uid.
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;
    await UserProfileService.ensureUserDocument(
      uid: uid,
      fallbackName: name,
      fallbackEmail: email,
    );

    // also update display name on the auth profile for convenience
    await cred.user!.updateDisplayName(name);

    return cred;
  }

  /// Signs in with [email]/[password]. Throws whatever firebase throws.
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await UserProfileService.ensureUserDocument(
        uid: user.uid,
        fallbackName: user.displayName,
        fallbackEmail: user.email,
      );
    }
    return credential;
  }

  /// Sends a password reset email to [email].
  static Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Signs the current user out.
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Fetches additional metadata stored in Firestore for the given [uid].
  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  /// Updates the user's name in Firestore (and the displayName on the auth
  /// profile) so it can be shown elsewhere in the app.
  static Future<void> updateUserName(String uid, String newName) async {
    await _db.collection('users').doc(uid).update({'name': newName});
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(newName);
    }
  }
}
