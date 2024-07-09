import 'package:flutter/material.dart';

import '../main.dart';

class LastBoardingScreen extends StatefulWidget {
  const LastBoardingScreen({super.key});

  @override
  State<LastBoardingScreen> createState() => _InitialBoardingScreenState();
}

class _InitialBoardingScreenState extends State<LastBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 350,
            width: double.maxFinite,
            decoration: const BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Image.asset(
                'asset/img3.png', // Replace this with your image path
                fit: BoxFit.fitHeight, // Adjust the fit as needed
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 15.0, left: 15),
                        child: Text(
                          "Stay Organized.!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,color: Colors.black,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 15.0, left: 15),
                        child: Text(
                          "Click to create your BETPlus App account and embark on this exciting journey with us!",
                          style: TextStyle(fontSize: 15,color: Colors.black ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 180),
                          child: SizedBox(
                            width: 220,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                                // Text color
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Border radius here
                                ),
                              ),
                              onPressed: () {
                                // Navigate to the second screen when the button is pressed
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyApp()),
                                );
                              },
                              child: const Text(
                                'Get Started',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
