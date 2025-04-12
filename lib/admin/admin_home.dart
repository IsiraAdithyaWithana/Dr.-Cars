import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main/welcome.dart';

class ServiceCenterApprovalPage extends StatefulWidget {
  const ServiceCenterApprovalPage({super.key});

  @override
  State<ServiceCenterApprovalPage> createState() =>
      _ServiceCenterApprovalPageState();
}

class _ServiceCenterApprovalPageState extends State<ServiceCenterApprovalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> selectedRequestIds = [];

  Future<void> _acceptRequests() async {
    for (String docId in selectedRequestIds) {
      final request =
          await _firestore.collection("ServiceCenterRequests").doc(docId).get();
      final data = request.data();
      if (data != null) {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: data["email"],
              password: "12346789",
            );

        await _firestore.collection("Users").doc(userCredential.user!.uid).set({
          "Name": data["ownerName"],
          "Email": data["email"],
          "Username": data["username"],
          "Address": data["address"],
          "Contact": data["contact"],
          "User Type": "Service Center",
          "uid": userCredential.user!.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });

        await _firestore
            .collection("ServiceCenterRequests")
            .doc(docId)
            .delete();

        await _auth.sendPasswordResetEmail(email: data["email"]);
      }
    }

    if (mounted) {
      setState(() {
        selectedRequestIds.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Accepted request(s) and sent email")),
      );
    }
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
        ],
      ),
    );
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Welcome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Pending Service Center Requests"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
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
                child: ElevatedButton(
                  onPressed: _acceptRequests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Accept and Send Email"),
                ),
              )
              : null,
    );
  }
}
