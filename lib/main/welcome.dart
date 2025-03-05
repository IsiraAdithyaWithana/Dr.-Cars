import 'package:dr_cars/main/main_menu.dart';
import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            SizedBox(height: 50),
            Image.asset('images/logo.png', height: 100),
            SizedBox(height: 20),
            Text(
              "Welcome",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainMenu()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Updated property
                foregroundColor: Colors.white, // Updated property
                minimumSize: Size(double.infinity, 50),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Continue", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
