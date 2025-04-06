import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/rating.dart';
import 'package:dr_cars/main/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userName = "Loading...";
  int _selectedIndex = 0;
  Map<String, dynamic>? vehicleData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _fetchVehicleData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot =
            await _firestore
                .collection("Vehicle")
                .where("userId", isEqualTo: user.uid)
                .limit(1)
                .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            vehicleData =
                querySnapshot.docs.first.data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = "No vehicle found. Add a vehicle to see details.";
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = "Error loading vehicle data";
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Image.asset('images/logo.png', height: 80),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome, $userName!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Sign Out",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
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
                              child: Image.asset(
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
                                    "${vehicleData!['manufactureYear']?.toString() ?? 'Year not specified'}",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${vehicleData!['brand'] ?? 'Brand'} ${vehicleData!['model'] ?? 'Model'}",
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
                                        '🛢 ${vehicleData!['type'] ?? 'Type not specified'}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Upcoming maintenance',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Text(
                vehicleData != null
                    ? "${vehicleData!['brand'] ?? ''} ${vehicleData!['model'] ?? ''} (${vehicleData!['manufactureYear']?.toString() ?? 'Year not specified'})"
                    : 'Vehicle not loaded',
              ),
              subtitle: Text(
                vehicleData != null
                    ? 'Next maintenance at: ${getNextMaintenanceMileage(vehicleData!['mileage'] ?? 0)} KM'
                    : '',
              ),
              trailing: Icon(Icons.build, color: Colors.orange),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          if (index == 3)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RatingScreen()),
            );
          if (index == 4)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
