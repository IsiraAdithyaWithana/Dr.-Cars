import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/main/auth_service.dart';
import 'package:dr_cars/main/signup_selection.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dr_cars/main/google_profile_completion.dart';
import 'package:dr_cars/admin/admin_home.dart';

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
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;

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
      } catch (e) {}
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
      String emailToUse;

      if (input.contains('@')) {
        emailToUse = input;
      } else {
        final query =
            await FirebaseFirestore.instance
                .collection("Users")
                .where("Username", isEqualTo: input)
                .limit(1)
                .get();

        if (query.docs.isEmpty) {
          throw Exception("No user found with that username");
        }

        emailToUse = query.docs.first["Email"];
      }

      await _authService.signIn(emailToUse, password);

      String userType = await _fetchUserType();

      Widget targetScreen;
      if (userType == "Vehicle Owner") {
        targetScreen = DashboardScreen();
      } else if (userType == "Service Center") {
        targetScreen = HomeScreen();
      } else if (userType == "App Admin") {
        targetScreen = ServiceCenterApprovalPage();
      } else {
        targetScreen = DashboardScreen();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Sign In Failed: ${e.toString().replaceFirst('Exception: ', '')}",
          ),
        ),
      );
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

    try {
      final googleUser = await _authService.getGoogleUser();
      final googleAuth = await googleUser?.authentication;

      if (googleUser == null || googleAuth == null) {
        throw Exception("Google sign-in cancelled");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(googleUser.email);

      if (signInMethods.contains('password') &&
          !signInMethods.contains('google.com')) {
        final passwordController = TextEditingController();
        String? password = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Account Linking Required"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "This email is already registered with a password. Enter password to link Google account.",
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: "Password"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text("Link"),
                  onPressed:
                      () => Navigator.pop(context, passwordController.text),
                ),
              ],
            );
          },
        );

        if (password == null || password.isEmpty) return;

        final emailCredential = EmailAuthProvider.credential(
          email: googleUser.email,
          password: password,
        );

        final emailUser = await FirebaseAuth.instance.signInWithCredential(
          emailCredential,
        );
        await emailUser.user!.linkWithCredential(credential);

        final userType = await _fetchUserType();

        Widget screen;
        if (userType == "Vehicle Owner") {
          screen = DashboardScreen();
        } else if (userType == "Service Center") {
          screen = HomeScreen();
        } else {
          screen = DashboardScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
        return;
      }

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => GoogleProfileCompletionPage(
                  uid: userCredential.user!.uid,
                  name: googleUser.displayName ?? '',
                  email: googleUser.email,
                ),
          ),
        );
      } else {
        final userType = await _fetchUserType();

        Widget screen;
        if (userType == "Vehicle Owner") {
          screen = DashboardScreen();
        } else if (userType == "Service Center") {
          screen = HomeScreen();
        } else {
          screen = DashboardScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      }
    } catch (e) {
      print("Google Sign-in Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isGoogleLoading = false;
      });
    }
  }

  void _ResetPassword() async {
    final input = _emailOrUsernameController.text.trim();

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your email or username")),
      );
      return;
    }

    setState(() {
      isResettingPassword = true;
    });

    try {
      String emailToUse;

      if (input.contains('@')) {
        emailToUse = input;
      } else {
        final query =
            await FirebaseFirestore.instance
                .collection("Users")
                .where("Username", isEqualTo: input)
                .limit(1)
                .get();

        if (query.docs.isEmpty) {
          throw Exception("No user found with that username");
        }

        emailToUse = query.docs.first["Email"];
      }

      await _authService.resetPassword(emailToUse);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset link sent to your email")),
      );
    } catch (e) {
      String errorMessage = e.toString().replaceFirst(
        RegExp(r'^Exception[:]? ?'),
        '',
      );
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
          child: Form(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              key: _formKey,
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
                  TextFormField(
                    controller: _emailOrUsernameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter email or username';
                      }

                      final input = value.trim();
                      final isEmail = input.contains('@');
                      final isValidUsername = RegExp(
                        r'^[a-z0-9._]+$',
                      ).hasMatch(input);

                      if (!isEmail && !isValidUsername) {
                        return 'Enter a valid email or username';
                      }

                      return null;
                    },
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
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Password is required';
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
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
      ),
    );
  }
}
