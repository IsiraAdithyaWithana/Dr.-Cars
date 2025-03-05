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
          _buildSettingItem(
            Icons.notifications_outlined,
            "Notification",
            context,
          ),
          _buildSettingItem(Icons.people_outline, "Interest", context),
          _buildSettingItem(
            Icons.description_outlined,
            "Terms and conditions",
            context,
          ),
          _buildSettingItem(Icons.lock_outline, "Privacy policy", context),
          _buildSettingItem(Icons.security, "Security", context),
          _buildSettingItem(
            Icons.delete_outline,
            "Delete Account",
            context,
            color: Colors.red,
          ),
          _buildSettingItem(Icons.logout, "Log Out", context),
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

  Widget _buildSettingItem(
    IconData icon,
    String title,
    BuildContext context, {
    Color color = const Color.fromARGB(220, 0, 0, 0),
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}
