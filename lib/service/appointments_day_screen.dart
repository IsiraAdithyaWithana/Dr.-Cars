import 'package:flutter/material.dart';
import '../main/main_menu.dart';

class AppointmentsDayScreen extends StatelessWidget {
  final String day;

  const AppointmentsDayScreen({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    String displayDay = day;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Appointments for $displayDay",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          // Add a home icon button in the right corner
          IconButton(
            icon: Icon(Icons.home, color: Colors.black), // Home icon
            onPressed: () {
              // Navigate back to the home screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainMenu()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayDay,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                AppointmentSlot(time: "9:00 A.M - 12:00 P.M"),
                AppointmentSlot(time: "12:00 P.M - 3:00 P.M"),
                AppointmentSlot(time: "3:00 P.M - 6:00 P.M"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenu()),
                      (route) => false,
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
                  child: Text("Home", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentSlot extends StatelessWidget {
  final String time;

  const AppointmentSlot({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ...List.generate(
              4,
              (index) => ListTile(
                title: Text("[Vehicle Number], Contact number"),
                trailing: Checkbox(value: false, onChanged: (val) {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
