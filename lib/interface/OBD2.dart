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
    _selectedIndex = 2;
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
    _liveDataTimer = Timer.periodic(Duration(milliseconds: 1500), (_) async {
      final newRpm = await btService.getRPM();
      final newSpeed = await btService.getSpeed();
      final newCoolantTemp = await btService.getCoolantTemp();
      final newDtcs = await btService.getDTCs();

      setState(() {
        _rpm = (newRpm > 0 && newRpm < 10000) ? newRpm.toDouble() : 0.0;
        _speed = (newSpeed >= 0 && newSpeed < 300) ? newSpeed.toDouble() : 0.0;
        _coolantTemp =
            (newCoolantTemp >= -40 && newCoolantTemp < 150)
                ? newCoolantTemp.toDouble()
                : null;

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
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                value,
                key: ValueKey(value), // Important for triggering animation
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
          //     onPressed: _clearTroubleCodes,`
          //   ),`
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
                        await btService.clearDTCs(); // ✅ fixed line
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
    final response = await _responseCompleter!.future.timeout(
      Duration(seconds: 5),
      onTimeout: () => 'TIMEOUT',
    );
    if (response.trim().isEmpty || response == 'TIMEOUT') return '';
    return response;
  }

  Future<int> getRPM() async {
    final res = await sendAndRead("010C");
    print("RPM Raw: $res");

    // Match valid RPM response like "41 0C 1A F8"
    final match = RegExp(
      r'41\s0C\s([0-9A-Fa-f]{2})\s([0-9A-Fa-f]{2})',
    ).firstMatch(res);
    if (match != null) {
      try {
        final A = int.parse(match.group(1)!, radix: 16);
        final B = int.parse(match.group(2)!, radix: 16);
        final rpm = ((256 * A) + B) ~/ 4;

        // Optional: Clamp out-of-range or fake values
        if (rpm < 50 || rpm > 8000) {
          return 0; // assume engine is off
        }
        return rpm;
      } catch (e) {
        print("RPM parse error: $e");
      }
    }

    // Fallback: invalid data or car off
    return 0;
  }

  Future<int> getSpeed() async {
    final res = await sendAndRead("010D");
    print("Speed Raw: $res");

    final match = RegExp(r'41\s0D\s([0-9A-Fa-f]{2})').firstMatch(res);
    if (match != null) {
      return int.parse(match.group(1)!, radix: 16);
    }
    return 0;
  }

  Future<int> getCoolantTemp() async {
    final res = await sendAndRead("0105");
    print("Coolant Raw: $res");

    final match = RegExp(r'41\s05\s([0-9A-Fa-f]{2})').firstMatch(res);
    if (match != null) {
      return int.parse(match.group(1)!, radix: 16) - 40;
    }
    return 0;
  }

  final Map<String, String> dtcDescriptions = {
    // Engine Management & Timing (Includes cam/crank sensors, VVT, valves)
    'P0008': 'Engine Position System Misalignment Bank 1',
    'P0009': 'Engine Position System Variation Bank 2',
    'P0010': 'Camshaft Position Actuator “A” Circuit Malfunction (Bank 1)',
    'P0011': 'Camshaft “A” Timing Problem',
    'P0012': 'Camshaft “A” Over‑Retarded (Bank 1)',
    'P0013': 'VVT Solenoid/Actuator Circuit Worn',
    'P0014': 'Camshaft “B” Over‑Advanced (Bank 1)',
    'P0015': 'Camshaft “B” Over‑Retarded (PCM)',
    'P0016': 'Crank–Cam Correlation Bank 1 Sensor A',
    'P0017': 'Camshaft and Crankshaft Correlation Issue',
    'P0018': 'Crank–Cam Correlation Bank 2 Sensor A',
    'P0019': 'Crank–Cam Correlation Bank 2 Sensor B',
    'P0020': 'Camshaft Position Actuator “A” Circuit (Bank 2)',
    'P0021': 'Incorrect Camshaft Variable Timing Solenoid',
    'P0022': 'Camshaft “A” Timing Issue',
    'P0023': 'Camshaft Position Actuator “B” Circuit',
    'P0024': 'Camshaft “B” Over‑Advanced Timing',
    'P0025': 'Camshaft “B” Over‑Retarded Timing',
    'P0026': 'Intake Valve Control Solenoid Circuit Malfunction',
    'P0027': 'Exhaust Valve Control Solenoid Circuit Problem',
    'P0028': 'Intake Valve Control Malfunction (Bank 2)',
    'P0029': 'Exhaust Valve Control Range/Performance',
    'P0335': 'Crankshaft Position Sensor “A” Circuit Malfunction',
    'P0340': 'Camshaft Position Sensor Circuit Malfunction',
    'P0341': 'Camshaft Position Sensor “A” Circuit Range/Performance (Bank 1)',
    'P06DE': 'Engine Oil Pressure Control Circuit Stuck On',

    // Fuel System & Pressure / Injectors
    'P0001': 'Fuel Volume Regulator Control Circuit/Open',
    'P0002': 'Fuel Volume Regulator Range/Performance',
    'P0003': 'Fuel Volume Regulator Low Circuit',
    'P0004': 'Fuel Volume Regulator High Circuit',
    'P0005': 'Fuel Shutoff Valve “A” Open Circuit',
    'P0006': 'Fuel Shutoff Valve “A” Low Circuit',
    'P0007': 'Fuel Shutoff Valve “A” High Circuit',
    'P0087': 'Fuel Rail/System Low Pressure',
    'P0088': 'Fuel Rail/System High Pressure',
    'P0089': 'Fuel Pressure Regulator 1 Problem',
    'P0090': 'Fuel Pressure Regulator 1 Control Circuit Malfunction',
    'P0091': 'Fuel Pressure Regulator 1 Low Voltage Circuit',
    'P0092': 'Fuel Pressure Regulator 1 High Voltage Circuit',
    'P0093': 'Large Fuel System Leak Detected',
    'P0094': 'Small Fuel System Leak Detected',
    'P0148': 'Fuel Pressure Too Low or High',
    'P0149': 'Fuel Timing Sequence Problem',
    'P0611': 'Fuel Injector Control Module Performance Down',
    'P2148': 'Fuel Injector Group “A” Supply Voltage High',

    // Air Intake, MAF, MAP, Throttle & Sensors
    'P0065': 'Air‑Assisted Injector Control Solenoid Valve Problem',
    'P0066': 'Air‑Assisted Injector Control Circuit Low',
    'P0067': 'Air‑Assisted Injector Control Circuit High Voltage',
    'P0068': 'MAP/MAF–Throttle Position Mismatch',
    'P0069': 'MAP–Barometric Pressure Mismatch',
    'P0100': 'Mass Air Flow Circuit Malfunction',
    'P0101': 'Mass Air Flow Circuit Range/Performance',
    'P0102': 'MAF Low Input',
    'P0103': 'MAF High Input',
    'P0104': 'MAF “A” Circuit Intermittent',
    'P0105': 'MAP/Barometric Pressure Circuit Malfunction',
    'P0106': 'MAP/Barometric Pressure Range/Performance',
    'P0107': 'MAP Low Input',
    'P0108': 'MAP High Input',
    'P0109': 'MAP, BPC Not Continuous',
    'P0110': 'Intake Air Temp Sensor 1 Circuit Malfunction (Bank 1)',
    'P0111': 'Intake Air Temp 1 Range/Performance Mismatch',
    'P0112': 'Intake Air Temp 1 Voltage Too Low',
    'P0113': 'Intake Air Temperature Sensor Problem',
    'P0114': 'Intake Air Temperature Sensor 1 Bank 1 Malfunction',
    'P0115': 'Engine Coolant Temperature Circuit Malfunction',
    'P0116': 'ECT Range Incorrect',
    'P0117': 'ECT Low Voltage Output',
    'P0118': 'ECT High Voltage Output',
    'P0119': 'ECT Sensor 1 Malfunction',
    'P0120': 'Throttle/Pedal Position Sensor “A” Circuit Malfunction',
    'P0121': 'Throttle/Pedal Position Sensor “A” Range/Performance',
    'P0122': 'Throttle/Pedal Position “A” Low Voltage',
    'P0123': 'Throttle/Pedal Position “A” High Voltage',
    'P0124': 'Throttle/Pedal Position “A” Out of Range',
    'P0125': 'Engine Not Reaching Proper Temperature',
    'P0126': 'Low Coolant Temp or Bad Thermostat',
    'P0127': 'High Intake Air Temperature',
    'P0128': 'Engine Temperature Not Staying Hot Enough',
    'P0129': 'Barometric Pressure Too Low',

    // Turbocharger / Supercharger & Boost Control
    'P0033': 'Turbocharger Bypass Valve Control Circuit',
    'P0034': 'Turbocharger Bypass Valve Low Voltage',
    'P0035': 'Turbocharger Bypass Valve High Voltage',
    'P0039': 'Turbo/Supercharger Bypass Valve Circuit Malfunction',
    'P0045': 'Turbo/Supercharger Boost Control Solenoid/Open',
    'P0046': 'Turbo/Supercharger Boost Solenoid Range/Performance',
    'P0047': 'Turbo/Supercharger Boost Low Voltage',
    'P0048': 'Turbo/Supercharger Boost High Voltage',
    'P0049': 'Turbo/Supercharger Turbine Overspeed',
    'P0234': 'Turbocharger/Supercharger “A” Overboost Condition',
    'P0299': 'Turbo or Supercharger Underperformance',
    'P012B': 'Turbo/Supercharger Inlet Pressure Sensor Issue',

    // Oxygen (O2/HO2S) & NOx Sensors
    'P0030': 'Primary HO2S Heater Control Circuit Malfunction',
    'P0031': 'HO2S Heater Low Voltage (B1S1)',
    'P0032': 'HO2S Heater High Voltage (B1S1)',
    'P0036': 'HO2S Heater Control Malfunction (B1S2)',
    'P0037': 'Bank 1 Sensor 2 Oxygen Sensor Heater Issue',
    'P0038': 'HO2S Heater High Voltage (B1S2)',
    'P0040': 'O2 Sensor Signals Swapped B1S1/B2S1',
    'P0041': 'O2 Sensor Issue Bank 1 S2 / Bank 2 S2',
    'P0042': 'HO2S Heater Circuit (B1S3)',
    'P0043': 'HO2S Heater Low Voltage (B1S3)',
    'P0044': 'HO2S Heater High Voltage (B1S3)',
    'P0050': 'HO2S Heater Control Malfunction (B2S1)',
    'P0051': 'HO2S Heater Low Voltage (B2S1)',
    'P0052': 'HO2S Heater High Voltage (B2S1)',
    'P0053': 'HO2S Heater Resistance (B1S1)',
    'P0054': 'HO2S Heater Resistance (B1S2)',
    'P0055': 'HO2S Heater Resistance (B1S3)',
    'P0056': 'HO2S Heater Circuit (B2S2)',
    'P0057': 'HO2S Heater Low Voltage (B2S2)',
    'P0058': 'HO2S Heater High Voltage (B2S2)',
    'P0059': 'HO2S Heater Resistance (B2S1)',
    'P0060': 'HO2S Heater Resistance (B2S2)',
    'P0061': 'HO2S Heater Resistance (B2S3)',
    'P0062': 'HO2S Heater Circuit (B2S3)',
    'P0063': 'HO2S Heater Low Voltage (B2S3)',
    'P0064': 'HO2S Heater High Voltage (B2S3)',
    'P0130': 'O2 Sensor Circuit Malfunction (B1S1)',
    'P0131': 'O2 Sensor Low Voltage (B1S1)',
    'P0132': 'O2 Sensor High Voltage (B1S1)',
    'P0133': 'O2 Sensor Slow Response (B1S1)',
    'P0134': 'O2 Sensor Stops Working (B1S1)',
    'P0135': 'O2 Sensor Heater Circuit Malfunction',
    'P0136': 'O2 Sensor Circuit Malfunction (B1S2)',
    'P0137': 'O2 Sensor Low Voltage (B1S2)',
    'P0138': 'O2 Sensor High Voltage (B1S2)',
    'P0139': 'O2 Sensor Slow Response (B1S2)',
    'P0140': 'O2 Sensor Not Working',
    'P0141': 'O2 Sensor Heater Circuit Faulty',
    'P0142': 'O2 Sensor Circuit (B1S3)',
    'P0143': 'O2 Sensor Low Voltage (B1S3)',
    'P0144': 'O2 Sensor High Voltage (B1S3)',
    'P0145': 'O2 Sensor Slow Response (B1S3)',
    'P0146': 'O2 Sensor Not Responding (B1S3)',
    'P0147': 'O2 Heater Circuit Malfunction (B1S3)',
    'P0150': 'O2 Sensor Circuit Malfunction (B2S1)',
    'P0151': 'O2 Sensor Low Voltage (B2S1)',
    'P0161': 'O2 Sensor Circuit Malfunction (B2S2)',
    'P2209': 'NOx Sensor Heater Circuit Range/Performance',

    // Air‑Fuel Ratio / Fuel Trim Imbalance
    'P0171': 'System Too Lean (Bank 1)',
    'P0172': 'System Too Rich (Bank 1)',
    'P2188': 'System Too Rich at Idle (Bank 1)',

    // Misfire / Ignition
    'P0300': 'Random/Multiple Cylinder Misfire Detected',
    'P0316': 'Misfire Detected on Startup',

    // Emission & EVAP / EGR / Secondary Air
    'P0401': 'EGR Flow Insufficient',
    'P0440': 'EVAP System Malfunction',
    'P0442': 'EVAP Small Leak Detected',
    'P0446': 'EVAP Vent Control Circuit Issue',
    'P0452': 'EVAP Low Pressure',
    'P0455': 'EVAP Gross Leak Detected',
    'P0456': 'EVAP Leak Detected',
    'P2257': 'Secondary Air Injection Control “A” Low Circuit',
    'P2448': 'Secondary Air Injection High Air Flow (Bank 1)',

    // Transmission & Drivetrain
    'P0700': 'Transmission Control System Malfunction',
    'P0733': 'Incorrect Gear Ratio – 3rd Gear',

    // Brake & Vehicle Control
    'P0504': 'Brake Switch “A”/”B” Correlation',
    'P2299': 'Brake Pedal Position Incorrect',

    // Reductant / DEF & Exhaust Temp
    'P2047': 'Reductant Injection Valve Circuit/Open Issue',
    'P242B': 'Exhaust Gas Temperature Sensor Range/Performance (B1S3)',
    'P246F': 'Exhaust Gas Temperature Sensor Bank 1 Sensor 4',
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

    final type = ['P', 'C', 'B', 'U'][(b1 & 0xC0) >> 6];
    final digit1 = ((b1 & 0x30) >> 4).toString();
    final digit2 = (b1 & 0x0F).toRadixString(16).toUpperCase();

    return '$type$digit1$digit2$b2';
  }
}
