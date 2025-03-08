import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'conformation_receipt.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final TextEditingController _previousOilChangeController =
      TextEditingController();
  final TextEditingController _currentMileageController =
      TextEditingController();
  final TextEditingController _nextServiceDateController =
      TextEditingController();

  bool _oilChanged = false;
  bool _airFilterChanged = false;
  bool _oilFilterChanged = false;
  bool _coolantChanged = false;
  bool _brakeFluidChanged = false;
  bool _oesterboxOilChanged = false;
  bool _differentialOilChanged = false;
  bool _beltInspection = false;
  bool _batteryTesting = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _nextServiceDateController.text = DateFormat(
          'yyyy/MM/dd',
        ).format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Service",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Previous Oil Change
              TextField(
                controller: _previousOilChangeController,
                decoration: InputDecoration(
                  labelText: "Previous oil change",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Current Mileage
              TextField(
                controller: _currentMileageController,
                decoration: InputDecoration(
                  labelText: "Current Mileage",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              // Services Done
              Text(
                "Services Done",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Checkboxes for Services
              CheckboxListTile(
                title: Text("Oil Changed"),
                value: _oilChanged,
                onChanged: (value) {
                  setState(() {
                    _oilChanged = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Air Filter Changed"),
                value: _airFilterChanged,
                onChanged: (value) {
                  setState(() {
                    _airFilterChanged = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Oil Filter Changed"),
                value: _oilFilterChanged,
                onChanged: (value) {
                  setState(() {
                    _oilFilterChanged = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Coolant Changed"),
                value: _coolantChanged,
                onChanged: (value) {
                  setState(() {
                    _coolantChanged = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Brake Fluid Changed"),
                value: _brakeFluidChanged,
                onChanged: (value) {
                  setState(() {
                    _brakeFluidChanged = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Oesterbox Oil Changed"),
                value: _oesterboxOilChanged,
                onChanged: (value) {
                  setState(() {
                    _oesterboxOilChanged = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Differential Oil Changed"),
                value: _differentialOilChanged,
                onChanged: (value) {
                  setState(() {
                    _differentialOilChanged = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Belt Inspection"),
                value: _beltInspection,
                onChanged: (value) {
                  setState(() {
                    _beltInspection = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Battery Testing"),
                value: _batteryTesting,
                onChanged: (value) {
                  setState(() {
                    _batteryTesting = value!;
                  });
                },
              ),
              SizedBox(height: 20),

              // Next Service Date
              TextField(
                controller: _nextServiceDateController,
                decoration: InputDecoration(
                  labelText: "Next Service Date",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 20),

              // Continue Button
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
                    // Navigate to the next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RecieptPage(
                              // previousOilChange:
                              //     _previousOilChangeController.text,
                              // currentMileage: _currentMileageController.text,
                              // nextServiceDate: _nextServiceDateController.text,
                              // oilChanged: _oilChanged,
                              // airFilterChanged: _airFilterChanged,
                              // oilFilterChanged: _oilFilterChanged,
                              // coolantChanged: _coolantChanged,
                              // brakeFluidChanged: _brakeFluidChanged,
                              // oesterboxOilChanged: _oesterboxOilChanged,
                              // differentialOilChanged: _differentialOilChanged,
                              // beltInspection: _beltInspection,
                              // batteryTesting: _batteryTesting,
                            ),
                      ),
                    );
                  },
                  child: Text(
                    "Continue",
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

class ReceiptPage extends StatelessWidget {
  final String previousOilChange;
  final String currentMileage;
  final String nextServiceDate;
  final bool oilChanged;
  final bool airFilterChanged;
  final bool oilFilterChanged;
  final bool coolantChanged;
  final bool brakeFluidChanged;
  final bool oesterboxOilChanged;
  final bool differentialOilChanged;
  final bool beltInspection;
  final bool batteryTesting;

  const ReceiptPage({
    super.key,
    required this.previousOilChange,
    required this.currentMileage,
    required this.nextServiceDate,
    required this.oilChanged,
    required this.airFilterChanged,
    required this.oilFilterChanged,
    required this.coolantChanged,
    required this.brakeFluidChanged,
    required this.oesterboxOilChanged,
    required this.differentialOilChanged,
    required this.beltInspection,
    required this.batteryTesting,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Receipt")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Previous Oil Change: $previousOilChange"),
            Text("Current Mileage: $currentMileage"),
            Text("Next Service Date: $nextServiceDate"),
            SizedBox(height: 20),
            Text("Services Done:"),
            if (oilChanged) Text("- Oil Changed"),
            if (airFilterChanged) Text("- Air Filter Changed"),
            if (oilFilterChanged) Text("- Oil Filter Changed"),
            if (coolantChanged) Text("- Coolant Changed"),
            if (brakeFluidChanged) Text("- Brake Fluid Changed"),
            if (oesterboxOilChanged) Text("- Oesterbox Oil Changed"),
            if (differentialOilChanged) Text("- Differential Oil Changed"),
            if (beltInspection) Text("- Belt Inspection"),
            if (batteryTesting) Text("- Battery Testing"),
          ],
        ),
      ),
    );
  }
}
