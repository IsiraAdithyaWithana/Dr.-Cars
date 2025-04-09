import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/rating.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: ServiceRecordsPage()),
  );
}

int _selectedIndex = 0;

class ServiceRecordsPage extends StatefulWidget {
  const ServiceRecordsPage({super.key});

  @override
  State<ServiceRecordsPage> createState() => _ServiceRecordsPageState();
}

class _ServiceRecordsPageState extends State<ServiceRecordsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentMileageController =
      TextEditingController();
  final TextEditingController _serviceMileageController =
      TextEditingController();
  final TextEditingController _serviceProviderController =
      TextEditingController();
  final TextEditingController _serviceCostController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedServiceType;
  String? _selectedOilType;
  DateTime? _selectedDate;

  final List<String> _serviceTypes = [
    'Oil Filter Change',
    'Air Filter Change',
    'Battery Performance Check',
    'Brake Inspection',
    'Coolant Change/Check',
    'Tyre Pressure Check',
  ];

  final List<String> _oilTypes = [
    'Synthetic',
    'Semi-Synthetic',
    'Conventional',
    'High Mileage',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveServiceRecord() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save the service record to Firestore
      // After saving, navigate back to Service History page
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Records'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Mileage
              Text(
                'Current Mileage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _currentMileageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixText: 'KM',
                  hintText: 'Enter current mileage',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current mileage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type of Service
              Text(
                'Type of Service',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select service type',
                ),
                items:
                    _serviceTypes.map((String service) {
                      return DropdownMenuItem<String>(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedServiceType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a service type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Oil Type Dropdown (only shown when Oil Filter Change is selected)
              if (_selectedServiceType == 'Oil Filter Change')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oil Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedOilType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select oil type',
                      ),
                      items:
                          _oilTypes.map((String oil) {
                            return DropdownMenuItem<String>(
                              value: oil,
                              child: Text(oil),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOilType = newValue;
                        });
                      },
                      validator: (value) {
                        if (_selectedServiceType == 'Oil Filter Change' &&
                            (value == null || value.isEmpty)) {
                          return 'Please select an oil type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Date of Service
              Text(
                'Date of Service',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Service Mileage
              Text(
                'Service Mileage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _serviceMileageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixText: 'KM',
                  hintText: 'Enter service mileage',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service mileage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Provider
              Text(
                'Service Provider',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _serviceProviderController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter service provider name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service provider';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Cost
              Text(
                'Service Cost',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _serviceCostController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixText: 'Rs.',
                  hintText: 'Enter service cost',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service cost';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Additional Notes
              Text(
                'Additional Notes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter any additional notes',
                ),
              ),
              const SizedBox(height: 24),

              // Save and Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveServiceRecord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RatingScreen()),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 24),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.rate_review, size: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: '',
          ),
        ],
      ),
    );
  }
}
// test 