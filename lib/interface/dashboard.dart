// lib/interface/dashboard.dart
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/VehicleDashboard.dart';
import 'package:dr_cars/interface/appointment_notification_page.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/receipt_notification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dr_cars/interface/obd2.dart';
import 'package:dr_cars/interface/servicerecords.dart';
import 'package:dr_cars/interface/appointments.dart';
import 'package:rxdart/rxdart.dart';

// reuse the same color constants
const Color kAppBarColor = Colors.black;
const Color kAccentOrange = Color.fromARGB(255, 255, 99, 32);
const Color kBlueTint = Color.fromARGB(255, 243, 72, 33);
const Color kVehicleCardBg = Color(0xFFFAF7F7);
const Color kErrorRed = Colors.red;
const Color kIconBgOpacityBlue = Color.fromRGBO(0, 0, 255, .1);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String userName = "Loading...";
  int _selectedIndex = 0;
  Map<String, dynamic>? vehicleData;
  bool isLoading = true;
  String? errorMessage;
  String? _vehicleImageUrl;
  bool _hasVehicleInfo = false;
  bool _checkingVehicleInfo = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchVehicleData();
    _checkVehicleSetup();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final doc = await _firestore.collection("Users").doc(user.uid).get();
      setState(() {
        userName = (doc.exists ? doc["Name"] : null) ?? "User";
      });
    } catch (e) {
      setState(() => userName = "User");
      debugPrint("Error fetching user data: $e");
    }
  }

  Future<void> _fetchVehicleData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final doc = await _firestore.collection("Vehicle").doc(user.uid).get();
      if (doc.exists) {
        vehicleData = doc.data() as Map<String, dynamic>?;
        _vehicleImageUrl = vehicleData?['vehiclePhotoUrl'];
      } else {
        errorMessage =
            "No vehicle data found. Please add your vehicle in your profile.";
      }
    } catch (e) {
      errorMessage = "Failed to load vehicle data.";
      debugPrint("Error fetching vehicle data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkVehicleSetup() async {
    setState(() => _checkingVehicleInfo = true);
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('Vehicle').doc(user.uid).get();
      _hasVehicleInfo = doc.exists;
    }
    setState(() => _checkingVehicleInfo = false);
  }

  int getNextMaintenanceMileage(int current) => ((current ~/ 5000) + 1) * 5000;

  Widget _buildVehicleDashboardButton() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VehicleDashboardScreen()),
            ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kIconBgOpacityBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.dashboard_customize,
                  color: Color.fromARGB(255, 243, 96, 33),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View real-time vehicle metrics and status',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartVehicleDashboardButton() {
    if (_checkingVehicleInfo) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasVehicleInfo) {
      return Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.orange,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Up Your Vehicle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Complete your vehicle profile to access the dashboard',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      );
    }
    return _buildVehicleDashboardButton();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = MediaQuery.of(context).size.width;
    final text = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
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
                    Text(
                      'Welcome Back',
                      style: text.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (vehicleData?['vehicleNumber'] != null)
              StreamBuilder<List<QuerySnapshot>>(
                stream: Rx.combineLatest2(
                  _firestore
                      .collection('Service_Receipts')
                      .where(
                        'vehicleNumber',
                        isEqualTo: vehicleData!['vehicleNumber'],
                      )
                      .where('status', whereIn: ['not confirmed', 'finished'])
                      .snapshots(),
                  _firestore
                      .collection('appointments')
                      .where(
                        'vehicleNumber',
                        isEqualTo: vehicleData!['vehicleNumber'],
                      )
                      .where('status', whereIn: ['accepted', 'rejected'])
                      .snapshots(),
                  (a, b) => [a, b],
                ),
                builder: (_, snap) {
                  if (!snap.hasData) return const SizedBox();
                  final receipts = snap.data![0];
                  final appointments = snap.data![1];
                  final totalCount = receipts.size + appointments.size;

                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder:
                                (_) => BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 4,
                                    sigmaY: 4,
                                  ),
                                  child: Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Select Notification Type",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Divider(),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.receipt_long,
                                            ),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Receipt Notifications",
                                                ),
                                                if (receipts.size > 0)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: kErrorRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${receipts.size}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          const ReceiptNotificationPage(),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(
                                              Icons.calendar_today,
                                            ),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Appointment Notifications",
                                                ),
                                                if (appointments.size > 0)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: kErrorRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${appointments.size}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          const AppointmentNotificationPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          );
                        },
                      ),
                      if (totalCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: kErrorRed,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '$totalCount',
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
            const SizedBox(height: 20),
            Text(
              'Your Vehicle',
              style: text.headlineSmall?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 10),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  errorMessage!,
                  style: text.bodyLarge?.copyWith(color: kErrorRed),
                ),
              )
            else if (vehicleData == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("No vehicle data available", style: text.bodyLarge),
              )
            else
              Container(
                width: w,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child:
                          _vehicleImageUrl != null
                              ? Image.network(
                                _vehicleImageUrl!,
                                width: w,
                                height: 250,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => Image.asset(
                                      'images/dashcar.png',
                                      width: w,
                                      height: 250,
                                      fit: BoxFit.cover,
                                    ),
                              )
                              : Image.asset(
                                'images/dashcar.png',
                                width: w,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${vehicleData!['year'] ?? 'Year not specified'}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${vehicleData!['selectedBrand'] ?? ''} ${vehicleData!['selectedModel'] ?? ''}",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '⚙️ ${vehicleData!['mileage'] ?? '0'} KM',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '🚗 ${vehicleData!['vehicleType'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (vehicleData!['vehicleNumber'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '🚗 ${vehicleData!['vehicleNumber']}',
                                style: const TextStyle(
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

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppointmentsPage(),
                        ),
                      ),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text(
                    'Make an Appointment',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ServiceRecordsPage()),
                      ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add a Service Record',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0, // Match the previous button
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Upcoming maintenance', style: text.titleMedium),
            ),
            InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ServiceRecordsPage()),
                  ),
              child: ListTile(
                title: Text(
                  vehicleData != null
                      ? "${vehicleData!['selectedBrand']} ${vehicleData!['selectedModel']} (${vehicleData!['year']})"
                      : '',
                ),
                subtitle: Text(
                  vehicleData != null
                      ? 'Next maintenance at: ${getNextMaintenanceMileage(int.tryParse(vehicleData!['mileage'].toString()) ?? 0)} KM'
                      : '',
                ),
                trailing: const Icon(Icons.build, color: Colors.orange),
              ),
            ),

            _buildSmartVehicleDashboardButton(),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: kAccentOrange,
        unselectedItemColor:
            theme.brightness == Brightness.light
                ? Colors.black
                : Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i == _selectedIndex) return;
          setState(() => _selectedIndex = i);
          Widget target = widget;
          switch (i) {
            case 1:
              target = MapScreen();
              break;
            case 2:
              target = const OBD2Page();
              break;
            case 3:
              target = const ServiceHistorypage();
              break;
            case 4:
              target = const ProfileScreen();
              break;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => target),
          );
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', width: 30, height: 30),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
