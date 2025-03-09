import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyGarageScreen(),
    );
  }
}

class MyGarageScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cars = [
    {
      'year': 2016,
      'name': 'Focus RS',
      'miles': '4,020',
      'oil': '1,291',
      'image': 'assets/focus_rs.jpg',
    },
    {
      'year': 2017,
      'name': 'Mustang GT',
      'miles': '17,528',
      'oil': '820',
      'image': 'assets/mustang_gt.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Garage',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Container(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(car['image']),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car['year'].toString(),
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            car['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '⚙️ ${car['miles']} MILES',
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                '🛢 ${car['oil']} OIL',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Upcoming maintenance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('2017 Mustang GT'),
                  subtitle: Text('18,348 miles'),
                  trailing: Icon(Icons.check_circle, color: Colors.blue),
                ),
                ListTile(
                  title: Text('2016 Focus RS'),
                  subtitle: Text('5,301 miles'),
                  trailing: Icon(Icons.check_circle, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
