import 'package:dr_cars/interface/rating.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart'; // Import your Dashboard screen

int _selectedIndex = 4;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? selectedBrand;
  String? selectedModel;
  String? selectedType;

  final Map<String, List<String>> vehicleModels = {
    'Toyota': ['Corolla', 'Camry', 'RAV4', 'Hilux', 'Land Cruiser'],
    'Nissan': ['Sunny', 'X-Trail', 'Patrol', 'Navara', 'GT-R'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Vezel', 'City'],
    'Suzuki': ['Alto', 'Swift', 'Dzire', 'Baleno', 'Jimny'],
  };

  final List<String> vehicleTypes = ['Car', 'SUV', 'Truck', 'Buses', 'Van'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.black),
          onPressed: () => _navigateToDashboard(context),
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

            /// **Top Vehicle Selection Fields**
            _buildBrandDropdown(),
            _buildModelDropdown(),
            _buildTypeDropdown(),

            /// **Updated Fields**
            _buildTextField(label: "Mileage (km)", hintText: "Enter mileage"),
            _buildTextField(label: "Manufacture Year", hintText: "Enter year"),

            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () => _showPopupMessage(context),
              child: Text("Continue", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.black,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RatingScreen()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
        BottomNavigationBarItem(
          icon: Image.asset('images/logo.png', height: 30),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
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
              onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildBrandDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Vehicle Brand",
          border: OutlineInputBorder(),
        ),
        value: selectedBrand,
        items:
            vehicleModels.keys
                .map(
                  (brand) => DropdownMenuItem(value: brand, child: Text(brand)),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            selectedBrand = value;
            selectedModel = null;
          });
        },
        hint: Text("Select a brand"),
      ),
    );
  }

  Widget _buildModelDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Vehicle Model",
          border: OutlineInputBorder(),
        ),
        value: selectedModel,
        items:
            (selectedBrand != null && vehicleModels[selectedBrand] != null)
                ? vehicleModels[selectedBrand]!
                    .map(
                      (model) =>
                          DropdownMenuItem(value: model, child: Text(model)),
                    )
                    .toList()
                : [],
        onChanged: (value) {
          setState(() {
            selectedModel = value;
          });
        },
        hint: Text(
          selectedBrand == null ? "Select brand first" : "Select model",
        ),
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: "Vehicle Type",
          border: OutlineInputBorder(),
        ),
        value: selectedType,
        items:
            vehicleTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
        onChanged: (value) {
          setState(() {
            selectedType = value;
          });
        },
        hint: Text("Select vehicle type"),
      ),
    );
  }
}
