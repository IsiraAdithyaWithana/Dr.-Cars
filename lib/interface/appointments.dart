import 'package:dr_cars/interface/OBD2.dart';
import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  //  used this controller for save the vehicle number in the fire base
  final TextEditingController _vehicleNumberController =
      TextEditingController();
  bool _isLoading = true;

  final List<String> vehicleModels = [
    'Car',
    'Van',
    'Jeep',
    'Truck',
    'Motorcycle',
    'Three-Wheeler',
    'Bus',
  ];

  final List<String> serviceTypes = [
    'Full Service',
    'Oil and filter change',
    'Tire pressure and rotation check',
    'Fluid level check',
    'Battery check and replacements',
    'Wiper blade replacement',
    'Light bulb check',
    'Brake system services',
    'Suspension and alignment services',
    'Exhaust system service',
    'Air conditioning services',
    'Electrical system services',
    'Car detailing (Interior and exterior cleaning, waxing)',
    'Tire sales and installation',
    'Pre-purchase inspections',
    'Diagnostic testing',
  ];

  final List<String> branches = [
    // Western Province
    'Colombo',
    'Dehiwala',
    'Moratuwa',
    'Nugegoda',
    'Homagama',
    'Piliyandala',
    'Battaramulla',
    'Gampaha',
    'Negombo', 'Ja-Ela', 'Wattala', 'Ragama', 'Katunayake',
    'Kalutara',
    'Panadura',
    'Beruwala',
    'Horana',
    'Aluthgama',
    'Matugama',

    // Central Province
    'Kandy',
    'Peradeniya',
    'Katugastota',
    'Gampola',
    'Nawalapitiya',
    'Matale', 'Dambulla', 'Ukuwela', 'Rattota',
    'Nuwara Eliya', 'Hatton', 'Talawakele', 'Nanu Oya',

    // Southern Province
    'Galle', 'Unawatuna', 'Ambalangoda', 'Hikkaduwa',
    'Matara', 'Weligama', 'Akurassa', 'Dikwella',
    'Hambantota', 'Tangalle', 'Tissamaharama', 'Ambalantota',

    // Northern Province
    'Jaffna', 'Point Pedro', 'Chavakachcheri', 'Nallur',
    'Kilinochchi', 'Pallai', 'Paranthan',
    'Mannar', 'Thalaimannar', 'Pesalai',
    'Vavuniya', 'Cheddikulam', 'Nedunkeni',
    'Mullaitivu', 'Puthukkudiyiruppu', 'Oddusuddan',

    // Eastern Province
    'Batticaloa', 'Eravur', 'Kattankudy',
    'Ampara', 'Kalmunai', 'Sammanthurai', 'Akkaraipattu',
    'Trincomalee', 'Kinniya', 'Mutur', 'Kuchchaveli',

    // North Western Province
    'Kurunegala', 'Pannala', 'Nikaweratiya', 'Kuliyapitiya',
    'Puttalam', 'Wennappuwa', 'Chilaw', 'Anamaduwa',

    // North Central Province
    'Anuradhapura', 'Kekirawa', 'Medawachchiya', 'Mihintale',
    'Polonnaruwa', 'Hingurakgoda', 'Medirigiriya',

    // Uva Province
    'Badulla', 'Bandarawela', 'Hali-Ela', 'Diyatalawa',
    'Monaragala', 'Wellawaya', 'Bibile', 'Buttala',

    // Sabaragamuwa Province
    'Ratnapura', 'Balangoda', 'Eheliyagoda', 'Kuruwita',
    'Kegalle', 'Mawanella', 'Rambukkana', 'Warakapola',
  ];

  List<Map<String, dynamic>> _filteredServiceCenters = [];
  String? _selectedServiceCenterId;

  String? _selectedModel;
  List<String> _selectedServices = [];
  String? _selectedBranch;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _appointmentsCount = 0;

  String? _userPhoneNumber;
  String? _userId;

  Future<void> _fetchAppointmentsForDate(DateTime date) async {
    try {
      // Convert date to start and end of day
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      setState(() {
        _appointmentsCount = snapshot.docs.length;
      });
    } catch (e) {
      print('Error fetching appointments: $e');
      setState(() {
        _appointmentsCount = 0;
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
      await _fetchAppointmentsForDate(pickedDate);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get();
      setState(() {
        _userPhoneNumber =
            userDoc['Contact']; // make sure this key matches your Firestore
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot vehicleDoc =
            await FirebaseFirestore.instance
                .collection('Vehicle')
                .doc(user.uid)
                .get();

        if (vehicleDoc.exists) {
          setState(() {
            _vehicleNumberController.text = vehicleDoc['vehicleNumber'] ?? '';
            _selectedModel = vehicleDoc['vehicleType'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No vehicle information found. Please set up your vehicle first.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading vehicle data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Book Your Appointment',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FractionallySizedBox(
              widthFactor: constraints.maxWidth > 600 ? 0.6 : 0.95,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vehicle Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Divider(
                          color: Color.fromARGB(255, 189, 7, 7),
                          thickness: 1.5,
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Vehicle Number '),
                        TextField(
                          controller: _vehicleNumberController,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: "EX: CAD-0896",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),

                        const SizedBox(height: 16),
                        _buildLabel('Vehicle Model '),
                        DropdownButtonFormField<String>(
                          value: _selectedModel,
                          items:
                              vehicleModels
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
                          onChanged: null,
                          decoration: InputDecoration(
                            hintText: "SELECT",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Type of Service '),
                        _buildMultiSelect(),

                        const SizedBox(height: 16),

                        _buildLabel('City'),
                        _buildDropdown(
                          List<String>.from(branches)..sort(),
                          _selectedBranch,
                          (value) async {
                            setState(() {
                              _selectedBranch = value;
                              _filteredServiceCenters = [];
                              _selectedServiceCenterId = null;
                            });

                            QuerySnapshot snapshot =
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .where(
                                      'User Type',
                                      isEqualTo: 'Service Center',
                                    )
                                    .where('City', isEqualTo: value)
                                    .get();

                            setState(() {
                              _filteredServiceCenters =
                                  snapshot.docs
                                      .map(
                                        (doc) => {
                                          'id': doc.id,
                                          'name': doc['Service Center Name'],
                                          'uid': doc['uid'],
                                        },
                                      )
                                      .toList();
                            });
                          },
                        ),

                        if (_filteredServiceCenters.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Select Service Center'),
                              DropdownButtonFormField<String>(
                                value: _selectedServiceCenterId,
                                items:
                                    _filteredServiceCenters.map((center) {
                                      return DropdownMenuItem<String>(
                                        value: center['id'],
                                        child: Text(center['name']),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(
                                    () => _selectedServiceCenterId = value,
                                  );
                                },
                                decoration: InputDecoration(
                                  hintText: "SELECT",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                ),
                              ),
                            ],
                          ),

                        if (_filteredServiceCenters.isEmpty &&
                            _selectedBranch != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'No service centers available in this city.',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

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
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  9,
                                  23,
                                  111,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () async {
                                if (_vehicleNumberController.text
                                        .trim()
                                        .isEmpty ||
                                    _selectedModel == null ||
                                    _selectedBranch == null ||
                                    _selectedDate == null ||
                                    _selectedTime == null ||
                                    _selectedServices.isEmpty ||
                                    _selectedServiceCenterId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill all required fields',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  final selectedCenter = _filteredServiceCenters
                                      .firstWhere(
                                        (center) =>
                                            center['id'] ==
                                            _selectedServiceCenterId,
                                      );

                                  await FirebaseFirestore.instance
                                      .collection('appointments')
                                      .add({
                                        'vehicleNumber':
                                            _vehicleNumberController.text
                                                .trim(),
                                        'vehicleModel': _selectedModel,
                                        'serviceTypes': _selectedServices,
                                        'branch': _selectedBranch,
                                        'date':
                                            _selectedDate!.toIso8601String(),
                                        'time': _selectedTime!.format(context),
                                        'timestamp':
                                            FieldValue.serverTimestamp(),
                                        'Contact': _userPhoneNumber,
                                        'userId': _userId,
                                        'serviceCenterUid':
                                            selectedCenter['uid'],
                                        'status': 'pending',
                                      });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Appointment booked successfully!',
                                      ),
                                    ),
                                  );

                                  // Redirect to dashboard after short delay
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DashboardScreen(),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                              child: const Text(
                                'Schedule Appointment',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
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
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,

        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OBD2Page()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ServiceHistorypage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "SELECT",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildMultiSelect() {
    return Wrap(
      spacing: 6.0,
      children:
          serviceTypes.map((service) {
            final isSelected = _selectedServices.contains(service);
            return FilterChip(
              label: Text(service, overflow: TextOverflow.ellipsis),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedServices.add(service);
                  } else {
                    _selectedServices.remove(service);
                  }
                });
              },
            );
          }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
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
                Text(
                  _selectedDate == null
                      ? 'SELECT DATE'
                      : _selectedDate!.toLocal().toString().split(' ')[0],
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_selectedDate != null && _appointmentsCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'There are $_appointmentsCount appointment(s) already scheduled for this date.',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

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
            Text(
              _selectedTime == null
                  ? 'SELECT TIME'
                  : _selectedTime!.format(context),
            ),
            const Icon(Icons.access_time, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
