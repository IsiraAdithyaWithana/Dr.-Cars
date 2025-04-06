import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/main/welcome.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future <void> _fetchUserType(user) async {
    try {
        DocumentSnapshot userData =
            await _firestore.collection("Users").doc(user?.uid).get();
        return userData.exists ? userData["User Type"] ?? "User" : "User";
      } catch (e) {
        print("Error fetching user data: $e");
      }
  }

  void _checkUser() async {
    User? user = auth.currentUser;
    // Wait a bit for smooth transition
    await Future.delayed(Duration(seconds: 2));

    Future<void> userType = _fetchUserType(user);

    if (user != null) {
      // User is logged in, go to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => userType == "Vehicle Owner"?DashboardScreen():HomeScreen()),
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

