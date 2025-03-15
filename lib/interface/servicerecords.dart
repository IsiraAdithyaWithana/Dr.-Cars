import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:dr_cars/interface/rating.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: ServiceRecordsPage()),
  );
}

int _selectedIndex = 0;

class ServiceRecordsPage extends StatelessWidget {
  const ServiceRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Records'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Mileage
              Text(
                'Current Mileage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixText: 'KM',
                ),
              ),
              SizedBox(height: 10),

              // Type of Service
              Text(
                'Type of Service',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              SizedBox(height: 10),

              // Date of Service
              Text(
                'Date of service',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 10),

              // Mileage
              Text('Mileage', style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixText: 'KM',
                ),
              ),
              SizedBox(height: 10),

              // Service Provider
              Text(
                'Service Provider',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),

              // Service Cost
              Text(
                'Service Cost',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixText: 'Rs.',
                ),
              ),
              SizedBox(height: 10),

              // Additional Notes
              Text(
                'Additional Notes',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),

              // Upload Invoice
              Text('Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.upload),
                label: Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
         bottomNavigationBar: BottomNavigationBar(
         selectedItemColor: Colors.red,
         unselectedItemColor: Colors.black,
         currentIndex: _selectedIndex, // Highlight selected item
         onTap: (index) {
         (() {
         _selectedIndex = index; // Update selected index
          });

         if (index == 0) { // Navigate when "User" icon is clicked
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }
     if (index == 4) { // Navigate when "User" icon is clicked
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }
     if (index == 3) { // Navigate when "User" icon is clicked
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RatingScreen()),
      );
    }
  },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
       
      ),
    );
  }
}
