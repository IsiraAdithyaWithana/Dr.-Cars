import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PendingRequestsTab extends StatefulWidget {
  const PendingRequestsTab({super.key});

  @override
  State<PendingRequestsTab> createState() => _PendingRequestsTabState();
}

class _PendingRequestsTabState extends State<PendingRequestsTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> selectedRequestIds = [];
  bool isLoading = false;

  Future<void> _acceptRequests() async {
    setState(() => isLoading = true);

    try {
      for (String docId in selectedRequestIds) {
        final request =
            await _firestore
                .collection("ServiceCenterRequests")
                .doc(docId)
                .get();
        final data = request.data();
        if (data != null) {
          final email = data["email"];

          try {
            UserCredential userCredential = await _auth
                .createUserWithEmailAndPassword(
                  email: email,
                  password: "12346789",
                );

            await _firestore
                .collection("Users")
                .doc(userCredential.user!.uid)
                .set({
                  "Name": data["ownerName"],
                  "Service Center Name": data["serviceCenterName"],
                  "Email": email,
                  "Username": data["username"],
                  "Address": data["address"],
                  "Contact": data["contact"],
                  "User Type": "Service Center",
                  "City": data["city"],
                  "uid": userCredential.user!.uid,
                  "createdAt": FieldValue.serverTimestamp(),
                });

            await _firestore
                .collection("ServiceCenterRequests")
                .doc(docId)
                .delete();
          } on FirebaseAuthException catch (e) {
            if (e.code == 'email-already-in-use') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Email already in use for $email.')),
              );
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
            }
          }
        }
      }
    } finally {
      setState(() {
        selectedRequestIds.clear();
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Accepted request(s)")));
      }
    }
  }

  Future<void> _rejectRequests() async {
    for (String docId in selectedRequestIds) {
      await _firestore.collection("ServiceCenterRequests").doc(docId).update({
        "status": "rejected",
      });
    }

    if (mounted) {
      setState(() => selectedRequestIds.clear());
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Rejected request(s)")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children:
                    requests.map((doc) {
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
                          subtitle: Text(
                            "Owner: ${data["ownerName"] ?? "N/A"}",
                          ),
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
                              title: const Text("City"),
                              subtitle: Text(data["city"] ?? "N/A"),
                            ),
                            ListTile(
                              title: const Text("Notes"),
                              subtitle: Text(data["notes"] ?? "N/A"),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            if (selectedRequestIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () async {
                                  setState(() => isLoading = true);
                                  await _acceptRequests();
                                  if (mounted)
                                    setState(() => isLoading = false);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text("Accept"),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () async {
                                  setState(() => isLoading = true);
                                  await _rejectRequests();
                                  if (mounted)
                                    setState(() => isLoading = false);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text("Reject"),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
