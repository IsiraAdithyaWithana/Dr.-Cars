import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceCenterRequestScreen extends StatelessWidget {
  const ServiceCenterRequestScreen({super.key});

  final String formUrl =
      "https://docs.google.com/forms/d/e/1FAIpQLSdvL3gHgFMdLvtMs5luSlnVLcaRFFcMs0GIvj_8pyrb83mgog/viewform?usp=header";

  Future<void> _openForm() async {
    final Uri url = Uri.parse(
      "https://docs.google.com/forms/d/e/1FAIpQLSdvL3gHgFMdLvtMs5luSlnVLcaRFFcMs0GIvj_8pyrb83mgog/viewform?usp=header",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch URL");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Center Account Request"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How to Request a Service Center Account",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please fill out the following Google Form to request a service center account. Ensure that you provide accurate information and upload necessary documents.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("✔ Service Center Name"),
                  Text("✔ Registered or Not?"),
                  Text("✔ If registered, upload your registration certificate"),
                  Text("✔ Service Center Start Date"),
                  Text("✔ Contact Information (Phone & Email)"),
                  Text("✔ Service Center Address"),
                  Text("✔ Services Provided"),
                  Text("✔ Additional Notes (Optional)"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _openForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("Open Google Form"),
            ),
            const SizedBox(height: 24),
            const Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "By submitting this form, you agree that we will securely store your provided information, including any uploaded documents, for verification purposes. Your data will only be used for processing your request and will not be shared with third parties without your consent.",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text("Back to Home"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
