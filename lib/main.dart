import 'package:dr_cars/interface/Service%20History.dart';
import 'package:dr_cars/interface/Settings.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/rating.dart';
import 'package:dr_cars/interface/servicerecords.dart';
import 'package:dr_cars/main/welcome.dart';
import 'package:dr_cars/service/add_service.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main/signin.dart';
import 'package:dr_cars/interface/appointments.dart';
import 'package:dr_cars/interface/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck(), // Auto-redirects user
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    // Wait a bit for smooth transition
    await Future.delayed(Duration(seconds: 2));

    if (user != null) {
      // User is logged in, go to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      // No user, go to Welcome
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Welcome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()), // Show loading
    );
  }
}
