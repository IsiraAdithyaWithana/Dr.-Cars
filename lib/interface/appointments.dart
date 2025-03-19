import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  // Lists for dropdowns
  final List<String> vehicleModels = ['Car', 'Van', 'Jeep', 'Truck', 'Motorcycle', 'Three-Wheeler', 'Bus'];
  final List<String> serviceTypes = [
    'Full Service', 'Oil and filter change', 'Tire pressure and rotation check',
    'Fluid level check', 'Battery check and replacements', 'Wiper blade replacement',
    'Light bulb check', 'Brake system services', 'Suspension and alignment services',
    'Exhaust system service', 'Air conditioning services', 'Electrical system services',
    'Car detailing (Interior and exterior cleaning, waxing)', 'Tire sales and installation',
    'Pre-purchase inspections', 'Diagnostic testing'
  ];
  final List<String> branches = ['Kandy', 'Colombo', 'Galle', 'Jaffna', 'Kurunegala', 'Kalutara', 'Matara', 'Batticaloa'];

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
      title: const Text(
        'Book Your Appointment',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      centerTitle: true,
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: FractionallySizedBox(
            widthFactor: constraints.maxWidth > 600 ? 0.6 : 0.95, //Increased width slightly for safety
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView( //Allows scrolling to avoid overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicle Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const Divider(color: Color.fromARGB(255, 189, 7, 7), thickness: 1.5),
                      const SizedBox(height: 16),
                      _buildLabel('Vehicle Number '),
                      _buildTextField(),
                      const SizedBox(height: 16),
                      _buildLabel('Vehicle Model '),
                      _buildDropdown(vehicleModels, _selectedModel, (value) => setState(() => _selectedModel = value)),
                      const SizedBox(height: 16),
                      _buildLabel('Type of Service '),
                     
                       SizedBox(
                        width: double.infinity, //Ensures it fits within the container
                        child: DropdownButtonFormField<String>(
                          value: _selectedService,
                          items: serviceTypes.map((service) {
                            return DropdownMenuItem<String>(
                              value: service,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.6, // Limits dropdown width
                                ),
                                child: Text(
                                  service,
                                  overflow: TextOverflow.ellipsis, // Truncates long text
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedService = value;
                            });
                          },
                          isExpanded: true, // Ensures the dropdown fits inside its container
                          decoration: InputDecoration(
                            hintText: "SELECT",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),


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
                      Center(
                        child: SizedBox(
                          width: 180, 
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(180, 50),
                              backgroundColor: const Color.fromARGB(255, 9, 23, 111),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            onPressed: () async{
                              if (_selectedModel == null || _selectedBranch == null || _selectedDate == null || _selectedTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all required fields')),
                                );
                                return;
                              }
                              try {
                                await FirebaseFirestore.instance.collection('appointments').add({
                                  'vehicleModel': _selectedModel,
                                  'serviceType': _selectedService,
                                  'branch': _selectedBranch,
                                  'date': _selectedDate!.toIso8601String(),
                                  'time': _selectedTime!.format(context),
                                  'timestamp': FieldValue.serverTimestamp(), // Useful for ordering
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Appointment booked successfully!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            child: const Text('Submit Appointment', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  
  bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
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
        hintText: "EX: CAD-0896",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
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
        hintText: "SELECT",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
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
          borderRadius: BorderRadius.circular(25),
          color: Colors.grey[200],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_selectedDate == null ? 'SELECT DATE' : _selectedDate!.toLocal().toString().split(' ')[0]),
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
          borderRadius: BorderRadius.circular(25),
          color: Colors.grey[200],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_selectedTime == null ? 'SELECT TIME' : _selectedTime!.format(context)),
            const Icon(Icons.access_time, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
