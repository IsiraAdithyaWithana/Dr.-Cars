import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

int _selectedIndex = 3;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial', // Setting default font
      ),
      home: RatingScreen(),
    );
  }
}

class Review {
  final String name;
  final String date;
  final int rating;
  final String feedback;
  final int helpfulCount;

  Review({
    required this.name,
    required this.date,
    required this.rating,
    required this.feedback,
    required this.helpfulCount,
  });
}

class RatingScreen extends StatefulWidget {
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedRating = 0; // Stores the selected star rating
  final TextEditingController _feedbackController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 void _submitFeedback() async {
  if (_feedbackController.text.isEmpty || _selectedRating == 0) return;

  final feedback = {
    'name': 'Anonymous', // Replace this with actual user info if needed
    'date': DateTime.now().toIso8601String(),
    'rating': _selectedRating,
    'feedback': _feedbackController.text,
    'helpfulCount': 0,
  };

  await _firestore.collection('Feedbacks').add(feedback); // Ensure lowercase 'feedbacks'
  _feedbackController.clear();
  setState(() {
    _selectedRating = 0;
  });
  _showSnackBar();
}

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Submit Review"),
          content: Text("Are you sure you want to submit your feedback?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitFeedback();
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Thank you for your feedback!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  double _calculateAverageRating(List<QueryDocumentSnapshot> feedbacks) {
    if (feedbacks.isEmpty) return 0.0;
    int totalRating = 0;
    for (var feedback in feedbacks) {
      totalRating = feedback['rating'] + totalRating;
    }
    return totalRating / feedbacks.length;
  }

  Map<int, int> _calculateRatingDistribution(List<QueryDocumentSnapshot> feedbacks) {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var feedback in feedbacks) {
      distribution[feedback['rating']] = (distribution[feedback['rating']] ?? 0) + 1;
    }
    return distribution;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: Center(
          child: Text(
            "Reviews",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Share your feedback",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 18),
            Text(
              "How was the service at the service center today?",
              style: TextStyle(fontSize: 19, color: Colors.black87),
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    size: 34,
                    color: _selectedRating > index ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 25),
            Text(
              "Can you tell us more?",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 18),
            TextField(
              controller: _feedbackController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Add feedback",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.black),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showSubmitDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
   Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('Feedbacks').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text("No feedback available"));
      }

      final feedbacks = snapshot.data!.docs;
      final averageRating = _calculateAverageRating(feedbacks);
      // ignore: unused_local_variable
      final ratingDistribution = _calculateRatingDistribution(feedbacks);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Average Rating: ${averageRating.toStringAsFixed(1)}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Total Feedbacks: ${feedbacks.length}",
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index].data() as Map<String, dynamic>? ?? {};

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              feedback['name'] ?? 'Anonymous',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              feedback['date'] ?? '',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: index < (feedback['rating'] ?? 0) ? Colors.orange : Colors.grey,
                            );
                          }),
                        ),
                        SizedBox(height: 8),
                        Text(
                          feedback['feedback'] ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${feedback['helpfulCount'] ?? 0} people found this helpful",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  ),
),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex, // Highlight selected item
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Update selected index
          });

          if (index == 0) { // Navigate when "Home" icon is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          }
          if (index == 4) { // Navigate when "Profile" icon is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
          if (index == 3) { // Navigate when "Review" icon is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RatingScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Image.asset('images/logo.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.rate_review), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}