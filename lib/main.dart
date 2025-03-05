import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/servicerecords.dart';
import 'package:flutter/material.dart';
import 'interface/Settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ServiceRecordsPage(),
    );
  }
}
