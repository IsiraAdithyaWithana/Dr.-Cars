import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppointmentNotificationPage extends StatefulWidget {
  const AppointmentNotificationPage({super.key});

  @override
  State<AppointmentNotificationPage> createState() =>
      _AppointmentNotificationPageState();
}

class _AppointmentNotificationPageState
    extends State<AppointmentNotificationPage> {
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Appointment Notifications"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('appointments')
                      .where('vehicleNumber', isEqualTo: vehicleNumber)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }

                final docs = snapshot.data!.docs;

                final pending =
                    docs
                        .where(
                          (doc) =>
                              (doc.data() as Map<String, dynamic>)['status'] ==
                              'pending',
                        )
                        .length;

                final accepted =
                    docs
                        .where(
                          (doc) =>
                              (doc.data() as Map<String, dynamic>)['status'] ==
                              'accepted',
                        )
                        .length;

                final rejected =
                    docs
                        .where(
                          (doc) =>
                              (doc.data() as Map<String, dynamic>)['status'] ==
                              'rejected',
                        )
                        .length;

                Widget tabLabel(String label, int count) => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label),
                      if (count > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
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
                  ),
                );

                return TabBar(
                  tabs: [
                    tabLabel("Pending", pending),
                    tabLabel("Accepted", accepted),
                    tabLabel("Rejected", rejected),
                  ],
                  labelColor: Colors.amber,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.amber,
                );
              },
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentList("pending"),
            _buildAppointmentList("accepted"),
            _buildAppointmentList("rejected"),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('appointments')
              .where('vehicleNumber', isEqualTo: vehicleNumber)
              .where('status', isEqualTo: status)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No $status appointments found."));
        }

        final appointments = snapshot.data!.docs;

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final doc = appointments[index];
            final appointment = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Model: ${appointment['vehicleModel'] ?? '-'}"),
                    Text(
                      "Date: ${appointment['date']?.toString().split('T').first ?? '-'}",
                    ),
                    Text("Time: ${appointment['time'] ?? '-'}"),
                    Text("Status: ${appointment['status'] ?? '-'}"),
                    const SizedBox(height: 6),
                    Text(
                      "Services: ${(appointment['serviceTypes'] as List).join(', ')}",
                    ),
                    const SizedBox(height: 12),
                    if (status == 'pending') ...[
                      ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('appointments')
                              .doc(doc.id)
                              .delete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Cancel Appointment"),
                      ),
                    ] else if (status == 'accepted') ...[
                      ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('appointments')
                              .doc(doc.id)
                              .delete();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Handed Over Vehicle"),
                      ),
                    ] else if (status == 'rejected') ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(doc.id)
                                    .update({'status': 'pending'});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Resend Appointment"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('appointments')
                                    .doc(doc.id)
                                    .delete();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Delete"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
