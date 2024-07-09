import 'package:flutter/material.dart';

class feedback extends StatefulWidget {
  const feedback({super.key});

  @override
  State<feedback> createState() => _feedbackState();
}

class _feedbackState extends State<feedback> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Feedback",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Add navigation functionality
          },
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.only(top: 22.0, left: 10, right: 10),
            child: SizedBox(
              height: 220, // Set the height of the Container
              child: TextFormField(
                maxLines: 10, // Allow unlimited number of lines
                keyboardType: TextInputType.multiline, // Enable multiline input
                style: const TextStyle(fontSize: 20), // Increase the font size
                decoration: const InputDecoration(
                  border: OutlineInputBorder(), // Add a border
                ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.only(top: 22.0),
          child: SizedBox(
            width: 220,
            child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightGreen)),
                child: const Text(
                  "Send message",
                  style: TextStyle(color: Colors.white),
                )),
          ),
        )
      ]),
    );
  }
}
