import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  TextEditingController mileageController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();

  final Map<String, List<String>> vehicleModels = {
    'Toyota': [
      'Corolla',
      'Camry',
      'RAV4',
      'Highlander',
      'Aqua',
      'Axio',
      'Vitz',
      'Allion',
      'Premio',
      'LandCruiser',
      'Hilux',
      'Prius',
      'Rush',
    ],
    'Nissan': [
      'Sunny',
      'X-Trail',
      'Juke',
      'Note',
      'Teana',
      'Skyline',
      'Patrol',
      'Navara',
      'Qashqai',
      'Murano',
      'Titan',
      'Frontier',
      'Sylphy',
      'Fairlady Z',
      'Armada',
      'Sentra',
      'Leaf',
      'GT-R',
      'Bluebird',
      'March',
      'AD Wagon',
      'Vanette',
      'Caravan',
      'Serena',
      'Primera',
      'Cedric',
      'Gloria',
      'Terrano',
      'Dualis',
      'Dayz',
      'Elgrand',
      'Lafesta',
      'Wingroad',
    ],
    'Honda': [
      'Civic',
      'Accord',
      'CR-V',
      'Pilot',
      'Fit',
      'Vezel',
      'Grace',
      'Freed',
      'Insight',
      'HR-V',
      'BR-V',
      'Jazz',
      'City',
      'Legend',
      'Odyssey',
      'Shuttle',
      'Stepwgn',
      'Acty',
      'S660',
      'NSX',
      'Integra',
      'Stream',
      'Airwave',
      'CR-Z',
      'Elysion',
      'Beat',
      'Mobilio',
      'Crossroad',
    ],
    'Suzuki': [
      'Alto',
      'Wagon R',
      'Swift',
      'Dzire',
      'Baleno',
      'Ertiga',
      'Celerio',
      'S-Presso',
      'Vitara Brezza',
      'Grand Vitara',
      'Ciaz',
      'Ignis',
      'XL6',
      'Jimny',
      'Fronx',
      'Maruti 800',
      'Esteem',
      'Kizashi',
      'A-Star',
    ],
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

            // **Vehicle Selection Fields at the Top**
            _buildBrandDropdown(),
            _buildModelDropdown(),
            _buildTypeDropdown(),

            // **Updated Fields**
            _buildTextField(
              controller: mileageController,
              label: "Mileage (km)",
              hintText: "Enter mileage",
            ),
            _buildTextField(
              controller: vehicleNumberController,
              label: "Vehicle Number",
              hintText: "Enter vehicle number",
            ),
            _buildTextField(
              controller: yearController,
              label: "Manufacture Year",
              hintText: "Enter year",
            ),

            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed:
                  () => _uploadVehicleData(), // Call function to upload data
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
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
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
        BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
        BottomNavigationBarItem(
          icon: Image.asset('images/logo.png', height: 30),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }

  void _uploadVehicleData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Ensure user is logged in

    if (selectedBrand != null &&
        selectedModel != null &&
        selectedType != null &&
        vehicleNumberController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('Vehicle').doc(vehicleNumberController.text).set({
          'userId': user.uid, // Store user's ID
          'brand': selectedBrand,
          'model': selectedModel,
          'type': selectedType,
          'mileage': int.tryParse(mileageController.text) ?? 0,
          'vehicleNumber': vehicleNumberController.text, // FIXED
          'manufactureYear': int.tryParse(yearController.text) ?? 0,
          'image': 'images/dashcar.png', // Default image (modify as needed)
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show Success Message
        _showPopupMessage(context, "Success", "Your data was saved.");
      } catch (e) {
        _showPopupMessage(context, "Error", "Failed to save data.\n${e.toString()}");
      }
    } else {
      _showPopupMessage(context, "Warning", "Please fill all fields.");
    }
  }


  void _showPopupMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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

  void _clearFields() {
    setState(() {
      mileageController.clear();
      yearController.clear();
      selectedBrand = null;
      selectedModel = null;
      selectedType = null;
      vehicleNumberController.clear();
    });
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreen()),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
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
            selectedModel = null; // Reset model when brand changes
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
