import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_service.dart';

class OwnerInfo extends StatefulWidget {
  final String vehicleNumber;
  final Map<String, dynamic>? vehicleData;
  final Map<String, dynamic>? userData;

  const OwnerInfo({super.key, required this.vehicleNumber, this.vehicleData, this.userData});

  @override
  _OwnerInfoPageState createState() => _OwnerInfoPageState();
}

class _OwnerInfoPageState extends State<OwnerInfo> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController vehicleYearController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  String? selectedBrand;
  String? selectedModel;

  // Map of vehicle brands to their respective models
  final Map<String, List<String>> vehicleModels = {
    'Toyota': [
      'Corolla', 'Camry', 'RAV4', 'Highlander', 'Aqua', 'Axio', 'Vitz',
      'Allion', 'Premio', 'LandCruiser', 'Hilux', 'Prius', 'Rush',
    ],
    'Nissan': [
      'Sunny', 'X-Trail', 'Juke', 'Note', 'Teana', 'Skyline', 'Patrol',
      'Navara', 'Qashqai', 'Murano', 'Titan', 'Frontier', 'Sylphy',
      'Fairlady Z', 'Armada', 'Sentra', 'Leaf', 'GT-R',
    ],
    'Honda': [
      'Civic', 'Accord', 'CR-V', 'Pilot', 'Fit', 'Vezel', 'Grace',
      'Freed', 'Insight', 'HR-V', 'BR-V', 'Jazz', 'City', 'Legend',
      'Odyssey', 'Shuttle', 'Stepwgn', 'Acty', 'S660', 'NSX',
    ],
    'Suzuki': [
      'Alto', 'Wagon R', 'Swift', 'Dzire', 'Baleno', 'Ertiga', 'Celerio',
      'S-Presso', 'Vitara Brezza', 'Grand Vitara', 'Ciaz', 'Ignis', 'XL6',
      'Jimny', 'Fronx', 'Maruti 800', 'Esteem', 'Kizashi', 'A-Star',
    ],
  };

  @override
  void initState() {
    super.initState();
    
    // If vehicleData is not passed, fetch data from Firestore
    if (widget.vehicleData == null) {
      _fetchVehicleData();
    } else {
      _populateFields(widget.vehicleData!);
    }


    if(widget.userData == null){
      _fetchUserData();
    } else {
      _userDetails(widget.userData!);
    }
  }

  Future<void> _fetchVehicleData() async {
    // Fetch data from Firestore using vehicleNumber
    DocumentSnapshot vehicleDoc = await FirebaseFirestore.instance
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
    selectedBrand = data['brand'] ?? 'Toyota';
    selectedModel = data['model'] ?? vehicleModels['Toyota']?[0];
    if (data['manufactureYear'] != null) {
      vehicleYearController.text = data['manufactureYear'].toString();
    } else {
      vehicleYearController.text = "";
    }
    
    userIdController.text = data['userId'] ?? "";
  });
}

  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
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

  void _userDetails(Map<String, dynamic> data){
    setState(() {
      nameController.text = data['Name'] ?? "";
      addressController.text = data['Address'] ?? "";
      contactController.text = data['Contact'] ?? "";
      emailController.text = data['Email'] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vehicle Owner: ${widget.vehicleNumber}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('images/logo.png'),
            ),
            const SizedBox(height: 20),
            _buildTextField(nameController, "Name", "Name of user"),
            _buildTextField(addressController, "Address", "Address"),
            _buildTextField(contactController, "Contact", "Contact Number"),
            _buildTextField(emailController, "E-mail", "Email"),
            _buildTextField(vehicleYearController, "Vehicle Year", "Year of Manufacture"),

            // Brand Dropdown
            _buildDropdownField("Brand", vehicleModels.keys.toList(), selectedBrand, (value) {
              setState(() {
                selectedBrand = value;
                // Reset the model when brand changes
                selectedModel = vehicleModels[selectedBrand]?.first;
              });
            }),

            // Model Dropdown
            if (selectedBrand != null) 
              _buildDropdownField("Model", vehicleModels[selectedBrand] ?? [], selectedModel, (value) {
                setState(() {
                  selectedModel = value;
                });
              }),

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddService()),
                  );
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
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
        value: selectedValue,
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
