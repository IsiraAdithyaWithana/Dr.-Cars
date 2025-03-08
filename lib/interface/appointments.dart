import 'package:flutter/material.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  // Lists for dropdowns
  final List<String> vehicleModels = ['Car', 'Van', 'SUV', 'Truck', 'Motorcycle'];
  final List<String> serviceTypes = ['Full Service', 'Oil Change', 'Brake Check', 'Tire Rotation'];
  final List<String> branches = ['Kandy', 'Colombo', 'Galle', 'Jaffna', 'Kurunegala'];

  // Selected values
  String? _selectedModel;
  String? _selectedService;
  String? _selectedBranch;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Function to pick a date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to pick a time
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Your Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vehicle Number *', style: TextStyle(fontWeight: FontWeight.bold)),
            const TextField(decoration: InputDecoration(border: OutlineInputBorder())),

            const SizedBox(height: 16),
            const Text('Vehicle Model *', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedModel,
              items: vehicleModels.map((model) {
                return DropdownMenuItem(value: model, child: Text(model));
              }).toList(),
              onChanged: (value) => setState(() => _selectedModel = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),
            const Text('Type of Service', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedService,
              items: serviceTypes.map((service) {
                return DropdownMenuItem(value: service, child: Text(service));
              }).toList(),
              onChanged: (value) => setState(() => _selectedService = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),
            const Text('Preferred Branch *', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedBranch,
              items: branches.map((branch) {
                return DropdownMenuItem(value: branch, child: Text(branch));
              }).toList(),
              onChanged: (value) => setState(() => _selectedBranch = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),
            const Text('Preferred Date *', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(_selectedDate == null ? 'Select Date' : _selectedDate!.toLocal().toString().split(' ')[0]),
              onPressed: _pickDate,
            ),

            const SizedBox(height: 16),
            const Text('Preferred Time *', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_selectedTime == null ? 'Select Time' : _selectedTime!.format(context)),
              onPressed: _pickTime,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_selectedModel == null || _selectedBranch == null || _selectedDate == null || _selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                  return;
                }
                // Handle appointment submission
              },
              child: const Text('Submit Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
