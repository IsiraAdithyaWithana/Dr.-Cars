import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/main/signin.dart';
import 'package:dr_cars/service/service_receipts_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'records_screen.dart';
import 'appointments_screen.dart';
import 'add_vehicle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                "Loading...",
                style: TextStyle(color: Colors.white),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text(
                "Welcome",
                style: TextStyle(color: Colors.white),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data['Name'] ?? 'Service Center';

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'images/logo.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Welcome $name - Service Center",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('Service_Receipts')
                          .where('status', whereIn: ['confirmed', 'rejected'])
                          .where(
                            'serviceCenterId',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                          )
                          .snapshots(),
                  builder: (context, snapshot) {
                    int count =
                        snapshot.hasData ? snapshot.data!.docs.length : 0;

                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ServiceReceiptsPage(),
                              ),
                            );
                          },
                        ),
                        if (count > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: Image.asset('images/bg_removed_logo.png', height: 150),
                ),
                const SizedBox(height: 50),
                _buildMenuButton(
                  context,
                  text: "Add New",
                  subtext: "Add new vehicles and add services",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddVehicle()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildMenuButton(
                  context,
                  text: "Records",
                  subtext: "For quick view of services (For non users)",
                  onPressed: () async {
                    bool isAuthenticated = await showDialog(
                      context: context,
                      builder: (context) => PasswordDialog(),
                    );
                    if (isAuthenticated) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordsScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Wrong password")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                _buildMenuButton(
                  context,
                  text: "Appointments",
                  subtext: "Accept service appointments",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentsScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String text,
    required String subtext,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 300,
      height: 90,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(subtext, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key});

  @override
  _PasswordDialogState createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<bool> _verifyPassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      final password = _passwordController.text.trim();

      if (email == null || password.isEmpty) {
        return false;
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user!.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _errorText,
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            setState(() {
              _isLoading = true;
              _errorText = null;
            });

            final isAuthenticated = await _verifyPassword();

            setState(() {
              _isLoading = false;
            });

            if (isAuthenticated) {
              Navigator.of(context).pop(true);
            } else {
              setState(() {
                _errorText = "Wrong password!";
              });
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
