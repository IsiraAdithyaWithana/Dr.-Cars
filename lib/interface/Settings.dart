import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/service_history.dart';
import 'package:flutter/material.dart';
import 'package:dr_cars/interface/obd2.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/main/signin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dr_cars/main.dart'; // for themeNotifier

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          home: const SettingsScreen(),
        );
      },
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Sinhala', 'Tamil'];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  final String _supportEmail = 'mailto:support@drcars.com';
  final String _supportPhone = 'tel:+94772111426';
  final String _supportChat = 'https://wa.me/+94772111426';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadUserData();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      themeNotifier.value = _darkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get();

        if (userData.exists) {
          setState(() {
            _nameController.text = userData['Name'] ?? '';
            _emailController.text = userData['Email'] ?? '';
            _phoneController.text = userData['Contact'] ?? '';
            _notificationsEnabled = userData['notificationsEnabled'] ?? true;
            _selectedLanguage = userData['language'] ?? 'English';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
              'Name': _nameController.text,
              'Email': _emailController.text,
              'Contact': _phoneController.text,
              'notificationsEnabled': _notificationsEnabled,
              'language': _selectedLanguage,
            });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('darkMode', _darkMode);
        themeNotifier.value = _darkMode ? ThemeMode.dark : ThemeMode.light;

        _showSnackBar('Settings Updated Successfully');
      }
    } catch (e) {
      _showSnackBar('Error Updating Settings');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    final isError = message.toLowerCase().contains('error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateUserData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  _buildSectionHeader('Account Settings'),
                  _buildSettingItem(
                    Icons.person_outline,
                    "Personal Information",
                    onTap: () => _showPersonalInfoDialog(context),
                  ),
                  _buildSettingItem(
                    Icons.notifications_outlined,
                    "Notifications",
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged:
                          (v) => setState(() => _notificationsEnabled = v),
                    ),
                  ),
                  _buildSettingItem(
                    Icons.language,
                    "Language",
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      items:
                          _languages
                              .map(
                                (lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(lang),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedLanguage = v);
                        }
                      },
                    ),
                  ),
                  _buildSettingItem(
                    Icons.dark_mode,
                    "Dark Mode",
                    trailing: Switch(
                      value: _darkMode,
                      onChanged:
                          (v) => setState(() {
                            _darkMode = v;
                            themeNotifier.value =
                                v ? ThemeMode.dark : ThemeMode.light;
                          }),
                    ),
                  ),
                  _buildSectionHeader('Privacy & Security'),
                  _buildSettingItem(
                    Icons.lock_outline,
                    "Privacy policy",
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _buildSettingItem(
                    Icons.security,
                    "Security",
                    onTap: () => _showSecuritySettings(context),
                  ),
                  _buildSettingItem(
                    Icons.password,
                    "Change Password",
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  _buildSectionHeader('Support'),
                  _buildSettingItem(
                    Icons.help_outline,
                    "Help & Support",
                    onTap: () => _showHelpSupport(context),
                  ),
                  _buildSettingItem(
                    Icons.description_outlined,
                    "Terms and conditions",
                    onTap: () => _showTermsAndConditions(context),
                  ),
                  _buildSettingItem(
                    Icons.info_outline,
                    "About",
                    onTap: () => _showAboutDialog(context),
                  ),
                  _buildSectionHeader('Account Actions'),
                  _buildSettingItem(
                    Icons.delete_outline,
                    "Delete account",
                    color: Colors.red,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                  _buildSettingItem(
                    Icons.logout,
                    "Log Out",
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: theme.colorScheme.secondary,
        unselectedItemColor: theme.iconTheme.color,
        currentIndex: 4,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DashboardScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MapScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OBD2Page()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ServiceHistorypage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', width: 30, height: 30),
            label: '',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final itemColor = color ?? theme.iconTheme.color;
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(color: itemColor),
      ),
      trailing:
          trailing ??
          Icon(Icons.arrow_forward_ios, size: 16, color: theme.iconTheme.color),
      onTap: onTap,
    );
  }

  void _showPersonalInfoDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder:
          (_) => AlertDialog(
            title: const Text('Personal Information'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _updateUserData();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (newPasswordController.text ==
                      confirmPasswordController.text) {
                    _changePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                    );
                    Navigator.pop(context);
                  } else {
                    _showSnackBar('Passwords do not match');
                  }
                },
                child: Text('Change'),
              ),
            ],
          ),
    );
  }

  Future<void> _changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Reauthenticate user before changing password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // Change password
        await user.updatePassword(newPassword);
        _showSnackBar('Password changed successfully');
      }
    } catch (e) {
      _showSnackBar('Error changing password: $e');
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Privacy Policy'),
            content: SingleChildScrollView(
              child: Text('''Privacy Policy for Dr Cars

Effective Date: April 23, 2025

At Dr Cars, we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our car service booking app.

1. Information We Collect

When you use Dr Cars, we may collect the following personal information:
- Full Name
- Address
- Phone Number
- Email Address
- Username

This information is collected to provide you with a smooth and personalized experience when booking car services.

2. How We Use Your Information

We use your information to:
- Register and manage your account
- Process and confirm your service bookings
- Communicate with you regarding your bookings and support inquiries
- Improve our services and user experience
- Ensure security and prevent unauthorized access

3. Data Sharing

We do not sell, trade, or rent your personal information to third parties. We may share your information only:
- With service professionals (e.g., mechanics or garages) to fulfill your booking
- When required by law or legal process
- To protect the rights, property, or safety of Dr Cars and its users

4. Data Security

We implement reasonable safeguards to protect your personal information from unauthorized access, use, or disclosure.

5. Your Choices

You can review, update, or delete your personal information by contacting us or through your account settings in the app.

6. Changes to This Policy

We may update this Privacy Policy from time to time. If we make any significant changes, we will notify you through the app or by email.

7. Contact Us

If you have any questions or concerns about this Privacy Policy, please contact us at:
- Email: support@drcars.com
- Phone: +94 77 211 1426
- Chat: https://wa.me/+94772111426
'''),
            ),
            actions: [
              TextButton(
                onPressed: () => _launchUrl('mailto:support@drcars.com'),
                child: Text('Email Us'),
              ),
              TextButton(
                onPressed: () => _launchUrl('tel:+94772111426'),
                child: Text('Call Us'),
              ),
              TextButton(
                onPressed: () => _launchUrl('https://wa.me/+94772111426'),
                child: Text('Chat Support'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showSecuritySettings(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Security Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text('Two-Factor Authentication'),
                  subtitle: Text(
                    'Add an extra layer of security to your account',
                  ),
                  value: false,
                  onChanged: (value) {
                    // This will be implemented later
                    _showSnackBar('This feature will be available soon');
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Help & Support'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email Support'),
                  subtitle: Text(_supportEmail),
                  onTap: () => _launchUrl('mailto:$_supportEmail'),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Call Support'),
                  subtitle: Text(_supportPhone),
                  onTap: () => _launchUrl('tel:$_supportPhone'),
                ),
                ListTile(
                  leading: Icon(Icons.chat),
                  title: Text('Live Chat'),
                  subtitle: Text('Click to start chat'),
                  onTap: () => _launchUrl(_supportChat),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Terms and Conditions'),
            content: SingleChildScrollView(
              child: Text('''Terms and Conditions for Dr Cars

Effective Date: April 23, 2025

Please read these Terms and Conditions ("Terms") carefully before using the Dr Cars app. By accessing or using the app, you agree to be bound by these Terms.

1. Use of the App
You agree to use the Dr Cars app only for lawful purposes and in accordance with these Terms. You may not misuse the app or interfere with its normal operation.

2. Service Bookings
All service bookings made through the app are subject to availability and confirmation. We reserve the right to cancel or refuse any booking at our discretion.

3. User Information
You are responsible for providing accurate and up-to-date information during registration and booking. Any false or misleading information may result in suspension of your account.

4. Payments
Prices and fees for services are displayed in the app and may vary based on location and service provider. All payments must be completed as per the method specified during booking.

5. Cancellations and Refunds
You may cancel a service within the allowed cancellation window specified during booking. Refunds (if applicable) are processed based on the service provider’s policy.

6. Intellectual Property
All content, branding, and features of the Dr Cars app are the property of Dr Cars or its licensors. You may not copy, modify, or distribute any part of the app without permission.

7. Limitation of Liability
Dr Cars is not responsible for any direct or indirect damages resulting from use of the app or services booked through it. We act solely as a platform connecting users and service providers.

8. Changes to Terms
We may update these Terms from time to time. Continued use of the app after changes means you accept the new Terms.

9. Governing Law
These Terms are governed by and interpreted in accordance with the laws of [Your Country/Region].

10. Contact Us
If you have any questions about these Terms, please contact us at:
Email: support@drcars.com
Phone: +94 77 211 1426
Chat: https://wa.me/+94772111426
'''),
            ),
            actions: [
              TextButton(
                onPressed: () => _launchUrl('mailto:support@drcars.com'),
                child: Text('Email Us'),
              ),
              TextButton(
                onPressed: () => _launchUrl('tel:+94772111426'),
                child: Text('Call Us'),
              ),
              TextButton(
                onPressed: () => _launchUrl('https://wa.me/+94772111426'),
                child: Text('Chat Support'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('About'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('images/logo.png', height: 100),
                SizedBox(height: 16),
                Text('Dr. Cars v1.0.0'),
                Text('© 2025 Dr. Cars. All rights reserved.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _logout(context);
              },
              child: Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Account"),
          content: Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteAccount(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Successfully logged out!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to signin page and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging out: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .delete();
        // Delete the user account
        await user.delete();

        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully Deleted Account!"),
            backgroundColor: const Color.fromARGB(255, 99, 215, 103),
          ),
        );

        // Navigate to signin page and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting account: $e"),
          backgroundColor: const Color.fromARGB(255, 242, 55, 22),
        ),
      );
    }
  }
}
