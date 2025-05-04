import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Widget _buildDashboardTile(IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // New method to build a dashboard tile with an image
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
                // Don't apply color to preserve original image colors
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

  // Method to show information about the indicator when tapped
  void _showIndicatorInfo(String imagePath, String title) {
    // Map of explanations for each indicator
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

    final String explanation = explanations[imagePath] ?? 'No additional information available for this indicator.';
    
    // Show a dialog with the explanation
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

  List<Widget> _buildVehicleSpecificWidgets() {
    // Default widgets for all vehicle brands
    List<Widget> widgets = [];
    
    // Add brand-specific widgets based on selected vehicle brand
    switch (vehicleBrand?.toLowerCase()) {
      case 'toyota':
        widgets = [
          _buildDashboardTileWithImage(
            'images/Toyota/ENGINE CHECK LIGHT.png',
            'Engine Status',
            'Normal',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/Toyota/LOW FUEL.png',
            'Fuel Level',
            '75%',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/Toyota/WATER HEAT.png',
            'Engine Temp',
            '90°C',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/Toyota/BATTERY CHECK.png',
            'Battery',
            '12.6V',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/Toyota/HAND BREAK.png',
            'Parking Brake',
            'Released',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/Toyota/seat bealts.png',
            'Seatbelts',
            'All Fastened',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/Toyota/ABS.png',
            'ABS Status',
            'Active',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/Toyota/DOORS OPEND.png',
            'Doors',
            'All Closed',
            Colors.green,
          ),
        ];
        break;
        
      case 'bmw':
        widgets = [
          _buildDashboardTileWithImage(
            'images/BMW/check engine.png',
            'Engine Status',
            'Normal',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/BMW/fuel low.png',
            'Fuel Level',
            '75%',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/BMW/oil light.png',
            'Oil Level',
            'Normal',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/BMW/high heat.png',
            'Engine Temp',
            '90°C',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/BMW/tire presure waring.png',
            'Tire Pressure',
            '35 PSI',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/BMW/breake.png',
            'Brake System',
            'Normal',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/BMW/ABS.png',
            'ABS Status',
            'Active',
            Colors.green,
          ),
          _buildDashboardTileWithImage(
            'images/BMW/seatbelt.png',
            'Seatbelts',
            'All Fastened',
            Colors.green,
          ),
        ];
        break;
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
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
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
                    child: Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                    children: _buildVehicleSpecificWidgets(),
                  ),
                  
                ],
              ),
            ),
    );
  }
}