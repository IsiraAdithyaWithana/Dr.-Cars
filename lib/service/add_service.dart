import 'package:dr_cars/service/conformation_receipt.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:flutter/material.dart';

class AddService extends StatefulWidget {
  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  // Controllers for input fields
  final TextEditingController _previousOilChangeController =
      TextEditingController();
  final TextEditingController _currentMileageController =
      TextEditingController();
  final TextEditingController _nextServiceDateController =
      TextEditingController();

  // Service selection boolean values
  bool _oilChanged = false;
  bool _airFilterChanged = false;
  bool _oilFilterChanged = false;
  bool _coolantChanged = false;
  bool _brakeFluidChanged = false;
  bool _oesterboxOilChanged = false;
  bool _differentialOilChanged = false;
  bool _beltInspection = false;
  bool _batteryTesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Vehicle Owner Information",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Home icon button in the right corner
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              // Navigate back to the home screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Previous Oil Change:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _previousOilChangeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter previous oil change",
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Current Mileage:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _currentMileageController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter current mileage",
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Next Service Date:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _nextServiceDateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter next service date",
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Select Services:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // List of services
              CheckboxListTile(
                title: const Text("Oil Changed"),
                value: _oilChanged,
                onChanged:
                    (bool? value) =>
                        setState(() => _oilChanged = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Air Filter Changed"),
                value: _airFilterChanged,
                onChanged:
                    (bool? value) =>
                        setState(() => _airFilterChanged = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Oil Filter Changed"),
                value: _oilFilterChanged,
                onChanged:
                    (bool? value) =>
                        setState(() => _oilFilterChanged = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Coolant Changed"),
                value: _coolantChanged,
                onChanged:
                    (bool? value) =>
                        setState(() => _coolantChanged = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Brake Fluid Changed"),
                value: _brakeFluidChanged,
                onChanged:
                    (bool? value) =>
                        setState(() => _brakeFluidChanged = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Oesterbox Oil Changed"),
                value: _oesterboxOilChanged,
                onChanged:
                    (bool? value) =>
                        setState(() => _oesterboxOilChanged = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Differential Oil Changed"),
                value: _differentialOilChanged,
                onChanged:
                    (bool? value) => setState(
                      () => _differentialOilChanged = value ?? false,
                    ),
              ),
              CheckboxListTile(
                title: const Text("Belt Inspection"),
                value: _beltInspection,
                onChanged:
                    (bool? value) =>
                        setState(() => _beltInspection = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Battery Testing"),
                value: _batteryTesting,
                onChanged:
                    (bool? value) =>
                        setState(() => _batteryTesting = value ?? false),
              ),

              const SizedBox(height: 20),
              // Button to proceed to receipt page
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
                      MaterialPageRoute(
                        builder:
                            (context) => RecieptPage(
                              previousOilChange:
                                  _previousOilChangeController.text,
                              currentMileage: _currentMileageController.text,
                              nextServiceDate: _nextServiceDateController.text,
                              servicesSelected: {
                                "Oil Changed": _oilChanged,
                                "Air Filter Changed": _airFilterChanged,
                                "Oil Filter Changed": _oilFilterChanged,
                                "Coolant Changed": _coolantChanged,
                                "Brake Fluid Changed": _brakeFluidChanged,
                                "Oesterbox Oil Changed": _oesterboxOilChanged,
                                "Differential Oil Changed":
                                    _differentialOilChanged,
                                "Belt Inspection": _beltInspection,
                                "Battery Testing": _batteryTesting,
                              },
                            ),
                      ),
                    );
                  },
                  child: const Text(
                    "Proceed to Receipt",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
