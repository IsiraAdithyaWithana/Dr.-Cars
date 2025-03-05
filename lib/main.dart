import 'package:dr_cars/interface/Service%20History.dart';
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
      home:ServiceRecordsPage(),
=======
      home: ServiceHistorypage(),
>>>>>>> 82ea51047be8e469c5e19b29120a26fef581ca58
    );
  }
}
