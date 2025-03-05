import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [IconButton(icon: Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: ListView(
        children: [
          _buildSettingItem(Icons.person_outline, "Account Setting", context),
          _buildSettingItem(Icons.notifications_outlined, "Notification", context),
          _buildSettingItem(Icons.people_outline, "Interest", context),
          _buildSettingItem(Icons.description_outlined, "Terms and conditions", context),
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
            color: const Color.fromARGB(255, 14, 13, 13),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: const Color.fromARGB(255, 8, 8, 8),
      ),
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
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel button
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _logout(context); // Call logout function
              },
              child: Text("Log Out", style: TextStyle(color: Colors.red)),
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
      SnackBar(content: Text("Logged out successfully")),
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
          title: Text("Delete Account"),
          content: Text("Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel button
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _deleteAccount(context); // Call delete function
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Delete account function (Modify this with actual API call)
  void _deleteAccount(BuildContext context) {
    // TODO: Implement account deletion logic
    // Example: Call API to delete account, clear user data, etc.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Account deleted successfully")),
    );

    // Navigate to login screen after deleting account
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
