import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

 int _selectedIndex = 1;

class _MapScreenState extends State<MapScreen> {
  LocationData? _userLocation;
  final Location _location = Location();

  // List of service centers
  final List<Map<String, dynamic>> serviceCenters = [
    {
      "name": "Colombo Service Center",
      "lat": 6.9271,
      "lng": 79.8612,
      "description": "Located in the heart of Colombo, providing 24/7 customer support."
    },
    {
      "name": "Kandy Service Center",
      "lat": 7.2906,
      "lng": 80.6337,
      "description": "Situated near the Kandy Lake, offering maintenance services."
    },
    {
      "name": "Galle Service Center",
      "lat": 6.0535,
      "lng": 80.2210,
      "description": "A modern facility near Galle Fort, specializing in quick repairs."
    },
    {
      "name": "Jaffna Service Center",
      "lat": 9.6615,
      "lng": 80.0255,
      "description": "Serving the northern region with dedicated support services."
    },
    {
      "name": "Anuradhapura Service Center",
      "lat": 8.3114,
      "lng": 80.4037,
      "description": "Located close to heritage sites, ensuring reliable service."
    },
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _trackUserLocation();
  }

  // Request location permissions and get current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _location.changeSettings(
      accuracy: LocationAccuracy.high, // Ensures high accuracy
      interval: 3000, // Updates every 3 seconds
    );

    final LocationData locationData = await _location.getLocation();
    setState(() {
      _userLocation = locationData;
    });
  }

  // Continuously track user location
  void _trackUserLocation() {
    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _userLocation = currentLocation;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: Colors.white),
         onPressed: () {
         Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    },
  ),
        title: const Text(" Dr Cars Service Centers"),
        
      ),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator()) // Show loader if location is null
          : FlutterMap(
              options: MapOptions(
                center: LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
                zoom: 9.0, // Adjusted zoom
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
  markers: [
    // User's Current Location Marker
    Marker(
      point: LatLng(_userLocation!.latitude!, _userLocation!.longitude!),
      width: 50,
      height: 50,
      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 50),
    ),

    // Service Center Markers with Clickable Dialog
    for (var center in serviceCenters)
      Marker(
        point: LatLng(center["lat"], center["lng"]),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(center["name"]),
                  content: Text(center["description"]),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      ),
  ],
),

              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: () async {
          final LocationData locationData = await _location.getLocation();
          setState(() {
            _userLocation = locationData;
          });
        },
      ),
      
      // **Bottom Navigation Bar**
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

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
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RatingScreen()),
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
          BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ), 
    );
  }
}