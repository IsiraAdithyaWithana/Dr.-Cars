import 'package:dr_cars/interface/Service History.dart';
import 'package:dr_cars/interface/servicerecords.dart';
import 'package:flutter/material.dart';
import 'interface/Settings.dart';
import 'main/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
<<<<<<< HEAD
      title: 'Vehicle Service App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Welcome(),
=======
      home: SettingsScreen(),
>>>>>>> db63c74cd9a2edd1aa41b001ffc40a10aace2652
    );
  }
}
