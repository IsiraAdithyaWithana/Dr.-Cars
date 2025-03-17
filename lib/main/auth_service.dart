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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await _firestore.collection("Users").doc(userCredential.user!.uid).set({
          "Name": fullName,
          "Email": email,
          "Username": username,
          "Address": address,
          "Contact": contact,
        });

        return userCredential.user;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get User Data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection("Users").doc(uid).get();
  }
}
