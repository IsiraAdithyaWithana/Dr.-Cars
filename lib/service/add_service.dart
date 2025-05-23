import 'package:dr_cars/service/conformation_receipt.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:flutter/material.dart';

class AddService extends StatefulWidget {
  final String vehicleNumber;

  const AddService({required this.vehicleNumber, super.key});

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

  String? oilType;
  String? gearboxChecked;
  String? differentialChecked;

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
        title: Text(
          "Add Service: ${widget.vehicleNumber}",
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
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
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
                "Service Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _previousOilChangeController,
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _previousOilChangeController.text =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: "Enter previous oil change date",
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.black54),
                ),
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _currentMileageController,
                decoration: InputDecoration(
                  labelText: "Current Mileage",
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 20),
              const Text(
                "Services Done",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Oil changed'),
                    Checkbox(
                      value: _oilChanged,
                      onChanged: (bool? value) {
                        setState(() {
                          _oilChanged = value!;
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: oilType,
                      hint: Text('Type'),
                      items:
                          ['Synthetic', 'Semi-Synthetic', 'Mineral'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          oilType = newValue;
                        });
                      },
                    ),
                  ],
                ),
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
              const SizedBox(height: 10),
              TextField(
                controller: _nextServiceDateController,
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _nextServiceDateController.text =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: "Next service date",
                  labelStyle: TextStyle(color: Colors.black54),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.black54),
                ),
                style: TextStyle(color: Colors.black),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RecieptPage(
                              vehicleNumber: widget.vehicleNumber,
                              previousOilChange:
                                  _previousOilChangeController.text,
                              currentMileage: _currentMileageController.text,
                              nextServiceDate: _nextServiceDateController.text,
                              servicesSelected: {
                                "Oil Changed (${oilType ?? 'N/A'})":
                                    _oilChanged,
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
