import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceInfoScreen extends StatelessWidget {
  final String vehicleNumber;

  const ServiceInfoScreen({super.key, required this.vehicleNumber});

  @override
  Widget build(BuildContext context) {
    final String? serviceCenterUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Service History"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          serviceCenterUid == null
              ? const Center(child: Text("Not logged in"))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Service_Receipts')
                        .where('vehicleNumber', isEqualTo: vehicleNumber)
                        .where('serviceCenterId', isEqualTo: serviceCenterUid)
                        .where('status', isEqualTo: 'done')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No matching service record found."),
                    );
                  }

                  final records = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final data =
                          records[index].data() as Map<String, dynamic>;
                      final services = data['services'] as Map<String, dynamic>;

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Service Date: ${data['createdAt']?.toDate().toString().split(' ')[0] ?? '-'}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Previous Oil Change: ${data['previousOilChange'] ?? '-'}",
                              ),
                              Text(
                                "Next Service Date: ${data['nextServiceDate'] ?? '-'}",
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Services:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              ...services.entries.map(
                                (entry) =>
                                    Text("${entry.key}: Rs. ${entry.value}"),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Current Mileage: ${data['currentMileage'] ?? '-'} km",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
