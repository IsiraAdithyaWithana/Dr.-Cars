import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceHistoryPage extends StatefulWidget {
  const ServiceHistoryPage({super.key});

  @override
  _ServiceHistoryPageState createState() => _ServiceHistoryPageState();
}

class _ServiceHistoryPageState extends State<ServiceHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> serviceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadServiceHistory();
  }

  Future<void> _loadServiceHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot serviceSnapshot =
            await _firestore
                .collection('Users')
                .doc(user.uid)
                .collection('service_history')
                .orderBy('date', descending: true)
                .get();

        setState(() {
          serviceHistory =
              serviceSnapshot.docs
                  .map(
                    (doc) => {
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    },
                  )
                  .toList();
        });
      }
    } catch (e) {
      print('Error loading service history: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading service history')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service History'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : serviceHistory.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.build_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No service history found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: serviceHistory.length,
                itemBuilder: (context, index) {
                  final service = serviceHistory[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.build_circle, color: Colors.blue),
                      title: Text(service['service_type'] ?? 'Service'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${_formatDate(service['date'])}'),
                          Text('Mileage: ${service['mileage']} km'),
                          if (service['notes'] != null)
                            Text('Notes: ${service['notes']}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new service entry
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add new service - Coming soon')),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      return date.toDate().toString().split(' ')[0];
    }
    return date.toString();
  }
}
