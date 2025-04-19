import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReceiptNotificationPage extends StatefulWidget {
  const ReceiptNotificationPage({super.key});

  @override
  State<ReceiptNotificationPage> createState() =>
      _ReceiptNotificationPageState();
}

class _ReceiptNotificationPageState extends State<ReceiptNotificationPage> {
  String? vehicleNumber;

  @override
  void initState() {
    super.initState();
    _loadVehicleNumber();
  }

  Future<void> _loadVehicleNumber() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final vehicleDoc =
          await FirebaseFirestore.instance.collection('Vehicle').doc(uid).get();
      if (vehicleDoc.exists) {
        setState(() {
          vehicleNumber = vehicleDoc['vehicleNumber'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vehicleNumber == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Receipts"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('Pending_Receipts')
                .where('vehicleNumber', isEqualTo: vehicleNumber)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending receipts found."));
          }

          final receipts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index].data() as Map<String, dynamic>;
              final services = receipt['services'] as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ExpansionTile(
                  title: Text("Receipt ${index + 1}"),
                  subtitle: Text("Mileage: ${receipt['currentMileage']}"),
                  children: [
                    ListTile(
                      title: const Text("Previous Oil Change"),
                      subtitle: Text(receipt['previousOilChange']),
                    ),
                    ListTile(
                      title: const Text("Next Service Date"),
                      subtitle: Text(receipt['nextServiceDate']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        "Services:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...services.entries.map(
                      (entry) => ListTile(
                        title: Text(entry.key),
                        trailing: Text("Rs. ${entry.value}"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("Pending_Receipts")
                              .doc(receipts[index].id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Receipt confirmed and removed"),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Confirm Receipt"),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
