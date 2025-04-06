import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user already exists in Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          // Store user data in Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'Unknown',
            'email': user.email,
            'userType': 'Vehicle Owner',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        return user;
      }
      return null;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<User?> signUp(
    String fullName,
    String email,
    String password,
    String username,
    String address,
    String contact,
  ) async {
    try {
      String userType = "Vehicle Owner";
      print("Creating user with email: $email");

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        print("User created: ${user.uid}");

        await _firestore.collection("users").doc(user.uid).set({
          "name": fullName,
          "email": email,
          "username": username,
          "address": address,
          "contact": contact,
          "userType": userType,
          "createdAt": FieldValue.serverTimestamp(),
        });

        return user;
      } else {
        print("User is null after creation.");
        return null;
      }
    } catch (e) {
      print("Sign-up error: $e");
      rethrow; // Rethrow the error to handle it in the UI
    }
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Sign in
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
