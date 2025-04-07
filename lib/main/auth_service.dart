import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

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
        final doc = await _firestore.collection('Users').doc(user.uid).get();

        if (!doc.exists) {
          return {
            "newUser": true,
            "uid": user.uid,
            "name": user.displayName ?? "",
            "email": user.email ?? "",
          };
        }

        return {"newUser": false, "uid": user.uid};
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

      final existing = await _firestore.collection("Users").doc(username).get();
      if (existing.exists) {
        throw Exception("Username already taken. Please choose another.");
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection("Users").doc(username).set({
          "Name": fullName,
          "Email": email,
          "Username": username,
          "Address": address,
          "Contact": contact,
          "User Type": userType,
          "uid": user.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });

        return user;
      } else {
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        List<String> methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.contains('google.com')) {
          throw Exception(
            "This email is already registered with Google. Please sign in using Google first.",
          );
        } else {
          throw Exception("This email is already in use.");
        }
      } else {
        throw Exception(e.message ?? "Unknown error");
      }
    } catch (e) {
      throw Exception("Sign-up error: $e");
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  bool isSignedIn() {
    return _auth.currentUser != null;
  }

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
