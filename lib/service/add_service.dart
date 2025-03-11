import 'package:dr_cars/service/conformation_receipt.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

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
        actions: [
          // Add a home icon button in the right corner
          IconButton(
            icon: Icon(Icons.home, color: Colors.black), // Home icon
            onPressed: () {
              // Navigate back to the home screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
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
            children: [
              _buildTextField(
                _previousOilChangeController,
                "Previous oil change",
              ),
              _buildTextField(
                _currentMileageController,
                "Current Mileage",
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 20),
              Text(
                "Services Done",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              _buildCheckbox(
                "Oil Changed",
                _oilChanged,
                (value) => setState(() => _oilChanged = value),
              ),
              _buildCheckbox(
                "Air Filter Changed",
                _airFilterChanged,
                (value) => setState(() => _airFilterChanged = value),
              ),
              _buildCheckbox(
                "Oil Filter Changed",
                _oilFilterChanged,
                (value) => setState(() => _oilFilterChanged = value),
              ),
              _buildCheckbox(
                "Coolant Changed",
                _coolantChanged,
                (value) => setState(() => _coolantChanged = value),
              ),
              _buildCheckbox(
                "Brake Fluid Changed",
                _brakeFluidChanged,
                (value) => setState(() => _brakeFluidChanged = value),
              ),
              _buildCheckbox(
                "Oesterbox Oil Changed",
                _oesterboxOilChanged,
                (value) => setState(() => _oesterboxOilChanged = value),
              ),
              _buildCheckbox(
                "Differential Oil Changed",
                _differentialOilChanged,
                (value) => setState(() => _differentialOilChanged = value),
              ),
              _buildCheckbox(
                "Belt Inspection",
                _beltInspection,
                (value) => setState(() => _beltInspection = value),
              ),
              _buildCheckbox(
                "Battery Testing",
                _batteryTesting,
                (value) => setState(() => _batteryTesting = value),
              ),

              SizedBox(height: 20),

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RecieptPage(
                              previousOilChange:
                                  _previousOilChangeController.text,
                              currentMileage: _currentMileageController.text,
                              nextServiceDate: _nextServiceDateController.text,
                              oilChanged: _oilChanged,
                              airFilterChanged: _airFilterChanged,
                              oilFilterChanged: _oilFilterChanged,
                              coolantChanged: _coolantChanged,
                              brakeFluidChanged: _brakeFluidChanged,
                              oesterboxOilChanged: _oesterboxOilChanged,
                              differentialOilChanged: _differentialOilChanged,
                              beltInspection: _beltInspection,
                              batteryTesting: _batteryTesting,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: (val) => onChanged(val ?? false),
    );
  }
}
