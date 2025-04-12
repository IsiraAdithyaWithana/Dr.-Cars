import 'package:dr_cars/admin/pending_requests.dart';
import 'package:dr_cars/admin/rejected_requests.dart';
import 'package:dr_cars/main/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceCenterApprovalPage extends StatelessWidget {
  const ServiceCenterApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Service Center Requests"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [Tab(text: 'Pending'), Tab(text: 'Rejected')],
          ),
        ),
        body: const TabBarView(
          children: [PendingRequestsTab(), RejectedRequestsTab()],
        ),
      ),
    );
  }
}
