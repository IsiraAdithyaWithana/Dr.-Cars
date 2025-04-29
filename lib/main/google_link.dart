import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:dr_cars/admin/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class GooglePasswordLinkPage extends StatefulWidget {
  final String email;
  final auth.AuthCredential googleCredential;
  final String userType;

  const GooglePasswordLinkPage({
    required this.email,
    required this.googleCredential,
    required this.userType,
    super.key,
  });

  @override
  State<GooglePasswordLinkPage> createState() => _GooglePasswordLinkPageState();
}

class _GooglePasswordLinkPageState extends State<GooglePasswordLinkPage> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool isLoading = false;

  void _linkAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final emailCredential = EmailAuthProvider.credential(
        email: widget.email,
        password: passwordController.text,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        emailCredential,
      );

      await userCredential.user!.linkWithCredential(widget.googleCredential);

      Widget screen;
      if (widget.userType == "Vehicle Owner") {
        screen = DashboardScreen();
      } else if (widget.userType == "Service Center") {
        screen = HomeScreen();
      } else {
        screen = ServiceCenterApprovalPage();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => screen),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Link Google Account")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Enter your password to link with Google Sign-In"),
              SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "New Password"),
                validator: (val) {
                  if (val == null || val.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Confirm Password"),
                validator: (val) {
                  if (val != passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : _linkAccount,
                child:
                    isLoading
                        ? CircularProgressIndicator()
                        : Text("Link Google Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
