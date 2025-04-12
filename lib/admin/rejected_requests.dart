import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RejectedRequestsTab extends StatelessWidget {
  const RejectedRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection("ServiceCenterRequests")
              .where("status", isEqualTo: "rejected")
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text("No rejected requests."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              child: ExpansionTile(
                title: Text(data["serviceCenterName"] ?? "Unnamed"),
                subtitle: Text("Owner: ${data["ownerName"] ?? "N/A"}"),
                children: [
                  ListTile(
                    title: const Text("Email"),
                    subtitle: Text(data["email"] ?? "N/A"),
                  ),
                  ListTile(
                    title: const Text("Username"),
                    subtitle: Text(data["username"] ?? "N/A"),
                  ),
                  ListTile(
                    title: const Text("NIC"),
                    subtitle: Text(data["nic"] ?? "N/A"),
                  ),
                  ListTile(
                    title: const Text("Reg. Cert. No"),
                    subtitle: Text(data["regNumber"] ?? "N/A"),
                  ),
                  ListTile(
                    title: const Text("Address"),
                    subtitle: Text(data["address"] ?? "N/A"),
                  ),
                  ListTile(
                    title: const Text("Contact"),
                    subtitle: Text(data["contact"] ?? "N/A"),
                  ),
                  ListTile(
                    title: const Text("Notes"),
                    subtitle: Text(data["notes"] ?? "N/A"),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await _firestore
                              .collection("ServiceCenterRequests")
                              .doc(doc.id)
                              .update({"status": "pending"});
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Moved to pending")),
                            );
                          }
                        },
                        child: const Text("Restore"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          await _firestore
                              .collection("ServiceCenterRequests")
                              .doc(doc.id)
                              .delete();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Deleted request")),
                            );
                          }
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
