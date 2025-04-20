import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String? serviceCenterUid;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        serviceCenterUid = user.uid;
      });
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue is Timestamp) {
      return dateValue.toDate().toString().split(' ')[0];
    } else if (dateValue is String) {
      return dateValue.split('T').first;
    } else {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Appointments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  selectedDate = null;
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            serviceCenterUid == null
                ? null
                : FirebaseFirestore.instance
                    .collection('appointments')
                    .where('serviceCenterUid', isEqualTo: serviceCenterUid)
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),

        builder: (context, snapshot) {
          if (serviceCenterUid == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No appointments available."));
          }

          final rawAppointments = snapshot.data!.docs;

          final sortedAppointments =
              rawAppointments..sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                DateTime aDate =
                    aData['timestamp'] is Timestamp
                        ? (aData['timestamp'] as Timestamp).toDate()
                        : DateTime.tryParse(aData['timestamp'].toString()) ??
                            DateTime(2000);

                DateTime bDate =
                    bData['timestamp'] is Timestamp
                        ? (bData['timestamp'] as Timestamp).toDate()
                        : DateTime.tryParse(bData['timestamp'].toString()) ??
                            DateTime(2000);

                return aDate.compareTo(bDate);
              });

          final appointments =
              selectedDate == null
                  ? sortedAppointments
                  : sortedAppointments.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    DateTime docDate;
                    if (data['date'] is String) {
                      docDate =
                          DateTime.tryParse(data['date']) ?? DateTime(2000);
                    } else if (data['date'] is Timestamp) {
                      docDate = (data['date'] as Timestamp).toDate();
                    } else {
                      return false;
                    }
                    return docDate.year == selectedDate!.year &&
                        docDate.month == selectedDate!.month &&
                        docDate.day == selectedDate!.day;
                  }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final doc = appointments[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Vehicle No: ${data['vehicleNumber'] ?? '-'}"),
                      Text("Contact: ${data['Contact'] ?? '-'}"),
                      Text("Model: ${data['vehicleModel'] ?? '-'}"),
                      Text("Date: ${_formatDate(data['date'])}"),
                      Text("Time: ${data['time'] ?? '-'}"),
                      Text("Status: ${data['status'] ?? 'Pending'}"),
                      const SizedBox(height: 8),
                      Text(
                        "Service Types: ${(data['serviceTypes'] ?? []).join(', ')}",
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(doc.id)
                                  .update({'status': 'accepted'});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Accept"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(doc.id)
                                  .update({'status': 'rejected'});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Reject"),
                          ),
                        ],
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
