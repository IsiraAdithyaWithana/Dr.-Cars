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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: AuthCheck());
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

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

  Future<String> _fetchUserType(User? user) async {
    if (user == null) return "User";
    try {
      DocumentSnapshot userData =
          await _firestore.collection("users").doc(user.uid).get();
      return userData.exists ? userData.get("userType") ?? "User" : "User";
    } catch (e) {
      print("Error fetching user data: $e");
      return "User";
    }
  }

  void _checkUser() async {
    User? user = auth.currentUser;
    // Wait a bit for smooth transition
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (user != null) {
      String userType = await _fetchUserType(user);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  userType == "Vehicle Owner"
                      ? const DashboardScreen()
                      : const HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Welcome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
