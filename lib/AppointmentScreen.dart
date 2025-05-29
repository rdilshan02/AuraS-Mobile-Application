import 'package:flutter/material.dart';

void main() => runApp(MyAppointmentsApp());

class MyAppointmentsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyAppointmentsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyAppointmentsPage extends StatelessWidget {
  final List<Map<String, String>> appointments = [
    {
      "name": "Dr.Adithya",
      "date": "21 May",
      "time": "4.00 p.m.",
      "image": "assets/images/doc1.png"
    },
    {
      "name": "Dr.Arachchige",
      "date": "24 May",
      "time": "6.00 p.m.",
      "image": "assets/images/doc2.png"
    },
    {
      "name": "Dr.Smith",
      "date": "30 May",
      "time": "3.00 p.m.",
      "image": "assets/images/doc3.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            SizedBox(width: 8),
            Text("AuraS",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child:
                CircleAvatar(backgroundImage: AssetImage('assets/images/profile.png')),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navigation bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                navItem("Home", false),
                navItem("AI Analysis", false),
                navItem("Chat Bot", false),
                navItem("Doctor Channelling", true),
                navItem("Blog", false),
              ],
            ),
          ),
          SizedBox(height: 10),

          // My Appointments Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.pink[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("My Appointments",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Spacer(),
                Icon(Icons.arrow_back, color: Colors.pink[300]),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Appointment List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final doctor = appointments[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFF00332F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(doctor['image']!),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor['name']!,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(doctor['date']!,
                                      style: TextStyle(color: Colors.white)),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(doctor['time']!,
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text("Start Now"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          decoration:
              isSelected ? TextDecoration.underline : TextDecoration.none,
          color: Colors.black,
        ),
      ),
    );
  }
}
