import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/receipt_notification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dr_cars/interface/obd2.dart';
import 'package:dr_cars/interface/servicerecords.dart';
import 'package:dr_cars/interface/appointments.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = "Loading...";
  int _selectedIndex = 0;
  Map<String, dynamic>? vehicleData;
  bool isLoading = true;
  String? errorMessage;
  String? _vehicleImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchVehicleData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchVehicleData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData =
            await _firestore.collection("Users").doc(user.uid).get();

        if (userData.exists) {
          setState(() {
            userName = userData["Name"] ?? "User";
          });
        } else {
          print("User document does not exist");
          setState(() {
            userName = "User";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          userName = "User";
          errorMessage = "Failed to load user data: $e";
        });
      }
    }
  }

  Future<void> _fetchVehicleData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot vehicleDoc =
            await _firestore.collection("Vehicle").doc(user.uid).get();

        if (vehicleDoc.exists) {
          setState(() {
            vehicleData = vehicleDoc.data() as Map<String, dynamic>;
            _vehicleImageUrl = vehicleData?['vehiclePhotoUrl'];
            isLoading = false;
          });
        } else {
          print("Vehicle document does not exist");
          setState(() {
            isLoading = false;
            errorMessage =
                "No vehicle data found. Please add your vehicle in the profile section.";
          });
        }
      } catch (e) {
        print("Error fetching vehicle data: $e");
        setState(() {
          isLoading = false;
          errorMessage = "Failed to load vehicle data: $e";
        });
      }
    }
  }

  int getNextMaintenanceMileage(int currentMileage) {
    return ((currentMileage ~/ 5000) + 1) * 5000;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'images/logo.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (vehicleData != null && vehicleData!['vehicleNumber'] != null)
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Service_Receipts')
                        .where(
                          'vehicleNumber',
                          isEqualTo: vehicleData!['vehicleNumber'],
                        )
                        .where('status', whereIn: ['not confirmed', 'finished'])
                        .snapshots(),
                builder: (context, snapshot) {
                  int count = snapshot.hasData ? snapshot.data!.docs.length : 0;

                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReceiptNotificationPage(),
                            ),
                          );
                        },
                      ),
                      if (count > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Your vehicle',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            isLoading
                ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                )
                : errorMessage != null
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                )
                : vehicleData == null
                ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "No vehicle data available",
                    style: TextStyle(fontSize: 18),
                  ),
                )
                : Container(
                  width: screenWidth,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth * 1,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 250, 247, 247),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child:
                                  _vehicleImageUrl != null
                                      ? Image.network(
                                        _vehicleImageUrl!,
                                        width: screenWidth * 0.9,
                                        height: 250,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Image.asset(
                                            'images/dashcar.png',
                                            width: screenWidth * 0.9,
                                            height: 250,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                      : Image.asset(
                                        'images/dashcar.png',
                                        width: screenWidth * 0.9,
                                        height: 250,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${vehicleData!['year']?.toString() ?? 'Year not specified'}",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${vehicleData!['selectedBrand'] ?? 'Brand'} ${vehicleData!['selectedModel'] ?? 'Model'}",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '⚙️ ${vehicleData!['mileage']?.toString() ?? '0'} KM',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '🚗 ${vehicleData!['vehicleType'] ?? 'Type not specified'}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (vehicleData!['vehicleNumber'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '🚗 ${vehicleData!['vehicleNumber']}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            SizedBox(height: 20),
            Container(
              width: screenWidth * 0.9,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppointmentsPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Make an Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),
            Container(
              width: screenWidth * 0.9,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceRecordsPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 99, 32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add a Service Record',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Upcoming maintenance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ServiceRecordsPage()),
                );
              },
              child: ListTile(
                title: Text(
                  vehicleData != null
                      ? "${vehicleData!['selectedBrand'] ?? ''} ${vehicleData!['selectedModel'] ?? ''} (${vehicleData!['year']?.toString() ?? 'Year not specified'})"
                      : 'Vehicle not loaded',
                ),
                subtitle: Text(
                  vehicleData != null
                      ? 'Next maintenance at: ${getNextMaintenanceMileage(int.tryParse(vehicleData!['mileage']?.toString() ?? '0') ?? 0)} KM'
                      : '',
                ),
                trailing: Icon(Icons.build, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex)
            return; // Don't navigate if already on the same screen

          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              // Already on dashboard
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
}
