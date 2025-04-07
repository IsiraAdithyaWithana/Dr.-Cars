import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      String userType = "Vehicle Owner";
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // 🔹 Check if the user already exists in Firestore
        final doc = await _firestore.collection('Users').doc(user.uid).get();

        if (!doc.exists) {
          // 🔹 Store user data in Firestore
          await _firestore.collection('Users').doc(user.uid).set({
            'Name': user.displayName ?? 'Unknown',
            'Email': user.email,
            "User Type": userType,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
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

        await _firestore.collection("Users").doc(user.uid).set({
          "Name": fullName,
          "Email": email,
          "Username": username,
          "Address": address,
          "Contact": contact,
          "User Type": userType,
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

  Future<void> resetPassword(String email) async {
    try {
      final query =
          await FirebaseFirestore.instance
              .collection("Users")
              .where("Email", isEqualTo: email.trim())
              .get();

      if (query.docs.isEmpty) {
        throw Exception("No user found with this email");
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
