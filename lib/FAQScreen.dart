import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auras FAQ',
      debugShowCheckedModeBanner: false,
      home: const FAQPage(),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  final List<String> faqItems = const [
    "Usr Manual",
    "Early Detection Makes a Difference",
    "How is Machine Learning used  for this?",
    "What is AI Dermatologist?",
    "Who should use AI Dermatologist?",
    "Does AI Dermatologist replace the Doctor?",
    "Is my personal information safe?",
    "How to use?",
    "How to take photo?",
    "How to save results?",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6), // light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset('assets/images/logo.png'), // Replace with your logo
        ),
        title: const Text(
          'Auras',
          style: TextStyle(
            fontFamily: 'Avenir',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              // Handle menu toggle
            },
          ),
          const CircleAvatar(
            backgroundImage: AssetImage(
                'assets/images/profile.jpg'), // Replace with your profile image
            radius: 16,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey.shade300,
            child: const Center(
              child: Text(
                'FAQ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: faqItems.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFFFFF6F6), // light pinkish
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14),
                    child: Text(
                      faqItems[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
