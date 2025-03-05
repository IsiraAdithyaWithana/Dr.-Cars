import 'package:flutter/material.dart';
import 'interface/signin.dart';
import 'interface/Service History.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SignInScreen());
  }
}
