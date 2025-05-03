import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/main/welcome.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/admin/admin_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// ------------------------------------------------------------------
// COLOR CONSTANTS — used everywhere
// ------------------------------------------------------------------
const Color kAppBarColor = Colors.black;
const Color kAccentOrange = Color.fromARGB(255, 255, 99, 32);
const Color kBlueTint = Colors.blue;
const Color kVehicleCardBg = Color(0xFFFAF7F7);
const Color kErrorRed = Colors.red;
const Color kIconBgOpacityBlue = Color.fromRGBO(0, 0, 255, .1);

// ------------------------------------------------------------------
// GLOBAL THEME NOTIFIER
// ------------------------------------------------------------------
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // OneSignal initialization (no assignment needed)
  OneSignal.initialize("fd5e46c1-2563-4dd9-8b53-931517023f89");

  final prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _lightTheme() => ThemeData(
    brightness: Brightness.light,
    primaryColor: kAppBarColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: kAppBarColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>(
        (states) =>
            states.contains(MaterialState.selected)
                ? kAccentOrange
                : Colors.grey.shade400,
      ),
      trackColor: MaterialStateProperty.resolveWith<Color>(
        (states) =>
            states.contains(MaterialState.selected)
                ? kAccentOrange.withOpacity(0.5)
                : Colors.grey.shade300,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAppBarColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      headlineSmall: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: kAccentOrange),
  );

  ThemeData _darkTheme() => ThemeData(
    brightness: Brightness.dark,
    primaryColor: kAppBarColor,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: kAppBarColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>(
        (states) =>
            states.contains(MaterialState.selected)
                ? kAccentOrange
                : Colors.grey.shade600,
      ),
      trackColor: MaterialStateProperty.resolveWith<Color>(
        (states) =>
            states.contains(MaterialState.selected)
                ? kAccentOrange.withOpacity(0.5)
                : Colors.grey.shade800,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAppBarColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      headlineSmall: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
    ).copyWith(secondary: kAccentOrange),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          themeMode: mode,
          home: const AuthCheck(),
        );
      },
    );
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

  Future<String> _fetchUserType(User user) async {
    try {
      final doc = await _firestore.collection("Users").doc(user.uid).get();
      return doc.exists ? (doc["User Type"] ?? "User") : "User";
    } catch (_) {
      return "User";
    }
  }

  Future<void> _checkUser() async {
    final user = auth.currentUser;
    await Future.delayed(const Duration(seconds: 2));
    Widget screen = const Welcome();

    if (user != null) {
      final type = await _fetchUserType(user);
      if (type == "Vehicle Owner") {
        screen = const DashboardScreen();
      } else if (type == "Service Center") {
        screen = const HomeScreen();
      } else if (type == "App Admin") {
        screen = const ServiceCenterApprovalPage();
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
