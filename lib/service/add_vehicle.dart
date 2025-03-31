import 'package:flutter/material.dart';
import '../service/owner_info.dart';

class AddVehicle extends StatelessWidget {
  const AddVehicle({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController vehicleController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New",
          style: TextStyle(
            fontWeight: FontWeight.bold, // Bold title
            fontSize: 20, // Adjust font size if needed
          ),
        ),
        centerTitle: true, // Center the title
        elevation: 0, // Optional: Remove shadow
        iconTheme: IconThemeData(
          color: Colors.black,
        ), // Optional: Back button color
      ),

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('images/bg_removed_logo.png', height: 100),
            SizedBox(height: 30),
            Text(
              "Add a vehicle",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Enter the vehicle number",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 30),
            TextField(
              controller: vehicleController,
              decoration: InputDecoration(
                labelText: "Vehicle Number",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

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
                    MaterialPageRoute(builder: (context) => OwnerInfo()),
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
          ],
        ),
      ),
    );
  }
}
