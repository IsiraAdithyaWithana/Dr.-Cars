import 'package:dr_cars/interface/dashboard.dart';
import 'package:dr_cars/interface/mapscreen.dart';
import 'package:dr_cars/interface/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      theme: ThemeData(fontFamily: 'Arial'),
      home: RatingScreen(),
    );
  }
}

class RatingScreen extends StatefulWidget {
  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _submitFeedback() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to submit feedback"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_feedbackController.text.isEmpty || _selectedRating == 0) return;

    final feedback = {
      'name': user.displayName ?? 'Anonymous',
      'userId': user.uid,
      'date': DateTime.now().toString(),
      'rating': _selectedRating,
      'feedback': _feedbackController.text,
      'helpfulCount': 0,
    };

    await _firestore.collection('Feedbacks').add(feedback);

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
              onPressed: () => Navigator.of(context).pop(),
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
      int rating = (feedback['rating'] ?? 0);
      totalRating += rating;
    }
    
    return totalRating / feedbacks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Center(
          child: Text("Reviews", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Share your feedback", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 18),
            Text("How was the service at the service center today?", style: TextStyle(fontSize: 19, color: Colors.black87)),
            SizedBox(height: 18),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(Icons.star, size: 34, color: _selectedRating > index ? Colors.orange : Colors.grey),
                  onPressed: () => setState(() => _selectedRating = index + 1),
                );
              }),
            ),
            SizedBox(height: 25),
            TextField(
              controller: _feedbackController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Add feedback",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
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
                    child: Text("Cancel",
                     style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      )),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showSubmitDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: Text("Submit",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      )),
                    
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Average Rating: ${averageRating.toStringAsFixed(1)}",
                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
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
                            final feedback = feedbacks[index].data() as Map<String, dynamic>;

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
                                        Text(feedback['name'] ?? 'Anonymous', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text(feedback['date'] ?? '', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(Icons.star, color: index < (feedback['rating'] ?? 0) ? Colors.orange : Colors.grey);
                                      }),
                                    ),
                                    SizedBox(height: 8),
                                    Text(feedback['feedback'] ?? '', style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 8),
                                    Text("${feedback['helpfulCount'] ?? 0} people found this helpful", style: TextStyle(fontSize: 14, color: Colors.grey)),
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

           if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
          } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RatingScreen()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        }
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: ''),
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
