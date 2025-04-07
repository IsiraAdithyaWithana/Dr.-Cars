import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/main/auth_service.dart';
import 'package:dr_cars/main/signup_selection.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dr_cars/main/google_profile_completion.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailOrUsernameController =
      TextEditingController();

  bool isLoading = false;
  bool isGoogleLoading = false;
  bool isResettingPassword = false;

  Future<String> _fetchUserType() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData =
            await _firestore.collection("Users").doc(user.uid).get();
        return userData.exists ? userData["User Type"] ?? "User" : "User";
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
    return "User";
  }

  void _handleSignIn() async {
    setState(() {
      isLoading = true;
    });

    final input = _emailOrUsernameController.text.trim();
    final password = _passwordController.text;

    try {
      String email;

      if (input.contains('@')) {
        // It's an email
        email = input;
      } else {
        // It's a username — find email from Firestore
        final userDoc =
            await FirebaseFirestore.instance
                .collection("Users")
                .doc(input) // username = doc ID
                .get();

        if (!userDoc.exists) {
          throw Exception("No user found with that username");
        }

        email = userDoc["Email"];
      }

      // Sign in using email + password
      await _authService.signIn(email, password);

      // Redirect based on user type
      String userType = await _fetchUserType();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  userType == "Vehicle Owner"
                      ? DashboardScreen()
                      : HomeScreen(),
        ),
      );
    } catch (e) {
      String errorMessage = e.toString().replaceFirst(
        RegExp(r'^Exception: '),
        '',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sign In Failed: $errorMessage")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleGoogleSignIn() async {
    setState(() {
      isGoogleLoading = true;
    });

    final user = await _authService.signInWithGoogle();

    if (user != null) {
      if (user["newUser"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => GoogleProfileCompletionPage(
                  uid: user["uid"],
                  name: user["name"],
                  email: user["email"],
                ),
          ),
        );
      } else {
        String userType = await _fetchUserType();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    userType == "Vehicle Owner"
                        ? DashboardScreen()
                        : HomeScreen(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Google Sign-In Failed")));
    }

    setState(() {
      isGoogleLoading = false;
    });
  }

  void _ResetPassword() async {
    final email = _emailOrUsernameController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your email to reset password")),
      );
      return;
    }

    setState(() {
      isResettingPassword = true;
    });

    try {
      await _authService.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset link sent to your email")),
      );
    } catch (e) {
      String errorMessage = e.toString();
      errorMessage = errorMessage.replaceFirst(RegExp(r'^Exception[:]? ?'), '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send reset email: $errorMessage")),
      );
    } finally {
      setState(() {
        isResettingPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/bg_removed_logo.png', height: 100),
                SizedBox(height: 20),
                Text(
                  "Log in to Dr. Cars",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text("Enter your email to sign up for this app"),
                SizedBox(height: 20),
                TextField(
                  controller: _emailOrUsernameController,
                  decoration: InputDecoration(
                    hintText: "Email or Username",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child:
                      isLoading
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text("Continue"),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child:
                      isResettingPassword
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : TextButton(
                            onPressed: _ResetPassword,
                            child: Text("Forgot Password?"),
                          ),
                ),
                Text("or"),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: isGoogleLoading ? null : _handleGoogleSignIn,
                  icon:
                      isGoogleLoading
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                          : Image.asset('images/google_ico.png', height: 24),
                  label:
                      isGoogleLoading
                          ? Text("Signing in...")
                          : Text("Continue with Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignupSelection(),
                      ),
                    );
                  },
                  child: Text('Create an account'),
                ),
                SizedBox(height: 20),
                Text(
                  'By clicking continue, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
