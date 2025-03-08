import 'package:flutter/material.dart';

void main() {
  runApp(ServiceRecordsPage());
}

class ServiceRecordsPage extends StatelessWidget {
  const ServiceRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ServiceRecordsScreen(),
    );
  }
}

class ServiceRecordsScreen extends StatelessWidget {
const ServiceRecordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Service Records",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Current Mileage"),
              _buildTextField(suffixText: "KM"),
              SizedBox(height: 10),
              _buildLabel("Type of Service"),
              _buildTextField(),
              SizedBox(height: 10),
              _buildLabel("Date of service"),
              _buildTextField(),
              SizedBox(height: 20),
              _buildServiceDetails(),
              SizedBox(height: 20),
              _buildUploadButton(),
              SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTextField({String? suffixText}) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        suffixText: suffixText,
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Mileage"),
        _buildTextField(suffixText: "KM"),
        SizedBox(height: 10),
        _buildLabel("Service Provider"),
        _buildTextField(),
        SizedBox(height: 10),
        _buildLabel("Service Cost"),
        _buildTextField(),
        SizedBox(height: 10),
        _buildLabel("Additional notes"),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return Row(
      children: [
        Text(
          "Invoice",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: Text("Upload"),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: Text("Save", style: TextStyle(color: Colors.white)),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: ""),
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/logo.png', // Add your logo in the assets folder
            height: 30,
          ),
          label: "",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
      ],
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }
}
