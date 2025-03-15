import 'package:flutter/material.dart';
import 'dashboard.dart'; // Import your Dashboard screen

int _selectedIndex = 4;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.black),
          onPressed: () {
            _navigateToDashboard(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('images/logo.png'),
            ),
            SizedBox(height: 10),
            Text(
              'User Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildTextField(label: "Name", hintText: "Name of user"),
            _buildTextField(label: "User Name", hintText: "Username"),
            _buildTextField(label: "Address", hintText: "Address"),
            _buildTextField(label: "Contact", hintText: "Contact Number"),
            _buildTextField(label: "E-mail", hintText: "email"),
            _buildDropdown(label: "Vehicle Model"),
            _buildDropdown(label: "Vehicle Year"),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                _showPopupMessage(context);
              },
              child: Text("Continue", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
         selectedItemColor: Colors.red,
         unselectedItemColor: Colors.black,
         currentIndex: _selectedIndex, // Highlight selected item
         onTap: (index) {
         (() {
         _selectedIndex = index; // Update selected index
          });

         if (index == 0) { // Navigate when "User" icon is clicked
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }
     if (index == 4) { // Navigate when "User" icon is clicked
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
  },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label:''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
       
      ),
    );
  }

  void _showPopupMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Your data was saved."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }

  Widget _buildTextField({required String label, required String hintText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items:
            [
              'Car before 2020',
              'Car before 2010',
              'Car before 2000',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) {},
      ),
    );
  }
}
