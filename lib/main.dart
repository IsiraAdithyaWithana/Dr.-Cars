import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          _buildSettingItem(Icons.person_outline, "Account Setting", context),
          _buildSettingItem(Icons.notifications_outlined, "Notification", context),
          _buildSettingItem(Icons.people_outline, "Interest", context),
          _buildSettingItem(Icons.description_outlined, "Terms and Conditions", context),
          _buildSettingItem(Icons.lock_outline, "Privacy Policy", context),
          _buildSettingItem(Icons.security, "Security", context),
          _buildSettingItem(
            Icons.delete_outline,
            "Delete Account",
            context,
            color: Colors.red,
            onTap: () => _showDeleteAccountDialog(context),
          ),
          _buildSettingItem(
            Icons.logout,
            "Log Out",
            context,
            color: const Color.fromARGB(255, 7, 7, 7),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 30),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: const Color.fromARGB(255, 8, 8, 8),
      ),
=======
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsScreen(),
>>>>>>> a9ffd9591d99d6e92147c92c06bb677163335f15
    );
  }

  // Generic method to build settings items
  Widget _buildSettingItem(
    IconData icon,
    String title,
    BuildContext context, {
    Color color = const Color.fromARGB(220, 0, 0, 0),
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel button
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _logout(context); // Call logout function
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Logout function
  void _logout(BuildContext context) {
    // TODO: Clear authentication session (modify this part for your app)
    // Example: Clear shared preferences, remove tokens, etc.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully")),
    );

    // Navigate to login screen and remove previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // Show delete account confirmation dialog
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel button
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _deleteAccount(context); // Call delete function
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Delete account function (Modify this with actual API call)
  void _deleteAccount(BuildContext context) {
    // TODO: Implement account deletion logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account deleted successfully")),
    );

    // Navigate to login screen after deleting account
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
