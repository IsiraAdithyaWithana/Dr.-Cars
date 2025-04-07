import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:flutter/material.dart';

class GoogleProfileCompletionPage extends StatefulWidget {
  final String uid;
  final String name;
  final String email;

  const GoogleProfileCompletionPage({
    required this.uid,
    required this.name,
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  State<GoogleProfileCompletionPage> createState() =>
      _GoogleProfileCompletionPageState();
}

class _GoogleProfileCompletionPageState
    extends State<GoogleProfileCompletionPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitProfile() async {
    if (usernameController.text.isEmpty ||
        addressController.text.isEmpty ||
        contactController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill in all fields")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final username = usernameController.text.trim();

      final existing =
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(username)
              .get();

      if (existing.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Username already taken")));
        setState(() => _isLoading = false);
        return;
      }

      await FirebaseFirestore.instance.collection("Users").doc(username).set({
        "Name": widget.name,
        "Email": widget.email,
        "Username": username,
        "Address": addressController.text.trim(),
        "Contact": contactController.text.trim(),
        "User Type": "Vehicle Owner",
        "uid": FirebaseAuth.instance.currentUser?.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving profile: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  Image.asset('images/bg_removed_logo.png', height: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'Complete Your Profile',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text("Name: ${widget.name}", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    "Email: ${widget.email}",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitProfile,
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Continue'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
