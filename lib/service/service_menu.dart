import 'package:flutter/material.dart';
import 'records_screen.dart';
import 'appointments_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vehicle Service App')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Show password dialog
                bool isAuthenticated = await showDialog(
                  context: context,
                  builder: (context) => PasswordDialog(),
                );

                if (isAuthenticated) {
                  // Navigate to RecordsScreen if password is correct
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecordsScreen()),
                  );
                } else {
                  // Show error message if password is incorrect
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Wrong password")));
                }
              },
              child: Text("Go to Records Screen"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppointmentsScreen()),
                );
              },
              child: Text("Go to Appointments Screen"),
            ),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Password'),
      content: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(labelText: 'Password'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Return false if canceled
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_passwordController.text == 'Isira') {
              Navigator.of(
                context,
              ).pop(true); // Return true if password is correct
            } else {
              Navigator.of(
                context,
              ).pop(false); // Return false if password is incorrect
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
