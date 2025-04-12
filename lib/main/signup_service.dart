import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServiceCenterRequestScreen extends StatefulWidget {
  const ServiceCenterRequestScreen({super.key});

  @override
  State<ServiceCenterRequestScreen> createState() =>
      _ServiceCenterRequestScreenState();
}

class _ServiceCenterRequestScreenState
    extends State<ServiceCenterRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _centerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _regCertController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _isSubmitting = false;

  Future<bool> _checkDuplicate(String field, String value) async {
    final users =
        await FirebaseFirestore.instance
            .collection("Users")
            .where(field, isEqualTo: value)
            .get();

    if (users.docs.isNotEmpty) return true;

    final requests =
        await FirebaseFirestore.instance
            .collection("ServiceCenterRequests")
            .where(field, isEqualTo: value)
            .get();

    return requests.docs.isNotEmpty;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();

    setState(() {
      _isSubmitting = true;
    });

    final emailExists = await _checkDuplicate("Email", email);
    final usernameExists = await _checkDuplicate("Username", username);

    if (emailExists) {
      _showError("This email address is already in use.");
      return;
    }

    if (usernameExists) {
      _showError("This username is already in use.");
      return;
    }

    try {
      await FirebaseFirestore.instance.collection("ServiceCenterRequests").add({
        "serviceCenterName": _centerNameController.text.trim(),
        "email": email,
        "ownerName": _ownerNameController.text.trim(),
        "nic": _nicController.text.trim(),
        "regNumber": _regCertController.text.trim(),
        "address": _addressController.text.trim(),
        "contact": _contactController.text.trim(),
        "notes": _notesController.text.trim(),
        "username": username,
        "status": "pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Request Submitted"),
              content: const Text(
                "Your request has been submitted. Please wait while the app admin reviews and approves your service center account. Check the 'Check service center availability!! option frequently'",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
      );

      _formKey.currentState!.reset();
    } catch (e) {
      _showError("Submission failed: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showError(String message) {
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool requiredField = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) {
          if (requiredField && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Center Account Request"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                label: "Service Center Name",
                controller: _centerNameController,
              ),
              _buildTextField(
                label: "E-mail Address",
                controller: _emailController,
              ),
              _buildTextField(
                label: "Username",
                controller: _usernameController,
              ),
              _buildTextField(
                label: "Owner Name",
                controller: _ownerNameController,
              ),
              _buildTextField(label: "NIC Number", controller: _nicController),
              _buildTextField(
                label: "Registration Certificate Number",
                controller: _regCertController,
              ),
              _buildTextField(
                label: "Service Center Address",
                controller: _addressController,
              ),
              _buildTextField(
                label: "Contact Information",
                controller: _contactController,
              ),
              _buildTextField(
                label: "Additional Notes",
                controller: _notesController,
                maxLines: 3,
                requiredField: false,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit Request"),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Home"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
