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

  Tab _buildTabWithBadge(String label, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
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

  int _calculateTotal(Map<String, dynamic> services) {
    int total = 0;
    services.forEach((key, value) {
      try {
        total += int.tryParse(value.toString()) ?? 0;
      } catch (_) {}
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (vehicleNumber == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Receipt Notifications"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Service_Receipts')
                      .where('vehicleNumber', isEqualTo: vehicleNumber)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }

                final docs = snapshot.data!.docs;
                final counts = {
                  'not confirmed': 0,
                  'confirmed': 0,
                  'rejected': 0,
                  'finished': 0,
                };

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'];
                  if (counts.containsKey(status)) {
                    counts[status] = counts[status]! + 1;
                  }
                }

                return TabBar(
                  isScrollable: true,
                  labelColor: Colors.amber,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.amber,
                  tabs: [
                    _buildTabWithBadge("Pending", counts['not confirmed']!),
                    _buildTabWithBadge("Confirmed", counts['confirmed']!),
                    _buildTabWithBadge("Rejected", counts['rejected']!),
                    _buildTabWithBadge("Finished", counts['finished']!),
                  ],
                );
              },
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildReceiptList("not confirmed", true),
            _buildReceiptList("confirmed", false),
            _buildReceiptList("rejected", false),
            _buildReceiptList("finished", false),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptList(String status, bool showActions) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Service_Receipts')
              .where('vehicleNumber', isEqualTo: vehicleNumber)
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

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ExpansionTile(
                title: Text(
                  "Receipt ${index + 1}: ${receipts[index]['Service Center Name']}",
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
                  ...services.entries
                      .map(
                        (entry) => ListTile(
                          title: Text(entry.key),
                          trailing: Text("Rs. ${entry.value}"),
                        ),
                      )
                      .toList(),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          "Total: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Rs. ${_calculateTotal(services)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showActions)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("Service_Receipts")
                                  .doc(receipts[index].id)
                                  .update({"status": "confirmed"});

                              if (mounted) {
                                Future.microtask(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Receipt confirmed."),
                                    ),
                                  );
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Confirm"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection("Service_Receipts")
                                  .doc(receipts[index].id)
                                  .update({"status": "rejected"});

                              if (mounted) {
                                Future.microtask(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Receipt rejected."),
                                    ),
                                  );
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
                    )
                  else if (status == "finished")
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection("Service_Receipts")
                              .doc(receipts[index].id)
                              .update({"status": "done"});

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Marked as done.")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
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
