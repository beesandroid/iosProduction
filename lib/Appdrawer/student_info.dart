import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class student_profile extends StatefulWidget {
  const student_profile({Key? key}) : super(key: key);

  @override
  State<student_profile> createState() => _student_profileState();
}

class _student_profileState extends State<student_profile> {
  File? _image;
  String? name;
  String? rollNo;
  String? betBatch;
  String? betSem;
  String? dob;
  String? aadharNo;
  String? betStudMobile;
  String? email;
  String? fatherName;
  String? motherName;
  String? mobile;
  String? admissionDate;
  String? imagePath; // Added variable to store image path

  bool _isLoading = true; // Flag to track loading state

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    _fetchProfileData();

// Call function to fetch profile data
    // Call function to fetch dashboard data
    super.initState();
  }

  // Function to fetch profile data
  Future<void> _fetchProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String grpCodeValue = prefs.getString('grpCode') ?? '';
      String userNameValue = prefs.getString('userName') ?? '';

      String apiUrl =
          'https://beessoftware.cloud/CoreAPI/Flutter/BETStudentinformation';
      Map<String, String> requestBody = {
        'grpCode': grpCodeValue,
        'userName': userNameValue,
      };

      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        List<dynamic>? detailsList = responseBody['betStudentInformationList'];

        if (detailsList != null && detailsList.isNotEmpty) {
          Map<String, dynamic> details = detailsList.first;
          setState(() {
            name = details['name'];
            admissionDate = details['admissionDate'];
            rollNo = details['rollNo'];
            betBatch = details['betBatch'];
            betSem = details['betSem'];
            dob = details['dob'];
            aadharNo = details['aadharNo'];
            betStudMobile = details['betStudMobile'];
            email = details['email'];
            fatherName = details['fatherName'];
            motherName = details['motherName'];
            mobile = details['mobile'];
            imagePath = details['imagePath'];
            _isLoading =
                false; // Set loading state to false after data is fetched
          });
        } else {
          print('Empty or null details list');
          setState(() {
            _isLoading =
                false; // Set loading state to false if details list is empty
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        setState(() {
          _isLoading = false; // Set loading state to false if request fails
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false; // Set loading state to false if error occurs
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: _isLoading // Check loading state
          ? Center(
              child:
                  CircularProgressIndicator(), // Show progress indicator while loading
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.0, top: 40),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundImage: imagePath != null
                                ? NetworkImage(imagePath!)
                                : null,
                            child: imagePath == null
                                ? Icon(Icons.person, size: 45)
                                : null,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 22.0),
                        child: Text(
                          name ?? '',
                          style: const TextStyle(color: Colors.black),
                        ), // Use name variable here
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 35.0, top: 25, bottom: 25, right: 35),
                    child: SizedBox(
                      height: 2,
                      width: double.maxFinite,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.black26),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hall ticket number",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(rollNo ?? ''),
                        const Text(
                          "Admission date",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(admissionDate ?? ''),
                        const Text(
                          "batch",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(betBatch ?? ''),
                        const Text(
                          "Semester",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(betSem ?? ''),
                        const Text(
                          "DOB",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(dob ?? ''),
                        const Text(
                          "Aadhaar Number",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(aadharNo ?? ''),
                        const Text(
                          "Mobile Number",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(betStudMobile ?? ''),
                        const Text(
                          "Email Id",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(email ?? ''),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 25, top: 25, bottom: 25, right: 25),
                          child: SizedBox(
                            height: 2,
                            width: double.maxFinite,
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.black26),
                            ),
                          ),
                        ),
                        const Text(
                          "Father Name",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(fatherName ?? ''),
                        const Text(
                          "Mother Name",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Text(motherName ?? ''),
                        const Text(
                          "Parent Mobile number",
                          style: TextStyle(
                              color: Color(0xFFFF9800),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(mobile ?? ''),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: student_profile(),
  ));
}
