import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/main/signin.dart';
import 'package:flutter/material.dart';

class CheckRequestStatusPage extends StatefulWidget {
  const CheckRequestStatusPage({super.key});

  @override
  State<CheckRequestStatusPage> createState() => _CheckRequestStatusPageState();
}

class _CheckRequestStatusPageState extends State<CheckRequestStatusPage> {
  final TextEditingController emailController = TextEditingController();
  String? statusMessage;
  bool isLoading = false;

  Future<void> checkStatus() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        statusMessage = "Please enter an email address.";
      });
      return;
    }

    setState(() {
      isLoading = true;
      statusMessage = null;
    });

    try {
      final userQuery =
          await FirebaseFirestore.instance
              .collection("Users")
              .where("Email", isEqualTo: email)
              .where("User Type", isEqualTo: "Service Center")
              .limit(1)
              .get();

      if (userQuery.docs.isNotEmpty) {
        setState(() {
          statusMessage = '''
✅ Your account has been approved!

📧 **Email:** $email  
🔐 **Password:** "Reset your password"

⚠️ Please reset your password during your first login using the "Forgot Password" option on the login screen.
''';
        });
      } else {
        final requestQuery =
            await FirebaseFirestore.instance
                .collection("ServiceCenterRequests")
                .where("email", isEqualTo: email)
                .limit(1)
                .get();

        if (requestQuery.docs.isEmpty) {
          statusMessage = "No request found for this email.";
        } else {
          final status = requestQuery.docs.first['status'];
          if (status == "rejected") {
            statusMessage =
                "❌ Your request has been rejected. Please contact support for more information.";
          } else {
            statusMessage =
                "⌛ Your request is still pending. Please check again later.";
          }
        }
      }
    } catch (e) {
      statusMessage = "An error occurred while checking status.";
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Request Status"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Enter your email to check your service center account status",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : checkStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text("Check Status"),
              ),
              const SizedBox(height: 30),
              if (statusMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        statusMessage!,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                        textAlign: TextAlign.left,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: Text("Home"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
