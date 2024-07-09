import 'dart:convert';

import 'package:betplus_ios/views/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class OtpValidating extends StatelessWidget {
  final String otp;
  final String groupCode;
  final String phoneNumber;
  final Map<String, dynamic> value;
  final String userName;

  const OtpValidating({
    Key? key,
    required this.otp,
    required this.groupCode,
    required this.phoneNumber,
    required this.value,
    required this.userName,
  }) : super(key: key);

  Widget build(BuildContext context) {
    TextEditingController otpController = TextEditingController();

    return Scaffold(
      body:
      Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 400, // Adjust the height as needed
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    SizedBox(
                      width: 150, // Increase the width
                      height: 150, // Increase the height
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: ClipOval(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                // Increase the height
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white,
                                      width: 2), // Add white border
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    "asset/ic_launcher_foreground.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Add some space at the top
                    // Add some space between the text and the text field
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child:

                                TextField(
                                  controller: otpController,
                                  decoration: InputDecoration(
                                    hintText: "Enter OTP",
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        'asset/otp.png',
                                        height: 24, // Adjust height as needed
                                        width: 24, // Adjust width as needed
                                        color: Colors.black,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(6), // Limit input to 6 characters
                                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            // Add space between the text field and the button
                            ElevatedButton(
                              onPressed: () {
                                final enteredOTP = otpController.text;
                                _verifyOTP(context, enteredOTP);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                                minimumSize: Size(150, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: Text(
                                "Submit",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOTP(BuildContext context, String enteredOTP) async {
    try {
      String apiUrl =
          'https://beessoftware.cloud/CoreAPI/Android/VerifyStudentDetailsForRegistration';
      Map<String, dynamic> requestBody = {
        'GrpCode': groupCode,
        'ColCode': 'PSS',
        'CollegeId': '0001',
        'UserName': value['username'], // Use value['username'] directly
        'Mobile': phoneNumber,
        'UserType': '2',
        'Flag': '0',
      };
      print(requestBody);

      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print(response.body);
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response: ${responseBody.toString()}");
        if (responseBody['status'] == 0) {

          // Check if entered OTP matches received OTP
          if (enteredOTP == otp) {
            // Navigate to the next screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUp(
                  grpCode: groupCode,
                  phoneNumber: phoneNumber,
                  userName: value['username'], // Pass the username here
                ),
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: "Incorrect OTP. Please try again.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "Please enter valid OTP !  ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to verify OTP. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to verify OTP. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
