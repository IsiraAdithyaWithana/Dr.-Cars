import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? selectedPaymentMethod;
  double serviceCost = 50.00; // Example base service cost
  double taxRate = 0.08; // 8% tax rate

  @override
  Widget build(BuildContext context) {
    double taxAmount = serviceCost * taxRate;
    double totalAmount = serviceCost + taxAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Service Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),
            _buildSummaryRow("Vehicle Model", "Car"),
            _buildSummaryRow("Service Type", "Full Service"),
            _buildSummaryRow("Branch", "Colombo"),
            _buildSummaryRow("Date", "March 20, 2025"),
            _buildSummaryRow("Time", "10:00 AM"),
            
            const SizedBox(height: 20),
            const Text('Cost Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildSummaryRow("Service Cost", "\$${serviceCost.toStringAsFixed(2)}"),
            _buildSummaryRow("Tax (8%)", "\$${taxAmount.toStringAsFixed(2)}"),
            _buildSummaryRow("Total", "\$${totalAmount.toStringAsFixed(2)}", isBold: true),

            const SizedBox(height: 20),
            const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
            _buildPaymentOption("Credit Card"),
            _buildPaymentOption("PayPal"),
            _buildPaymentOption("Cash"),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: selectedPaymentMethod == null ? null : () {
                  _showConfirmationDialog();
                },
                child: const Text('Confirm & Pay', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method) {
    return ListTile(
      title: Text(method),
      leading: Radio<String>(
        value: method,
        groupValue: selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            selectedPaymentMethod = value;
          });
        },
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Confirmed'),
          content: Text('Your payment of \$${(serviceCost + (serviceCost * taxRate)).toStringAsFixed(2)} has been processed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
