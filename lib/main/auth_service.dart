import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? 'YOUR_WEB_CLIENT_ID' : null,
    scopes: ['email'],
  );

  Future<User?> signInWithGoogle() async {
    try {
      // Clear any previous sign-in state
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google Sign In was cancelled by user");
        return null;
      }

      try {
        // Obtain auth details
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create credential
        final AuthCredential credential = GoogleAuthProvider.credential(
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
              'lastLogin': FieldValue.serverTimestamp(),
            });
          } else {
            // Update last login time
            await _firestore.collection('users').doc(user.uid).update({
              'lastLogin': FieldValue.serverTimestamp(),
            });
          }
          return user;
        }
      } catch (e) {
        print("Error during Google authentication: $e");
        // Clean up on error
        await _googleSignIn.signOut();
        await _auth.signOut();
      }
      return null;
    } catch (e) {
      print("Google Sign-In Error: $e");
      // Clean up on error
      try {
        await _googleSignIn.signOut();
        await _auth.signOut();
      } catch (e) {
        print("Error during cleanup: $e");
      }
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
