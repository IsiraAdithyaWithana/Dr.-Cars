import 'package:flutter/material.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  AppointmentPageState createState() => AppointmentPageState();
}

class AppointmentPageState extends State<AppointmentPage> {
  final TextEditingController _vehicleNumberController = TextEditingController();
  String? _selectedModel = "CAR";
  String? _selectedService = "FULL SERVICE";
  String? _selectedBranch = "KANDY";
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Your Appointment"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "VEHICLE DETAILS",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.red, thickness: 1),

              // Vehicle Number
              const Text("Vehicle Number *"),
              TextField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  hintText: "Enter vehicle number",
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Vehicle Model Dropdown
              const Text("Vehicle Model *"),
              DropdownButtonFormField<String>(
                value: _selectedModel,
                items: ["CAR", "SUV", "VAN", "TRUCK"]
                    .map((model) => DropdownMenuItem(value: model, child: Text(model)))
                    .toList(),
                onChanged: null, // Disabled Dropdown
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Type of Service Dropdown
              const Text("Type of Service"),
              DropdownButtonFormField<String>(
                value: _selectedService,
                items: ["FULL SERVICE", "OIL CHANGE", "BRAKE CHECK"]
                    .map((service) => DropdownMenuItem(value: service, child: Text(service)))
                    .toList(),
                onChanged: null, // Disabled Dropdown
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Preferred Branch Dropdown
              const Text("Preferred Branch *"),
              DropdownButtonFormField<String>(
                value: _selectedBranch,
                items: ["KANDY", "COLOMBO", "GALLE"]
                    .map((branch) => DropdownMenuItem(value: branch, child: Text(branch)))
                    .toList(),
                onChanged: null, // Disabled Dropdown
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Preferred Date Picker
              const Text("Preferred Date *"),
              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: _selectedDate == null
                          ? "SELECT DATE"
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preferred Time Picker
              const Text("Preferred Time *"),
              GestureDetector(
                onTap: () => _pickTime(context),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: _selectedTime == null
                          ? "SELECT TIME"
                          : "${_selectedTime!.hour}:${_selectedTime!.minute}",
                      suffixIcon: const Icon(Icons.access_time),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
