import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServiceCenterApprovalPage extends StatefulWidget {
  const ServiceCenterApprovalPage({super.key});

  @override
  State<ServiceCenterApprovalPage> createState() =>
      _ServiceCenterApprovalPageState();
}

class _ServiceCenterApprovalPageState extends State<ServiceCenterApprovalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> selectedRequestIds = [];

  Future<void> _updateStatus(String status) async {
    for (String docId in selectedRequestIds) {
      await _firestore.collection("ServiceCenterRequests").doc(docId).update({
        "status": status,
        "reviewedAt": FieldValue.serverTimestamp(),
      });

      if (status == "accepted") {
        final request =
            await _firestore
                .collection("ServiceCenterRequests")
                .doc(docId)
                .get();
        final data = request.data();
        if (data != null) {
          await _firestore.collection("Users").add({
            "Name": data["ownerName"],
            "Email": data["email"],
            "Username": data["email"].split("@")[0],
            "Address": data["address"],
            "Contact": data["contact"],
            "User Type": "Service Center",
            "uid": null,
            "createdAt": FieldValue.serverTimestamp(),
          });
        }
      }
    }

    setState(() {
      selectedRequestIds.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Request(s) $status successfully")));
  }

  Widget _buildRequestTile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final docId = doc.id;
    final isSelected = selectedRequestIds.contains(docId);

    return Card(
      child: ExpansionTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedRequestIds.add(docId);
              } else {
                selectedRequestIds.remove(docId);
              }
            });
          },
        ),
        title: Text(data["serviceCenterName"] ?? "Unnamed"),
        subtitle: Text("Owner: ${data["ownerName"] ?? "N/A"}"),
        children: [
          _infoRow("Email", data["email"]),
          _infoRow("NIC", data["nic"]),
          _infoRow("Reg. Cert. No", data["regNumber"]),
          _infoRow("Address", data["address"]),
          _infoRow("Contact", data["contact"]),
          _infoRow("Notes", data["notes"]),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String? value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value?.isNotEmpty == true ? value! : "N/A"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pending Service Center Requests"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection("ServiceCenterRequests")
                .where("status", isEqualTo: "pending")
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return const Center(child: Text("No pending requests."));
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: requests.map(_buildRequestTile).toList(),
          );
        },
      ),
      bottomNavigationBar:
          selectedRequestIds.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus("accepted"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Accept Selected"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateStatus("rejected"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Reject Selected"),
                      ),
                    ),
                  ],
                ),
              )
              : null,
    );
  }
}
