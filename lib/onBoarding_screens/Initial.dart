import 'package:flutter/material.dart';

class InitialBoardingScreen extends StatefulWidget {
  const InitialBoardingScreen({super.key});

  @override
  State<InitialBoardingScreen> createState() => _InitialBoardingScreenState();
}

class _InitialBoardingScreenState extends State<InitialBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                'asset/img1.png', // Replace this with your image path
                fit: BoxFit.fitHeight, // Adjust the fit as needed
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, left: 15),
                        child: Text(
                          "Welcome to BETPlus.!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, left: 15),
                        child: Text(
                          "We are thrilled to have you on board! BETPlus is your new examination companion, "
                          "designed to make your journey smoother and more successful.",
                          style: TextStyle(fontSize: 15),
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
