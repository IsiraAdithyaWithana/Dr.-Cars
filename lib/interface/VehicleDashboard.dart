import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class VehicleDashboardScreen extends StatefulWidget {
  const VehicleDashboardScreen({Key? key}) : super(key: key);

  @override
  _VehicleDashboardScreenState createState() => _VehicleDashboardScreenState();
}

class _VehicleDashboardScreenState extends State<VehicleDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? vehicleData;
  String? vehicleType;
  String? vehicleBrand;
  String? vehicleModel;
  List<String> brandIndicatorImages = [];

  // Status mapping - can be updated from Firestore in a real implementation
  final Map<String, Map<String, dynamic>> statusInfo = {
    'Engine Status': {'value': 'Normal', 'color': Colors.green},
    'Fuel Level': {'value': '75%', 'color': Colors.green},
    'Engine Temp': {'value': '90°C', 'color': Colors.green},
    'Battery': {'value': '12.6V', 'color': Colors.green},
    'Parking Brake': {'value': 'Released', 'color': Colors.green},
    'Seatbelts': {'value': 'All Fastened', 'color': Colors.green},
    'ABS Status': {'value': 'Active', 'color': Colors.green},
    'Doors': {'value': 'All Closed', 'color': Colors.green},
    'Oil Level': {'value': 'Normal', 'color': Colors.green},
    'Tire Pressure': {'value': '35 PSI', 'color': Colors.green},
    'Brake System': {'value': 'Normal', 'color': Colors.green},
  };

  // Indicator explanations
  final Map<String, String> explanations = {
    // BMW indicators
    'images/BMW/123.png': 'ABS Warning: Indicates a problem with the Anti-lock Braking System.',
    'images/BMW/ABS.png': 'Anti-lock Braking System Warning: ABS may not be functioning properly.',
    'images/BMW/airbag waring.png': 'Airbag System Warning: Service required for airbag system.',
    'images/BMW/breake.png': 'Brake System Warning: Check brake fluid level and brake function.',
    'images/BMW/check engine.png': 'Check Engine Warning: Engine issue detected, service needed.',
    'images/BMW/e brake.png': 'Automatic Brake Hold: This system is active.',
    'images/BMW/fog lights.png': 'Fog Lights: Fog lights are currently turned on.',
    'images/BMW/fuel low.png': 'Low Fuel Warning: Fuel level is low, refuel soon.',
    'images/BMW/glow.png': 'Diesel Pre-heating: Diesel glow plug indicator is active.',
    'images/BMW/high heat.png': 'Engine Temperature Warning: Engine is overheating.',
    'images/BMW/oil light.png': 'Oil Pressure Warning: Check oil level immediately.',
    'images/BMW/seatbelt.png': 'Seatbelt Reminder: One or more seatbelts are not fastened.',
    'images/BMW/tire presure waring.png': 'Tire Pressure Warning: Check tire pressure in one or more tires.',
    'images/BMW/TRC.png': 'Traction Control: Traction control system is active or has an issue.',
    'images/BMW/warning.png': 'General Warning: Check vehicle systems.',
    'images/BMW/window heater.png': 'Window Defroster: Rear window defroster is active.',
    
    // Toyota indicators
    'images/Toyota/ABS.png': 'ABS Warning: Indicates a problem with the Anti-lock Braking System.',
    'images/Toyota/BATTERY CHECK.png': 'Battery Warning: Issue with battery or charging system.',
    'images/Toyota/DOORS OPEND.png': 'Door Ajar Warning: One or more doors are not fully closed.',
    'images/Toyota/ENGINE CHECK LIGHT.png': 'Check Engine Warning: Engine malfunction detected.',
    'images/Toyota/HAND BREAK.png': 'Parking Brake: Parking brake is currently engaged.',
    'images/Toyota/HAZARD.png': 'Hazard Lights: Hazard warning lights are active.',
    'images/Toyota/HEAD BEAM.png': 'High Beam: High beam headlights are currently active.',
    'images/Toyota/LOW BEAM.png': 'Low Beam: Low beam headlights are currently active.',
    'images/Toyota/LOW FUEL.png': 'Low Fuel Warning: Fuel level is low, refuel soon.',
    'images/Toyota/seat bealts.png': 'Seatbelt Reminder: One or more seatbelts are not fastened.',
    'images/Toyota/WATER HEAT.png': 'Engine Temperature Warning: Engine is overheating.',
    'images/Toyota/WINDSCREEN WASHER LIQUID LOW.png': 'Washer Fluid Warning: Windshield washer fluid is low.',
  };

  // Indicator title mapping
  final Map<String, String> indicatorTitles = {
    // BMW
    'images/BMW/check engine.png': 'Engine Status',
    'images/BMW/fuel low.png': 'Fuel Level',
    'images/BMW/oil light.png': 'Oil Level',
    'images/BMW/high heat.png': 'Engine Temp',
    'images/BMW/tire presure waring.png': 'Tire Pressure',
    'images/BMW/breake.png': 'Brake System',
    'images/BMW/ABS.png': 'ABS Status',
    'images/BMW/seatbelt.png': 'Seatbelts',
    'images/BMW/123.png': 'ABS Warning',
    'images/BMW/airbag waring.png': 'Airbag Warning',
    'images/BMW/e brake.png': 'Auto Brake Hold',
    'images/BMW/fog lights.png': 'Fog Lights',
    'images/BMW/glow.png': 'Diesel Preheat',
    'images/BMW/TRC.png': 'Traction Control',
    'images/BMW/warning.png': 'Warning',
    'images/BMW/window heater.png': 'Window Defroster',

    // Toyota
    'images/Toyota/ENGINE CHECK LIGHT.png': 'Engine Status',
    'images/Toyota/LOW FUEL.png': 'Fuel Level',
    'images/Toyota/WATER HEAT.png': 'Engine Temp',
    'images/Toyota/BATTERY CHECK.png': 'Battery',
    'images/Toyota/HAND BREAK.png': 'Parking Brake',
    'images/Toyota/seat bealts.png': 'Seatbelts',
    'images/Toyota/ABS.png': 'ABS Status',
    'images/Toyota/DOORS OPEND.png': 'Doors',
    'images/Toyota/HAZARD.png': 'Hazard Lights',
    'images/Toyota/HEAD BEAM.png': 'High Beam',
    'images/Toyota/LOW BEAM.png': 'Low Beam',
    'images/Toyota/WINDSCREEN WASHER LIQUID LOW.png': 'Washer Fluid',
  };

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final vehicleDoc = await FirebaseFirestore.instance
            .collection('Vehicle')
            .doc(user.uid)
            .get();

        if (vehicleDoc.exists) {
          setState(() {
            vehicleData = vehicleDoc.data();
            vehicleType = vehicleData!['vehicleType'];
            vehicleBrand = vehicleData!['selectedBrand'];
            vehicleModel = vehicleData!['selectedModel'];
          });
          
          // Load all indicator images for the selected brand
          await _loadIndicatorImages();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No vehicle information found. Please set up your vehicle first.')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error loading vehicle data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading vehicle data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadIndicatorImages() async {
    // Clear previous list
    brandIndicatorImages = [];
    
    if (vehicleBrand == null) return;
    
    try {
      // Load all images from the brand's folder
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = Map<String, dynamic>.from(
          jsonDecode(manifestContent) as Map);
          
      final imagePaths = manifestMap.keys
          .where((String key) => key.contains('images/${vehicleBrand}/') && key.endsWith('.png'))
          .toList();
          
      setState(() {
        brandIndicatorImages = imagePaths;
      });
      
      print("Loaded ${brandIndicatorImages.length} indicators for $vehicleBrand");
    } catch (e) {
      print("Error loading indicator images: $e");
      // Fallback to hardcoded paths if needed
      _loadFallbackImages();
    }
  }
  
  void _loadFallbackImages() {
    // Fallback images if dynamic loading fails
    if (vehicleBrand?.toLowerCase() == 'bmw') {
      brandIndicatorImages = [
        'images/BMW/check engine.png',
        'images/BMW/fuel low.png',
        'images/BMW/oil light.png',
        'images/BMW/high heat.png',
        'images/BMW/tire presure waring.png',
        'images/BMW/breake.png',
        'images/BMW/ABS.png',
        'images/BMW/seatbelt.png',
        'images/BMW/123.png',
        'images/BMW/airbag waring.png',
        'images/BMW/e brake.png',
        'images/BMW/fog lights.png',
        'images/BMW/glow.png',
        'images/BMW/TRC.png',
        'images/BMW/warning.png',
        'images/BMW/window heater.png',
      ];
    } else if (vehicleBrand?.toLowerCase() == 'toyota') {
      brandIndicatorImages = [
        'images/Toyota/ENGINE CHECK LIGHT.png',
        'images/Toyota/LOW FUEL.png',
        'images/Toyota/WATER HEAT.png',
        'images/Toyota/BATTERY CHECK.png',
        'images/Toyota/HAND BREAK.png',
        'images/Toyota/seat bealts.png',
        'images/Toyota/ABS.png',
        'images/Toyota/DOORS OPEND.png',
        'images/Toyota/HAZARD.png',
        'images/Toyota/HEAD BEAM.png',
        'images/Toyota/LOW BEAM.png',
        'images/Toyota/WINDSCREEN WASHER LIQUID LOW.png',
      ];
    }
  }

  Widget _buildVehicleInfo() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: vehicleData?['vehiclePhotoUrl'] != null
                  ? NetworkImage(vehicleData!['vehiclePhotoUrl'])
                  : AssetImage('images/logo.png') as ImageProvider,
              radius: 30,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$vehicleBrand $vehicleModel',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    vehicleData?['vehicleNumber'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Type: $vehicleType | Year: ${vehicleData?['year']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTileWithImage(
    String imagePath,
    String title,
    String value,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        _showIndicatorInfo(imagePath, title);
      },
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 40,
                width: 40,
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading image $imagePath: $error");
                  return Icon(Icons.error_outline, size: 40, color: Colors.red);
                },
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIndicatorInfo(String imagePath, String title) {
    final String explanation = explanations[imagePath] ?? 'No additional information available for this indicator.';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imagePath,
                height: 60,
                width: 60,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error_outline, size: 60, color: Colors.red);
                },
              ),
              SizedBox(height: 16),
              Text(explanation),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildAllIndicatorTiles() {
    List<Widget> widgets = [];
    
    if (brandIndicatorImages.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "No indicator images found for $vehicleBrand",
              style: TextStyle(fontSize: 16),
            ),
          ),
        )
      ];
    }
    
    for (String imagePath in brandIndicatorImages) {
      // Get title from mapping or use fallback
      String title = indicatorTitles[imagePath] ?? 
                    imagePath.split('/').last.replaceAll('.png', '').replaceAll('_', ' ');
      
      // Get status from mapping or use default
      Map<String, dynamic> status = statusInfo[title] ?? {'value': 'Normal', 'color': Colors.green};
      
      widgets.add(
        _buildDashboardTileWithImage(
          imagePath,
          title,
          status['value'],
          status['color'],
        ),
      );
    }
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _loadVehicleData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVehicleInfo(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dashboard Indicators',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${brandIndicatorImages.length} indicators',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: _buildAllIndicatorTiles(),
                  ),
                ],
              ),
            ),
    );
  }
}