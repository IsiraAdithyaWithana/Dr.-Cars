import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/Settings.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/servicerecords.dart';
import 'package:dr_cars/main/welcome.dart';
import 'package:flutter/material.dart';
import 'main/signin.dart';
import 'package:dr_cars/interface/appointments.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'interface/rating.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(debugShowCheckedModeBanner: false, home: RatingScreen());
=======
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppointmentsPage(),
    );
>>>>>>> bf20c2045111d51cf3598ac6e34a127fc982aaf9
  }
}
