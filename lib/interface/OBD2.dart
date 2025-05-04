import 'package:flutter/material.dart';
import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'dart:async';
import 'package:dr_cars/service/OBD2.dart';
// Create this file (provided next)

class OBD2Page extends StatefulWidget {
  const OBD2Page({Key? key}) : super(key: key);

  @override
  _OBD2PageState createState() => _OBD2PageState();
}

class _OBD2PageState extends State<OBD2Page> {
  int _selectedIndex = 2;
  bool _isConnected = false;
  String? _selectedVehicle;
  double? _rpm;
  double? _coolantTemp;
  double? _speed;
  double? _fuelConsumption;
  late Timer _liveDataTimer;

  final List<String> _vehicles = [
    'Toyota Camry',
    'Honda Civic',
    'Suzuki Estilo',
    'BMW X5',
    'Mercedes C-Class',
    'Ford Mustang',
    'Chevrolet Malibu',
    'Hyundai Elantra',
    'Kia Seltos',
    'Volkswagen Passat',
    'Audi A4',
    'Nissan Altima',
    'Mazda 3',
    'Jeep Wrangler',
    'Subaru Outback',
    'Tesla Model 3',
  ];

  @override
  void dispose() {
    if (_liveDataTimer.isActive) _liveDataTimer.cancel();
    super.dispose();
  }

  Future<void> _connectToOBD2() async {
    bool connected = await OBD2.connect();
    setState(() {
      _isConnected = connected;
    });

    if (connected) {
      _startLiveDataPolling();
    }
  }

  void _disconnectOBD2() {
    OBD2.disconnect();
    if (_liveDataTimer.isActive) _liveDataTimer.cancel();
    setState(() {
      _isConnected = false;
      _rpm = null;
      _coolantTemp = null;
      _speed = null;
      _fuelConsumption = null;
    });
  }

  void _startLiveDataPolling() {
    _liveDataTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      setState(() {
        _rpm = OBD2.getRPM();
        _coolantTemp = OBD2.getCoolantTemp();
        _speed = OBD2.getSpeed();
        _fuelConsumption = OBD2.getFuelConsumption();
      });
    });
  }

  Future<void> _onFreezeFrameButtonPressed() async {
    if (!_isConnected) return;

    Map<String, String> freezeFrameData = await OBD2.getFreezeFrameData();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Freeze Frame Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                freezeFrameData.entries
                    .map((e) => Text('${e.key}: ${e.value}'))
                    .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onClearDTCButtonPressed() async {
    if (!_isConnected) return;

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Clear DTC Codes'),
            content: Text('Do you want to clear all stored error codes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await OBD2.clearDTC();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DTC codes cleared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildLiveDataWidgets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _liveDataCard('RPM', _rpm?.toStringAsFixed(0) ?? '--'),
        _liveDataCard(
          'Coolant Temp',
          _coolantTemp != null ? '${_coolantTemp!.toStringAsFixed(1)}°C' : '--',
        ),
        _liveDataCard(
          'Speed',
          _speed != null ? '${_speed!.toStringAsFixed(0)} km/h' : '--',
        ),
        _liveDataCard(
          'Fuel Cons.',
          _fuelConsumption != null
              ? '${_fuelConsumption!.toStringAsFixed(1)} L/100km'
              : '--',
        ),
      ],
    );
  }

  Widget _liveDataCard(String label, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 80,
        height: 100,
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticButton(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed:
            _isConnected
                ? () {
                  if (title == 'Freeze Frame') _onFreezeFrameButtonPressed();
                  if (title == 'Clear DTC') _onClearDTCButtonPressed();
                  // Add logic for other buttons later
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(children: [Icon(icon), SizedBox(width: 10), Text(title)]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OBD2 Diagnostics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bluetooth connection card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth_disabled,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _isConnected ? 'Connected' : 'Disconnected',
                          style: TextStyle(
                            fontSize: 16,
                            color: _isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed:
                          _isConnected ? _disconnectOBD2 : _connectToOBD2,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isConnected ? Colors.red : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(_isConnected ? 'Disconnect' : 'Connect'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Vehicle Dropdown
            DropdownButtonFormField<String>(
              value: _selectedVehicle,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                hintText: 'Select Vehicle',
              ),
              items:
                  _vehicles
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
              onChanged: (value) => setState(() => _selectedVehicle = value),
            ),
            SizedBox(height: 20),

            // Live Data
            _buildLiveDataWidgets(),
            SizedBox(height: 20),

            // Diagnostic buttons
            _buildDiagnosticButton('Freeze Frame', Icons.camera_alt),
            _buildDiagnosticButton('Clear DTC', Icons.cleaning_services),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
            );
          else if (index == 1)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MapScreen()),
            );
          else if (index == 3)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ServiceHistorypage()),
            );
          else if (index == 4)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            );
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
