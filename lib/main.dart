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
// COLOR CONSTANTS
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

  OneSignal.initialize("fd5e46c1-2563-4dd9-8b53-931517023f89");

  final prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _baseTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final fillColor = isDark ? Colors.grey[850] : Colors.grey[100];
    final labelColor = isDark ? Colors.white70 : Colors.black87;
    final hintColor = Colors.grey;

    return ThemeData(
      brightness: brightness,
      primaryColor: kAppBarColor,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: kAppBarColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAccentOrange, width: 2),
        ),
        hintStyle: TextStyle(color: hintColor),
        labelStyle: TextStyle(color: labelColor),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kAccentOrange, width: 2),
          ),
          hintStyle: TextStyle(color: hintColor),
          labelStyle: TextStyle(color: labelColor),
        ),
        textStyle: TextStyle(color: labelColor, fontSize: 14),
        menuStyle: MenuStyle(
          backgroundColor: MaterialStatePropertyAll(fillColor),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>(
          (states) =>
              states.contains(MaterialState.selected)
                  ? kAccentOrange
                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        ),
        trackColor: MaterialStateProperty.resolveWith<Color>(
          (states) =>
              states.contains(MaterialState.selected)
                  ? kAccentOrange.withOpacity(0.5)
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAppBarColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: labelColor),
        headlineSmall: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      colorScheme: ColorScheme.fromSwatch(
        brightness: brightness,
      ).copyWith(secondary: kAccentOrange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _baseTheme(Brightness.light),
          darkTheme: _baseTheme(Brightness.dark),
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
