import 'package:flutter/material.dart';
import 'appointments_day_screen.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatelessWidget {
  final List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('EEEE').format(DateTime.now());
    int startIndex = daysOfWeek.indexOf(today);

    List<String> orderedDays = [
      ...daysOfWeek.sublist(startIndex),
      ...daysOfWeek.sublist(0, startIndex),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Appointments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
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
            SizedBox(height: 20),
            Image.asset('images/logo.png', height: 100),
            SizedBox(height: 20),
            Text(
              "Select a day to view appointments",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  orderedDays.map((day) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AppointmentsDayScreen(day: day),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(day, style: TextStyle(fontSize: 18)),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
