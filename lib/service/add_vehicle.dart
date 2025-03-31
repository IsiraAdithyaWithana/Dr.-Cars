import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/owner_info.dart';

class AddVehicle extends StatelessWidget {
  const AddVehicle({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController vehicleController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('images/bg_removed_logo.png', height: 100), // Ensure the image path is correct
            const SizedBox(height: 30),
            const Text(
              "Add a vehicle",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Enter the vehicle number",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: vehicleController,
              decoration: const InputDecoration(
                labelText: "Vehicle Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
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
                onPressed: () async {
                  String vehicleNumber = vehicleController.text.trim();
                  
                  if (vehicleNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a vehicle number.")),
                    );
                    return;
                  }

                  // Search Firestore for a document with a matching vehicle number
                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                      .collection('Vehicle')
                      .where('vehicleNumber', isEqualTo: vehicleNumber)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    // Get first matching document
                    var vehicleDoc = querySnapshot.docs.first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnerInfo(
                          vehicleNumber: vehicleNumber,
                          vehicleData: vehicleDoc.data() as Map<String, dynamic>?,
                        ),
                      ),
                    );
                  } else {
                    // No matching document found, redirect without data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnerInfo(vehicleNumber: vehicleNumber),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
