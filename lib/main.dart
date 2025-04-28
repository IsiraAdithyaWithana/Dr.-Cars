import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/main/welcome.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/admin/admin_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global notifier to manage theme updates
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Load saved dark mode preference
  final prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
          home: AuthCheck(),
        );
      },
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

  Future<String> _fetchUserType(User user) async {
    try {
      DocumentSnapshot userData =
          await _firestore.collection("Users").doc(user.uid).get();
      return userData.exists ? userData["User Type"] ?? "User" : "User";
    } catch (e) {
      print("Error fetching user type: $e");
      return "User";
    }
  }

  void _checkUser() async {
    User? user = auth.currentUser;
    await Future.delayed(Duration(seconds: 2));

    Widget targetScreen;
    if (user != null) {
      String userType = await _fetchUserType(user);
      if (userType == "Vehicle Owner") {
        targetScreen = DashboardScreen();
      } else if (userType == "Service Center") {
        targetScreen = HomeScreen();
      } else if (userType == "App Admin") {
        targetScreen = const ServiceCenterApprovalPage();
      } else {
        targetScreen = Welcome();
      }
    } else {
      targetScreen = Welcome();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
