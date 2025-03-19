import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:dr_cars/interface/rating.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  bool isLoading = true;

  final Map<String, List<String>> vehicleModels = {
    'Toyota': ['Corolla', 'Camry', 'RAV4', 'Hilux', 'Land Cruiser'],
    'Nissan': ['Sunny', 'X-Trail', 'Patrol', 'Navara', 'GT-R'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Vezel', 'City'],
    'Suzuki': ['Alto', 'Swift', 'Dzire', 'Baleno', 'Jimny'],
  };

  final List<String> vehicleTypes = ['Car', 'SUV', 'Truck', 'Buses', 'Van'];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          mileageController.text = data['mileage'] ?? '';
          yearController.text = data['manufacture_year'] ?? '';
          selectedBrand = data['brand'];
          selectedModel = data['model'];
          selectedType = data['vehicle_type'];
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  /// **Updated function to store vehicle details in Firestore**
  Future<void> _saveUserProfile() async {
    if (user != null) {
      try {
        String vehicleId = _firestore.collection('Vehicle').doc().id;

        await _firestore.collection('Vehicle').doc(vehicleId).set({
          'brand': selectedBrand,
          'model': selectedModel,
          'type': selectedType,
          'mileage': int.tryParse(mileageController.text) ?? 0,
          'manufactureYear': int.tryParse(yearController.text) ?? 0,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user!.uid,
        });

        _showPopupMessage(context, "Vehicle details saved successfully!");
      } catch (e) {
        _showPopupMessage(context, "Error saving vehicle: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

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

            /// **Vehicle Details**
            _buildBrandDropdown(),
            _buildModelDropdown(),
            _buildTypeDropdown(),

            /// **User Input Fields**
            _buildTextField(
              controller: mileageController,
              label: "Mileage (km)",
              hintText: "Enter mileage",
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
              onPressed: _saveUserProfile,
              child: Text(
                "Save Profile",
                style: TextStyle(color: Colors.white),
              ),
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

  void _showPopupMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
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
    return DropdownButtonFormField<String>(
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
    );
  }

  Widget _buildModelDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Vehicle Model",
        border: OutlineInputBorder(),
      ),
      value: selectedModel,
      items:
          selectedBrand != null
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
      hint: Text("Select model"),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
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
    );
  }
}
