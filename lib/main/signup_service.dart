import 'package:dr_cars/main/signin.dart';
import 'package:flutter/material.dart';

class ServiceCenterRequestScreen extends StatelessWidget {
  const ServiceCenterRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Service Center Account Request"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How to Request a Service Center Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "To request a service center account, please send an email with the following details:",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email To: support@drcars.com",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Subject: Service Center Account Request"),
                  SizedBox(height: 12),
                  Text("Include the following information in your email:"),
                  SizedBox(height: 8),
                  Text("✔ Service Center Name"),
                  Text("✔ Is the service center registered? (Yes/No)"),
                  Text("✔ If registered, attach registration documents"),
                  Text("✔ Service Center Start Date"),
                  Text("✔ Owner/Manager Name"),
                  Text("✔ Contact Number & Email"),
                  Text("✔ Location/Address"),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Once we receive your request, our team will review your details and get back to you within 48 hours.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text("Back to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
