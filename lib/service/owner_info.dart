import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_service.dart';

class OwnerInfo extends StatefulWidget {
  final String vehicleNumber;
  final Map<String, dynamic>? vehicleData;
  final Map<String, dynamic>? userData;

  const OwnerInfo({
    super.key,
    required this.vehicleNumber,
    this.vehicleData,
    this.userData,
  });

  @override
  _OwnerInfoPageState createState() => _OwnerInfoPageState();
}

class _OwnerInfoPageState extends State<OwnerInfo> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController vehicleYearController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? selectedBrand;
  String? selectedModel;

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

  @override
  void initState() {
    super.initState();
    if (widget.vehicleData == null) {
      _fetchVehicleData();
    } else {
      _populateFields(widget.vehicleData!);
      _fetchUserData();
    }

    if (widget.userData != null) {
      _userDetails(widget.userData!);
    }
  }

  Future<void> _fetchVehicleData() async {
    DocumentSnapshot vehicleDoc =
        await FirebaseFirestore.instance
            .collection('Vehicle')
            .doc(widget.vehicleNumber)
            .get();

    if (vehicleDoc.exists) {
      _populateFields(vehicleDoc.data() as Map<String, dynamic>);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle not found in database.")),
      );
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    setState(() {
      selectedBrand = data['selectedBrand'] ?? 'Toyota';
      selectedModel = data['selectedModel'] ?? vehicleModels['Toyota']?[0];
      vehicleYearController.text =
          data['year']?.toString() ?? data['manufactureYear']?.toString() ?? '';
      userIdController.text = data['uid'] ?? '';
    });
  }

  Future<void> _fetchUserData() async {
    if (userIdController.text.isEmpty) return;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userIdController.text)
            .get();

    if (userDoc.exists) {
      _userDetails(userDoc.data() as Map<String, dynamic>);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found in database.")),
      );
    }
  }

  void _userDetails(Map<String, dynamic> data) {
    setState(() {
      nameController.text = data['Name'] ?? "";
      addressController.text = data['Address'] ?? "";
      contactController.text = data['Contact'] ?? "";
      emailController.text = data['Email'] ?? "";
    });
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final isVehicleExisting = widget.vehicleData != null;

    Map<String, dynamic> userData = {
      'Name': nameController.text.trim(),
      'Address': addressController.text.trim(),
      'Contact': contactController.text.trim(),
      'Email': emailController.text.trim(),
    };

    Map<String, dynamic> vehicleData = {
      'vehicleNumber': widget.vehicleNumber,
      'selectedBrand': selectedBrand,
      'selectedModel': selectedModel,
      'year': vehicleYearController.text.trim(),
      'uid': userIdController.text,
      'mileage': '100000',
      'vehicleType': 'Car',
      'vehiclePhotoUrl': null,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    final firestore = FirebaseFirestore.instance;

    if (isVehicleExisting) {
      final String uid = widget.vehicleData?['uid'];
      final userDoc = await firestore.collection('Users').doc(uid).get();
      final vehicleDoc = await firestore.collection('Vehicle').doc(uid).get();

      if (userDoc.exists) {
        await firestore.collection('Users').doc(uid).update(userData);
      }
      if (vehicleDoc.exists) {
        await firestore.collection('Vehicle').doc(uid).update(vehicleData);
      }
    } else {
      final newUserRef = firestore.collection('Users').doc();
      final newUID = newUserRef.id;

      await newUserRef.set({
        ...userData,
        'uid': newUID,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('Vehicle').doc(newUID).set({
        ...vehicleData,
        'uid': newUID,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (mounted) {
      setState(() => isLoading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddService(vehicleNumber: widget.vehicleNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vehicle: ${widget.vehicleNumber}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/logo.png'),
              ),
              const SizedBox(height: 20),
              _buildTextField(nameController, "Name"),
              _buildTextField(addressController, "Address"),
              _buildTextField(contactController, "Contact"),
              _buildTextField(emailController, "Email", isEmail: true),
              _buildTextField(vehicleYearController, "Vehicle Year"),

              _buildDropdownField(
                "Brand",
                vehicleModels.keys.toList(),
                selectedBrand,
                (value) {
                  setState(() {
                    selectedBrand = value;
                    selectedModel = vehicleModels[selectedBrand]?.first;
                  });
                },
              ),

              if (selectedBrand != null)
                _buildDropdownField(
                  "Model",
                  vehicleModels[selectedBrand] ?? [],
                  selectedModel,
                  (value) {
                    setState(() {
                      selectedModel = value;
                    });
                  },
                ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: _handleContinue,
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isEmail = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: "Enter $label",
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: items.contains(selectedValue) ? selectedValue : null,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }
}
