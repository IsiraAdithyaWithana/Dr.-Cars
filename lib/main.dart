import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/Settings.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/rating.dart';
import 'package:dr_cars/interface/servicerecords.dart';
import 'package:dr_cars/main/welcome.dart';
import 'package:dr_cars/service/add_service.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:flutter/material.dart';
import 'main/signin.dart';
import 'package:dr_cars/interface/appointments.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/checkout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Welcome());
  }
}
