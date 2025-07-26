import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/Settings.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/service_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:dr_cars/interface/obd2.dart';

int _selectedIndex = 4;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  String? selectedBrand;
  String? selectedModel;
  String? selectedType;
  TextEditingController mileageController = TextEditingController();
  TextEditingController yearController = TextEditingController();

  bool _isLoading = false;
  String? _vehiclePhotoUrl;
  bool _isInitialSetup = true;
  bool _isExpanded = false;

  final Map<String, List<String>> vehicleModels = {
    'Toyota': [
      'Corolla',
      'Camry',
      'RAV4',
      'Highlander',
      'Aqua',
      'Axio',
      'Vitz',
      'Prius',
    ],
    'Nissan': [
      'Sunny',
      'X-Trail',
      'Juke',
      'Note',
      'Teana',
      'GT-R',
      'Sentra',
      'Patrol',
    ],
    'Honda': [
      'Civic',
      'Accord',
      'CR-V',
      'Fit',
      'Vezel',
      'City',
      'Odyssey',
      'Freed',
    ],
    'Suzuki': [
      'Alto',
      'Wagon R',
      'Swift',
      'Baleno',
      'Vitara',
      'Ertiga',
      'Jimny',
      'Estilo',
    ],
    'Mazda': [
      'Mazda3',
      'Mazda6',
      'CX-3',
      'CX-5',
      'CX-9',
      'BT-50',
      'RX-8',
      'MX-5',
    ],
    'BMW': ['320i', 'X1', 'X3', 'X5', 'M3', 'Z4', '530e', '740i'],
    'Kia': [
      'Picanto',
      'Rio',
      'Sportage',
      'Seltos',
      'Sorento',
      'Cerato',
      'Stinger',
      'Carnival',
    ],
    'Hyundai': [
      'i10',
      'i20',
      'Elantra',
      'Tucson',
      'Santa Fe',
      'Accent',
      'Venue',
      'Creta',
    ],
  };

  final List<String> vehicleTypes = ['Car', 'SUV', 'Truck', 'Buses', 'Van'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get();

        final vehicleDoc =
            await FirebaseFirestore.instance
                .collection('Vehicle')
                .doc(user.uid)
                .get();

        if (userDoc.exists) {
          nameController.text = userDoc['Name'] ?? '';
          emailController.text = userDoc['Email'] ?? '';
        }

        if (vehicleDoc.exists) {
          setState(() {
            _isInitialSetup = false;
            vehicleNumberController.text = vehicleDoc['vehicleNumber'] ?? '';
            selectedBrand = vehicleDoc['selectedBrand'];
            selectedModel = vehicleDoc['selectedModel'];
            selectedType = vehicleDoc['vehicleType'];
            mileageController.text = vehicleDoc['mileage']?.toString() ?? '';
            yearController.text = vehicleDoc['year']?.toString() ?? '';
            _vehiclePhotoUrl = vehicleDoc['vehiclePhotoUrl'];
          });
        }
      }
    } catch (e) {
      print("Error loading user/vehicle data: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading profile data')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  ();
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadUserData,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child:
                _isInitialSetup
                    ? _buildInitialSetupForm()
                    : _buildVehiclePanel(),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildVehiclePanel() {
    return Column(
      children: [
        Card(
          elevation: 2,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundImage:
                  _vehiclePhotoUrl != null
                      ? NetworkImage(_vehiclePhotoUrl!)
                      : AssetImage('images/logo.png') as ImageProvider,
              radius: 25,
            ),
            title: Text(
              '${selectedBrand ?? ''} ${selectedModel ?? ''}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(vehicleNumberController.text),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Vehicle Type', selectedType ?? ''),
                    _buildInfoRow('Mileage', '${mileageController.text} km'),
                    _buildInfoRow('Year', yearController.text),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isInitialSetup = true;
                        });
                      },
                      child: Text('Edit Vehicle Information'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 40),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInitialSetupForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
              child:
                  _vehiclePhotoUrl != null
                      ? ClipOval(
                        child: Image.network(
                          _vehiclePhotoUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('images/logo.png'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Vehicle Information Setup',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildBrandDropdown(),
          _buildModelDropdown(),
          _buildTypeDropdown(),
          SizedBox(height: 20),
          _buildTextField(
            controller: vehicleNumberController,
            label: "Vehicle Number",
            hintText: "Enter vehicle number",
          ),
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
            onPressed: _isLoading ? null : () => _saveProfile(),
            child: Text(
              "Save Vehicle Information",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OBD2Page()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ServiceHistorypage()),
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
        BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Map<String, dynamic> vehicleData = {
            'uid': user.uid,
            'vehicleNumber': vehicleNumberController.text,
            'selectedBrand': selectedBrand,
            'selectedModel': selectedModel,
            'vehicleType': selectedType,
            'mileage': mileageController.text,
            'year': yearController.text,
            'vehiclePhotoUrl': _vehiclePhotoUrl,
            'lastUpdated': FieldValue.serverTimestamp(),
          };

          await FirebaseFirestore.instance
              .collection('Vehicle')
              .doc(user.uid)
              .set(vehicleData, SetOptions(merge: true));

          _showPopupMessage(
            context,
            "Success",
            "Vehicle information saved successfully!",
          );

          setState(() => _isInitialSetup = false);
        } else {
          throw Exception("User not authenticated");
        }
      } catch (e) {
        print("Error saving vehicle info: $e");
        _showPopupMessage(
          context,
          "Error",
          "Failed to save vehicle data: ${e.toString()}",
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
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
