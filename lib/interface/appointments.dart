import 'package:flutter/material.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  // Lists for dropdowns
  final List<String> vehicleModels = ['Car', 'Van', 'Jeep', 'Truck', 'Motorcycle','Three-Wheeler','Bus'];
  final List<String> serviceTypes = ['Full Service', 'Oil and filter change', 'Tire pressure and rotation check','Fluid level check','Battery check and replacements','Wiper blade replacement'
                                                'Light blub check','Brake system services','Susupension and alignment services','Exhaust system service','Air conditioning services','Electrical system services','Car detailing(Interior and exterior cleaning, waxing)','Tire sales and installation','pre-purchase inspections','Diagnostic testing'];
  final List<String> branches = ['Kandy', 'Colombo', 'Galle', 'Jaffna', 'Kurunegala','Kalutara','Matara','Batticaloa'];

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
      appBar: AppBar(
        title: const Text('Book Your Appointment', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
        ),
        centerTitle: true,
      ),
    
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5, // 🌟 Adds shadow for a modern look
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehicle Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                ),
                const Divider(color: Colors.redAccent, thickness: 1.5),

                const SizedBox(height: 16),
                _buildLabel('Vehicle Number '),
                _buildTextField(),

                const SizedBox(height: 16),
                _buildLabel('Vehicle Model '),
                _buildDropdown(vehicleModels, _selectedModel, (value) => setState(() => _selectedModel = value)),

                const SizedBox(height: 16),
                _buildLabel('Type of Service '),
                _buildDropdown(serviceTypes, _selectedService, (value) => setState(() => _selectedService = value)),

                const SizedBox(height: 16),
                _buildLabel('Preferred Branch '),
                _buildDropdown(branches, _selectedBranch, (value) => setState(() => _selectedBranch = value)),

                const SizedBox(height: 16),
                _buildLabel('Preferred Date '),
                _buildDatePicker(),

                const SizedBox(height: 16),
                _buildLabel('Preferred Time '),
                _buildTimePicker(),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 58, 85, 255), 
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (_selectedModel == null || _selectedBranch == null || _selectedDate == null || _selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all required fields')),
                        );
                        return;
                      }
                      // Handle appointment submission
                    },
                    child: const Text('Submit Appointment', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Label Widget
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  // 🔹 TextField Widget
  Widget _buildTextField() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  // 🔹 Dropdown Widget
  Widget _buildDropdown(List<String> items, String? selectedValue, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  // 🔹 Date Picker Widget
  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_selectedDate == null ? 'Select Date' : _selectedDate!.toLocal().toString().split(' ')[0]),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 🔹 Time Picker Widget
  Widget _buildTimePicker() {
    return InkWell(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_selectedTime == null ? 'Select Time' : _selectedTime!.format(context)),
            const Icon(Icons.access_time, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
