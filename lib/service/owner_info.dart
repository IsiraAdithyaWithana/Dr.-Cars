import 'package:flutter/material.dart';
import '../service/add_service.dart';

class OwnerInfo extends StatefulWidget {
  const OwnerInfo({super.key});

  @override
  _OwnerInfoPageState createState() => _OwnerInfoPageState();
}

class _OwnerInfoPageState extends State<OwnerInfo> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? selectedModel;
  String? selectedYear;

  final List<String> vehicleModels = [
    "Toyota",
    "Honda",
    "Ford",
    "BMW",
    "Tesla",
  ];
  final List<String> vehicleYears = ["2025", "2024", "2023", "2022", "2021"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vehicle Owner Information",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            SizedBox(height: 20), // Space between app bar and image
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('images/logo.png'),
            ),
            SizedBox(height: 20), // Space between image and form

            _buildTextField(nameController, "Name", "Name of user"),
            _buildTextField(usernameController, "User Name", "Username"),
            _buildTextField(addressController, "Address", "Address"),
            _buildTextField(contactController, "Contact", "Contact Number"),
            _buildTextField(emailController, "E-mail", "email"),

            // Vehicle Model Dropdown
            _buildDropdownField("Vehicle Model", vehicleModels, selectedModel, (
              value,
            ) {
              setState(() {
                selectedModel = value;
              });
            }),

            // Vehicle Year Dropdown
            _buildDropdownField("Vehicle Year", vehicleYears, selectedYear, (
              value,
            ) {
              setState(() {
                selectedYear = value;
              });
            }),

            SizedBox(height: 20), // Space before button
            // Continue Button
            SizedBox(
              width: double.infinity, // Full-width button
              height: 50, // Adjust height
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Black background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddService()),
                  );
                },
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white, // White text
                    fontSize: 16, // Adjust font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Space after button
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
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
          border: OutlineInputBorder(),
        ),
        value: selectedValue,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
