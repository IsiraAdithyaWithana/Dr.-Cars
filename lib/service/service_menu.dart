import 'package:dr_cars/main/signin.dart';
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                // Centered Logo at the Top
                SizedBox(
                  width: double.infinity,
                  child: Image.asset('images/bg_removed_logo.png', height: 150),
                ),
                const SizedBox(height: 50),

                // Buttons with increased spacing and adjusted size
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

                const SizedBox(height: 24), // Increased spacing

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

                const SizedBox(height: 24), // Increased spacing

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
                    await FirebaseAuth.instance.signOut(); // Sign out user
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInScreen(),
                      ), // Go back to Welcome
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red sign-out button
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

  // Custom Button Widget with Fixed Size
  Widget _buildMenuButton(
    BuildContext context, {
    required String text,
    required String subtext,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 300, // Reduced button width
      height: 90, // Increased button height
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Ensures text spacing
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

// Password Dialog for Records Screen
class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key});

  @override
  _PasswordDialogState createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Password'),
      content: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_passwordController.text == 'Isira') {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).pop(false);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
