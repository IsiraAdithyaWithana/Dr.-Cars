/*
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
    // update values every second
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
*/

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OBD-II App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OBD2Page(),
    );
  }
}

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
  List<Map<String, String>> _dtcs = [];
  Timer? _liveDataTimer;
  BluetoothDevice? selectedDevice;
  List<BluetoothDevice> devices = [];
  bool isConnecting = false;
  String connectionStatus = "";
  final BluetoothService btService = BluetoothService();

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
  void initState() {
    super.initState();
    loadDevices();
  }

  void loadDevices() async {
    final bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();
    setState(() {
      devices = bondedDevices;
    });
  }

  Future<void> _connectToOBD2() async {
    if (selectedDevice == null) return;

    setState(() {
      isConnecting = true;
      connectionStatus = "Connecting to ${selectedDevice!.name}...";
    });

    bool success = await btService.connect(selectedDevice!.address);

    setState(() {
      isConnecting = false;
      _isConnected = success;
      connectionStatus =
          success
              ? "Connected to ${selectedDevice!.name}"
              : "Connection failed. Try again.";
    });

    if (success) {
      _startLiveDataPolling();
    }
  }

  void _disconnectOBD2() {
    btService.disconnect();
    _liveDataTimer?.cancel();
    setState(() {
      _isConnected = false;
      _rpm = null;
      _coolantTemp = null;
      _speed = null;
      _dtcs.clear();
    });
  }

  void _clearTroubleCodes() async {
    if (_isConnected) {
      await btService.clearDTCs();
      setState(() {
        _dtcs.clear();
      });
    }
  }

  void _startLiveDataPolling() {
    _liveDataTimer = Timer.periodic(Duration(milliseconds: 500), (_) async {
      final newRpm = await btService.getRPM();
      final newSpeed = await btService.getSpeed();
      final newCoolantTemp = await btService.getCoolantTemp();
      final newDtcs = await btService.getDTCs();
      setState(() {
        _rpm = newRpm.toDouble();
        _speed = newSpeed.toDouble();
        _coolantTemp = newCoolantTemp.toDouble();
        _dtcs =
            newDtcs.map((code) {
              return {
                'code': code,
                'description':
                    btService.dtcDescriptions[code] ?? 'Unknown code',
              };
            }).toList();
      });
    });
  }

  @override
  void dispose() {
    _liveDataTimer?.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OBD2 Diagnostics'),
        backgroundColor: Colors.black,
        actions: [
          // if (_dtcs.isNotEmpty && _isConnected)
          //   IconButton(
          //     icon: Icon(Icons.delete_forever),
          //     tooltip: "Clear Trouble Codes",
          //     onPressed: _clearTroubleCodes,
          //   ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
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
                    if (connectionStatus.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(connectionStatus),
                    ],
                    if (!_isConnected) ...[
                      SizedBox(height: 10),
                      DropdownButton<BluetoothDevice>(
                        hint: const Text("Select Device"),
                        value: selectedDevice,
                        isExpanded: true,
                        onChanged: (BluetoothDevice? value) {
                          setState(() {
                            selectedDevice = value;
                          });
                        },
                        items:
                            devices
                                .map(
                                  (device) => DropdownMenuItem(
                                    value: device,
                                    child: Text(device.name ?? device.address),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _liveDataCard('RPM', _rpm?.toStringAsFixed(0) ?? '--'),
                _liveDataCard(
                  'Coolant Temp',
                  _coolantTemp != null
                      ? '${_coolantTemp!.toStringAsFixed(1)}°C'
                      : '--',
                ),
                _liveDataCard(
                  'Speed',
                  _speed != null ? '${_speed!.toStringAsFixed(0)} km/h' : '--',
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_dtcs.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _dtcs
                        .map(
                          (entry) => ListTile(
                            title: Text("Code: ${entry['code']}"),
                            subtitle: Text(
                              "Description: ${entry['description']}",
                            ),
                          ),
                        )
                        .toList(),
              )
            else
              Text("No trouble codes detected"),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed:
                  _isConnected
                      ? () async {
                        await btService.clearDTCs();
                        setState(() {
                          _dtcs.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Trouble codes cleared successfully.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                      : null,
              icon: Icon(Icons.restart_alt),
              label: Text("Reset Trouble Codes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: (i) {
          if (i == _selectedIndex) return;
          setState(() => _selectedIndex = i);
          Widget target = widget;
          switch (i) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
              break;
            case 1:
              target = MapScreen();
              break;
            case 2:
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
          BottomNavigationBarItem(icon: Icon(Icons.car_repair), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _streamSubscription;
  final _buffer = StringBuffer();
  Completer<String>? _responseCompleter;

  bool get isConnected => _connection != null && _connection!.isConnected;

  Future<bool> connect(String address) async {
    try {
      _connection = await BluetoothConnection.toAddress(address);
      _streamSubscription = _connection!.input!.listen((Uint8List data) {
        final incoming = utf8.decode(data);
        _buffer.write(incoming);

        if (_buffer.toString().contains('>') &&
            _responseCompleter != null &&
            !_responseCompleter!.isCompleted) {
          final fullResponse =
              _buffer
                  .toString()
                  .replaceAll('\r', '')
                  .replaceAll('>', '')
                  .trim();
          _responseCompleter!.complete(fullResponse);
          _buffer.clear();
        }
      });

      _streamSubscription!.onDone(() {
        _connection = null;
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  void disconnect() {
    _streamSubscription?.cancel();
    _connection?.dispose();
    _connection = null;
  }

  void sendCommand(String command) {
    if (_connection != null && _connection!.isConnected) {
      final cmd = "$command\r";
      _connection!.output.add(Uint8List.fromList(utf8.encode(cmd)));
      _connection!.output.allSent;
    }
  }

  Future<String> sendAndRead(String command) async {
    _responseCompleter = Completer<String>();
    sendCommand(command);
    return await _responseCompleter!.future.timeout(
      Duration(seconds: 5),
      onTimeout: () => 'TIMEOUT',
    );
  }

  Future<int> getRPM() async {
    final res = await sendAndRead("010C");
    if (res.length >= 6) {
      try {
        var A = int.parse(res.substring(4, 6), radix: 16);
        var B = int.parse(res.substring(6, 8), radix: 16);
        return ((256 * A) + B) ~/ 4;
      } catch (_) {}
    }
    return 0;
  }

  Future<int> getSpeed() async {
    final res = await sendAndRead("010D");
    if (res.length >= 4) {
      try {
        return int.parse(res.substring(4, 6), radix: 16);
      } catch (_) {}
    }
    return 0;
  }

  Future<int> getCoolantTemp() async {
    final res = await sendAndRead("0105");
    if (res.length >= 4) {
      try {
        return int.parse(res.substring(4, 6), radix: 16) - 40;
      } catch (_) {}
    }
    return 0;
  }

  final Map<String, String> dtcDescriptions = {
    // Engine Management
    'P0100': 'Mass/Volume Air Flow Circuit Malfunction',
    'P0101': 'Mass/Volume Air Flow Circuit Range/Performance',
    'P0102': 'Mass/Volume Air Flow Circuit Low Input',
    'P0103': 'Mass/Volume Air Flow Circuit High Input',
    'P0105': 'Manifold Pressure/Barometric Pressure Circuit Malfunction',
    'P0106': 'Manifold Pressure/Barometric Pressure Range/Performance',
    'P0110': 'Intake Air Temperature Circuit Malfunction',
    'P0115': 'Engine Coolant Temperature Circuit Malfunction',
    'P0120': 'Throttle Position Sensor Circuit Malfunction',
    'P0130': 'O2 Sensor Circuit Malfunction (Bank 1 Sensor 1)',
    'P0135': 'O2 Sensor Heater Circuit Malfunction',
    // Fuel System
    'P0170': 'Fuel Trim Malfunction (Bank 1)',
    'P0171': 'System Too Lean (Bank 1)',
    'P0172': 'System Too Rich (Bank 1)',
    'P0201': 'Injector Circuit Malfunction – Cylinder 1',
    'P0230': 'Fuel Pump Primary Circuit Malfunction',
    'P0261': 'Cylinder 1 Injector Circuit Low',
    'P0262': 'Cylinder 1 Injector Circuit High',
    // Ignition
    'P0300': 'Random/Multiple Cylinder Misfire Detected',
    'P0301': 'Cylinder 1 Misfire Detected',
    'P0325': 'Knock Sensor Circuit Malfunction',
    'P0335': 'Crankshaft Position Sensor Circuit Malfunction',
    'P0340': 'Camshaft Position Sensor Circuit Malfunction',
    'P0350': 'Ignition Coil Primary/Secondary Circuit Malfunction',
    // Emission
    'P0400': 'Exhaust Gas Recirculation Flow Malfunction',
    'P0420': 'Catalyst System Efficiency Below Threshold',
    'P0440': 'Evaporative Emission Control System Malfunction',
    'P0442': 'EVAP System Leak Detected (Small Leak)',
    'P0455': 'EVAP System Leak Detected (Gross Leak)',
    // Transmission
    'P0700': 'Transmission Control System Malfunction',
    'P0705': 'Transmission Range Sensor Circuit Malfunction',
    'P0715': 'Input/Turbine Speed Sensor Circuit Malfunction',
    'P0720': 'Output Speed Sensor Circuit Malfunction',
    'P0730': 'Incorrect Gear Ratio',
    'P0740': 'Torque Converter Clutch Circuit Malfunction',
    // Vehicle Control
    'P0500': 'Vehicle Speed Sensor Malfunction',
    'P0505': 'Idle Control System Malfunction',
    'P0560': 'System Voltage Malfunction',
    'P0600': 'Serial Communication Link Malfunction',
    'P0601': 'Control Module Memory Check Sum Error',
  };

  Future<List<String>> getDTCs() async {
    final res = await sendAndRead("03");
    if (res.length < 4 || res.toLowerCase().contains("no")) return [];

    List<String> dtcs = [];
    try {
      for (int i = 4; i + 3 < res.length; i += 4) {
        String code = res.substring(i, i + 4);
        dtcs.add(_decodeDTC(code));
      }
    } catch (_) {}
    return dtcs;
  }

  Future<void> clearDTCs() async {
    await sendAndRead("04");
  }

  String _decodeDTC(String raw) {
    if (raw.length < 4) return "Invalid";
    final b1 = int.parse(raw.substring(0, 2), radix: 16);
    final b2 = raw.substring(2, 4);
    String type = ['P', 'C', 'B', 'U'][(b1 & 0xC0) >> 6];
    int firstDigit = (b1 & 0x30) >> 4;
    int secondDigit = b1 & 0x0F;
    return '$type$firstDigit${secondDigit.toRadixString(16).toUpperCase()}$b2';
  }
}
