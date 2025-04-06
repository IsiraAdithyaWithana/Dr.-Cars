import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/Settings.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:dr_cars/interface/obd2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

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
  File? _imageFile;
  bool _isLoading = false;
  String? _vehiclePhotoUrl;

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
      'Ignis',
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
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userData.exists) {
          setState(() {
            nameController.text = userData['name'] ?? '';
            emailController.text = userData['email'] ?? '';
            vehicleNumberController.text = userData['vehicleNumber'] ?? '';
            selectedBrand = userData['selectedBrand'];
            selectedModel = userData['selectedModel'];
            selectedType = userData['selectedType'];
            mileageController.text = userData['mileage']?.toString() ?? '';
            yearController.text = userData['year']?.toString() ?? '';
            _vehiclePhotoUrl = userData['vehiclePhotoUrl'];
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (await Permission.photos.request().isGranted) {
        return;
      }

      var status = await Permission.photos.request();
      if (status.isDenied) {
        _showPopupMessage(
          context,
          "Permission Required",
          "Photo library access is required to pick images. Please enable it in settings.",
        );
      }
    } catch (e) {
      print("Error requesting permissions: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final file = File(image.path);
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Upload to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('vehicle_photos')
              .child('${user.uid}.jpg');

          await storageRef.putFile(file);
          final downloadUrl = await storageRef.getDownloadURL();

          // Update Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'vehiclePhotoUrl': downloadUrl});

          setState(() {
            _vehiclePhotoUrl = downloadUrl;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
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
                  _pickImage();
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
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
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
                                    backgroundImage: AssetImage(
                                      'images/logo.png',
                                    ),
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
                    'User Profile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: nameController,
                    label: "Full Name",
                    hintText: "Enter your full name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: emailController,
                    label: "Email",
                    hintText: "Enter your email",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  _buildBrandDropdown(),
                  _buildModelDropdown(),
                  _buildTypeDropdown(),
                  _buildTextField(
                    controller: vehicleNumberController,
                    label: "Vehicle Number",
                    hintText: "Enter vehicle number",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle number';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: mileageController,
                    label: "Mileage (km)",
                    hintText: "Enter mileage",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mileage';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: yearController,
                    label: "Manufacture Year",
                    hintText: "Enter year",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter manufacture year';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid year';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showImagePickerOptions,
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text("Select Vehicle Photo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: _isLoading ? null : () => _saveProfile(),
                    child: Text(
                      "Save Profile",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Create user data map
          Map<String, dynamic> userData = {
            'name': nameController.text,
            'email': emailController.text,
            'vehicleNumber': vehicleNumberController.text,
            'selectedBrand': selectedBrand,
            'selectedModel': selectedModel,
            'selectedType': selectedType,
            'mileage': int.tryParse(mileageController.text),
            'year': int.tryParse(yearController.text),
            'vehiclePhotoUrl': _vehiclePhotoUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          // Update Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userData, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
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
    String? Function(String?)? validator,
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
        validator: validator,
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
