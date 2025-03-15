import 'package:dr_cars/interface/Settings.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/main/signup.dart';
import 'package:dr_cars/main/signup_service.dart';
import 'package:dr_cars/main/temp_fornow.dart';
import 'package:dr_cars/service/service_menu.dart';
import 'package:flutter/material.dart';

class ForNowTemp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('images/bg_removed_logo.png', height: 100),
            SizedBox(height: 20),
            Text(
              'For now Select the account type',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Text('Vehicle Owner'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text('Service Center'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
