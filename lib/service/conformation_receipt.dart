import 'package:dr_cars/service/service_menu.dart';
import 'package:flutter/material.dart';

class RecieptPage extends StatefulWidget {
  final String previousOilChange;
  final String currentMileage;
  final String nextServiceDate;
  final Map<String, bool> servicesSelected;

  const RecieptPage({
    super.key,
    required this.previousOilChange,
    required this.currentMileage,
    required this.nextServiceDate,
    required this.servicesSelected,
  });

  @override
  _RecieptPageState createState() => _RecieptPageState();
}

class _RecieptPageState extends State<RecieptPage> {
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    widget.servicesSelected.forEach((service, selected) {
      if (selected) {
        _priceControllers[service] = TextEditingController();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Vehicle Owner Information",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Home icon button in the right corner
          IconButton(
            icon: const Icon(Icons.home, color: Colors.black),
            onPressed: () {
              // Navigate back to the home screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Service Table
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                // Table Header
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
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
                // Dynamic Rows for Selected Services
                ...widget.servicesSelected.entries
                    .where((entry) => entry.value)
                    .map((entry) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(entry.key),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _priceControllers[entry.key],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Enter Price",
                              ),
                            ),
                          ),
                        ],
                      );
                    })
                    .toList(),
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
                  Map<String, String> finalPrices = {};
                  _priceControllers.forEach((service, controller) {
                    finalPrices[service] = controller.text;
                  });

                  // Display confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Receipt sent successfully with prices: ${finalPrices.toString()}",
                      ),
                    ),
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
