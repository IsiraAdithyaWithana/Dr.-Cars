import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServiceReceiptsPage extends StatelessWidget {
  const ServiceReceiptsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("All Service Receipts"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [Tab(text: "Confirmed"), Tab(text: "Rejected")],
          ),
        ),

        body: TabBarView(
          children: [
            _buildReceiptList("confirmed"),
            _buildReceiptList("rejected"),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Service_Receipts')
              .where('status', isEqualTo: status)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No $status receipts found."));
        }

        final receipts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: receipts.length,
          itemBuilder: (context, index) {
            final receipt = receipts[index].data() as Map<String, dynamic>;
            final services = receipt['services'] as Map<String, dynamic>;
            final docId = receipts[index].id;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ExpansionTile(
                title: Text(
                  "Receipt ${index + 1} - ${receipt['vehicleNumber']}",
                ),
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
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
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
                  if (status == "confirmed")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("Service_Receipts")
                              .doc(docId)
                              .update({"status": "finished"});

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Service marked as finished."),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Finish"),
                      ),
                    )
                  else if (status == "rejected")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("Service_Receipts")
                              .doc(docId)
                              .delete();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Rejected receipt deleted."),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Done"),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
