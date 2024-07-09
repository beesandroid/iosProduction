import 'package:flutter/material.dart';
import 'Initial.dart';
import 'Last.dart';
import 'Primary.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: const [
                InitialBoardingScreen(),
                PrimaryBoardingScreen(),
                LastBoardingScreen(),
                // Add more pages as needed
              ],
            ),
          ),
          _buildBottomIndicator(),
        ],
      ),
    );
  }

  Widget _buildBottomIndicator() {
    return SizedBox(
      height: 50,
      width: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          3, // Change this to the number of pages/screens you have
          (index) => _buildIndicator(index),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return SizedBox(
      width: 20,
      child: Icon(
        Icons.circle,
        size: 12,
        color: index == _currentPageIndex ? Colors.lightGreen : Colors.grey,
      ),
    );
  }
}
