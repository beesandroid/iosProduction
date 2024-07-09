import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'otp.dart';

class NewLogin extends StatefulWidget {
  const NewLogin({Key? key}) : super(key: key);

  @override
  State<NewLogin> createState() => _NewLoginState();
}

class _NewLoginState extends State<NewLogin> {
  TextEditingController grpCode = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  String? groupPhotoUrl;

  final String apiUrlFirst =
      'https://beessoftware.cloud/CoreAPI/Flutter/BETAppRegBeforeOTP';

  final String collegeId = "0001";
  final String collegeCode = "PSS";

  Future<void> fetchDataFirst() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrlFirst),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCode.text,
          "ColCode": collegeCode,
          "CollegeId": collegeId,
          "Mobile": phoneNumber.text,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Check if jsonResponse is an array with exactly one object with specific keys
        if (jsonResponse is List &&
            jsonResponse.length == 1 &&
            jsonResponse[0] is Map<String, dynamic>) {
          final firstObject = jsonResponse[0];
          if (firstObject.containsKey('message') &&
              firstObject['message'] == 'No Mobile Number found' &&
              firstObject.containsKey('status') &&
              firstObject['status'] == 1) {
            final message = firstObject['message'];
            Fluttertoast.showToast(
              msg: message,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              fontSize: 16.0,
            );
            print(message);
            return; // Exit function gracefully since this is a valid scenario
          }
        }

        // Continue with your existing logic for handling other types of responses
        if (jsonResponse.containsKey('value')) {
          final value = jsonResponse['value'];
          if (value != null &&
              value is Map<String, dynamic> &&
              value.containsKey('statusCode') &&
              value.containsKey('status')) {
            if (value['statusCode'] == '200' && value['status'] == true) {
              final otp = value['otp'].toString();
              Fluttertoast.showToast(
                msg: "OTP Sent Successfully! OTP",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                fontSize: 16.0,
              );

              // Navigate to OTP validation screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpValidating(
                    otp: otp,
                    groupCode: grpCode.text,
                    phoneNumber: phoneNumber.text,
                    value: value,
                    userName:
                        value['username'] ?? '', // Pass the entire value object
                  ),
                ),
              );
            } else {
              print(
                  "Unexpected statusCode or status: ${value['statusCode']}, ${value['status']}");
              throw Exception('Unexpected response from server');
            }
          } else {
            print("Invalid response structure: $jsonResponse");
            throw Exception('Failed to load data from first API');
          }
        } else if (jsonResponse is List &&
            jsonResponse.isNotEmpty &&
            jsonResponse[0].containsKey('message')) {
          // Handle the case when no data is found
          final message = jsonResponse[0]['message'];
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0,
          );
          print(message);
        } else {
          print("Invalid response structure: $jsonResponse");
          throw Exception('Failed to load data from first API');
        }
      } else {
        print("Error response: ${response.body}");
        throw Exception('Failed to load data from first API');
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(
        msg: "User already registered!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
  }

  Future<void> fetchGroupPhoto(String groupCode) async {
    final apiUrl = 'https://beessoftware.cloud/CoreApi/Android/GetClgLogo';
    final payload = jsonEncode(
        {"GrpCode": groupCode, "ColCode": "PSS", "CollegeId": "0001"});

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: payload,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("Response: $responseBody");
        setState(() {
          groupPhotoUrl = responseBody['clgList']['clgLogo'];
        });
      } else {
        print(
            'Failed to fetch group photo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch group photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0, bottom: 50),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: ClipOval(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (groupPhotoUrl != null)
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: MemoryImage(
                                          base64Decode(groupPhotoUrl!),
                                        ),
                                        radius: 75,
                                      ),
                                    ),
                                  if (groupPhotoUrl == null)
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        backgroundImage: AssetImage(
                                          "asset/ic_launcher_foreground.png",
                                        ),
                                        radius:
                                            73, // Adjust the radius to include the border width
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      elevation: 8,
                      shadowColor: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: grpCode,
                              decoration: InputDecoration(
                                hintText: "Group Code",
                                prefixIcon:
                                    Icon(Icons.group, color: Colors.grey),
                              ),
                              onChanged: (value) {
                                fetchGroupPhoto(
                                    value); // Fetch image when group code changes
                              },
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: phoneNumber,
                              decoration: InputDecoration(
                                hintText: "Mobile Number",
                                prefixIcon:
                                    Icon(Icons.phone, color: Colors.grey),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                // Limit to 10 characters
                              ],
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                fetchDataFirst();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                              ),
                              child: Text(
                                "Proceed",
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
}

void main() {
  runApp(MaterialApp(
    home: NewLogin(),
  ));
}
