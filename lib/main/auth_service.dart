import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signUp(
    String fullName,
    String email,
    String password,
    String username,
    String address,
    String contact,
  ) async {
    try {
      print("Creating user with email: $email");

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        print("User created: ${user.uid}");

        await _firestore.collection("Users").doc(user.uid).set({
          "Name": fullName,
          "Email": email,
          "Username": username,
          "Address": address,
          "Contact": contact,
        });

        return user;
      } else {
        print("User is null after creation.");
        return null;
      }
    } catch (e) {
      print("Sign-up error: $e");
      return null;
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
    await _auth.signOut();
  }
}
