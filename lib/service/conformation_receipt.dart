import 'package:flutter/material.dart';

class RecieptPage extends StatelessWidget {
  // Example data for services and prices
  final List<Map<String, String>> services = [
    {"service": "Oil Changing with 5W-15", "price": "1500"},
    {"service": "Air Filter Replacement", "price": "500"},
    {"service": "Brake Fluid Replacement", "price": "800"},
  ];

  const RecieptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Conformation Receipt",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Table for Services and Prices
            Table(
              border: TableBorder.all(), // Add borders to the table
              columnWidths: const {
                0: FlexColumnWidth(2), // Service column width
                1: FlexColumnWidth(1), // Price column width
              },
              children: [
                // Table Header
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Header background color
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Service",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Price (Rs.)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                // Table Rows (Dynamic Data)
                for (var service in services)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(service["service"]!),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(service["price"]!),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Send Receipt Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  // Add functionality to send the receipt
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Receipt sent successfully!")),
                  );
                },
                child: const Text(
                  "Send the receipt",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
