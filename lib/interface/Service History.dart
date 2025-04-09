import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

int _selectedIndex = 3;

class ServiceHistorypage extends StatefulWidget {
  const ServiceHistorypage({super.key});

  @override
  State<ServiceHistorypage> createState() => _ServiceHistorypageState();
}

class _ServiceHistorypageState extends State<ServiceHistorypage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _serviceRecords = [];
  bool _isLoading = true;

  final List<String> _serviceTypes = [
    'Oil Filter Change',
    'Air Filter Change',
    'Battery Performance Check',
    'Brake Inspection',
    'Coolant Change/Check',
    'Tyre Pressure Check',
  ];

  @override
  void initState() {
    super.initState();
    _loadServiceRecords();
  }

  Future<void> _loadServiceRecords() async {
    setState(() => _isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('service_records')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .get();

        setState(() {
          _serviceRecords = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading service records: $e");
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getFilteredRecords() {
    return _serviceRecords.where((record) {
      bool matchesSearch = true;
      bool matchesFilter = true;
      bool matchesDate = true;

      if (_searchController.text.isNotEmpty) {
        matchesSearch = record['serviceProvider']
            .toString()
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }

      if (_selectedFilter != null) {
        matchesFilter = record['serviceType'] == _selectedFilter;
      }

      if (_selectedDate != null) {
        DateTime recordDate = (record['date'] as Timestamp).toDate();
        matchesDate = recordDate.year == _selectedDate!.year &&
            recordDate.month == _selectedDate!.month &&
            recordDate.day == _selectedDate!.day;
      }

      return matchesSearch && matchesFilter && matchesDate;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Service Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Service Type', record['serviceType']),
              _buildDetailRow('Date', (record['date'] as Timestamp).toDate().toString().split(' ')[0]),
              _buildDetailRow('Current Mileage', '${record['currentMileage']} KM'),
              _buildDetailRow('Service Mileage', '${record['serviceMileage']} KM'),
              _buildDetailRow('Service Provider', record['serviceProvider']),
              if (record['serviceType'] == 'Oil Filter Change')
                _buildDetailRow('Oil Type', record['oilType']),
              if (record['notes'] != null && record['notes'].isNotEmpty)
                _buildDetailRow('Notes', record['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Service History', 
        style: TextStyle(
          fontSize: 24 , 
          fontWeight: FontWeight.bold,
          color: Colors.white,
          ),
          ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by service provider',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(height: 20),

            // Filter Section
            Text(
              'Filter',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedFilter,
                        hint: Text(
                          'Select Service Type',
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                        items: _serviceTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilter = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: TextStyle(color: Colors.grey[800]),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Record Details
            const Text(
              'Record Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _getFilteredRecords().isEmpty
                      ? const Center(
                          child: Text('No service records found'),
                        )
                      : ListView.builder(
                          itemCount: _getFilteredRecords().length,
                          itemBuilder: (context, index) {
                            final record = _getFilteredRecords()[index];
                            return GestureDetector(
                              onTap: () => _showRecordDetails(record),
                              child: ServiceRecordCard(
                                date: (record['date'] as Timestamp)
                                    .toDate()
                                    .toString()
                                    .split(' ')[0],
                                mileage: record['serviceMileage'].toString(),
                                provider: record['serviceProvider'],
                                serviceType: record['serviceType'],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
          else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          }
          else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ServiceHistorypage()),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 24),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 24),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: '',
          ),
        ],
      ),
    );
  }
}

class ServiceRecordCard extends StatelessWidget {
  final String date;
  final String mileage;
  final String provider;
  final String serviceType;

  const ServiceRecordCard({
    super.key,
    required this.date,
    required this.mileage,
    required this.provider,
    required this.serviceType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                serviceType,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$mileage KM',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            provider,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
