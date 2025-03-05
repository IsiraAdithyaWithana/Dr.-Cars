import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // this one is for awsome fonts

class ServiceHistorypage extends StatelessWidget {
  const ServiceHistorypage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service History'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Term
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Term',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20),

            // Filter Options
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Service Type',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.filter_alt),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Service Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Service Cost',
                      border: OutlineInputBorder(),
                      prefixText: 'Rs.',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Record Details Section
            Expanded(
              child: ListView(
                children: [
                  ServiceRecordCard(
                    date: '12-02-2025',
                    mileage: '50,000 KM',
                    provider: 'ABC Auto Service',
                    cost: 'Rs. 3500',
                    notes: 'Regular oil change',
                  ),
                  // You can duplicate or dynamically generate more cards here.
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.compass), // font awsome commpass icon
            label: 'map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'User',
          ),
        ],
      ),
    );
  }
}

class ServiceRecordCard extends StatelessWidget {
  final String date;
  final String mileage;
  final String provider;
  final String cost;
  final String notes;

  const ServiceRecordCard({
    required this.date,
    required this.mileage,
    required this.provider,
    required this.cost,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: $date', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Mileage: $mileage'),
            SizedBox(height: 10),
            Text('Service Provider: $provider'),
            SizedBox(height: 10),
            Text('Service Cost: $cost'),
            SizedBox(height: 10),
            Text('Additional Notes: $notes'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // View action here
                  },
                  child: Text('View Invoice'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Download action here
                  },
                  icon: Icon(Icons.download),
                  label: Text('Download'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
