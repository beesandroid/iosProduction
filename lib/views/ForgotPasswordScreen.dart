import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupCodeController = TextEditingController();
  final _userNameController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpSent = false;

  @override
  void dispose() {
    _groupCodeController.dispose();
    _userNameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      final apiUrl =
          'https://mritsexams.com/CoreApi/Flutter/BETStudentInformation';
      final requestBody = {
        "GrpCode": _groupCodeController.text,
        "ColCode": "PSS",
        "CollegeId": "0001",
        "userName": _userNameController.text,
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final studentInfoList = responseBody['betStudentInformationList'];
          if (studentInfoList != null && studentInfoList.isNotEmpty) {
            final studentInfo = studentInfoList[0];
            final mobileNumber = studentInfo['betStudMobile'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('OTP sent to $mobileNumber')),
            );
            await _sendForgotPasswordDetails(mobileNumber);
            setState(() {
              _isOtpSent = true;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No student information found')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch data from server')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _sendForgotPasswordDetails(String mobile) async {
    final apiUrl =
        'https://mritsexams.com/CoreApi/Android/PostForgotPasswordDetails';
    final requestBody = {
      "GrpCode": _groupCodeController.text,
      "ColCode": "PSS",
      "CollegeId": "0001",
      "SchoolId": 1,
      "Username": _userNameController.text,
      "Mobile": mobile,
      "UserType": "2",
      "TemplateSlNo": 1,
      "OTP": "",
      "Email": "",
      "SMSKey": "",
      "SMSPass": "",
      "SMSUser": "",
      "SenderName": "",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(
              groupCode: _groupCodeController.text,
              userName: _userNameController.text,
              onVerified: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewPasswordScreen(
                      username: _userNameController.text,
                      groupCode:
                          _groupCodeController.text, // Pass groupCode here
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.statusCode}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Image.asset(
                  'asset/lock.png', // Path to your custom lock icon
                  color: Colors.black,
                  width: 150,
                  height: 150,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Forgot your password?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Enter your Groupcode and Username to send\nOTP to your registered mobile number",
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _groupCodeController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.group,
                        color: Colors.grey,
                      ),
                      labelText: "Group Code",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your group code';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                      labelText: "User Name",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your user name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                    ),
                    child: const Text(
                      "Send OTP",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerifyOtpScreen extends StatefulWidget {
  final String groupCode;
  final String userName;
  final Function()? onVerified;

  const VerifyOtpScreen({
    required this.groupCode,
    required this.userName,
    this.onVerified,
    Key? key,
  }) : super(key: key);

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final apiUrl =
        'https://mritsexams.com/CoreApi/Android/ForgotPasswordDetailsOTP';
    final requestBody = {
      "GrpCode": widget.groupCode,
      "ColCode": "pss",
      "CollegeId": "0001",
      "UserName": widget.userName,
      "OTP": _otpController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("dd" + responseBody.toString());

        final forgotPasswordDetailsList =
            responseBody['forgotPasswordDetailsList'];
        final singleForgotPasswordDetailsList =
            responseBody['singleForgotPasswordDetailsList'];

        // Accessing oldPassword from forgotPasswordDetailsList
        final oldPasswordFromList = forgotPasswordDetailsList != null &&
                forgotPasswordDetailsList.isNotEmpty
            ? forgotPasswordDetailsList[0]['oldPassword']
            : '';

        // Accessing oldPassword from singleForgotPasswordDetailsList
        final oldPasswordFromSingle = singleForgotPasswordDetailsList != null
            ? singleForgotPasswordDetailsList['oldPassword']
            : '';

        print('Old Password from single: $oldPasswordFromSingle');

        if (forgotPasswordDetailsList.isEmpty &&
            singleForgotPasswordDetailsList['otp'] == null) {
          Fluttertoast.showToast(
            msg: responseBody['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          if (widget.onVerified != null) {
            widget.onVerified!();
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.statusCode}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(
          'Verify OTP',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: Image.asset(
                    'asset/unlock.png', // Path to your custom lock icon
                    width: 100,
                    height: 100,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                  child: Text(
                    "Enter the OTP send to your registered\n Mobile number",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: "    Enter OTP",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen, // Background color
                  ),
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(color: Colors.white), // Text color
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NewPasswordScreen extends StatefulWidget {
  final String username;
  final String groupCode;

  const NewPasswordScreen(
      {required this.username, required this.groupCode, Key? key})
      : super(key: key);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final apiUrl =
        'https://mritsexams.com/CoreApi/Android/StudentLoginChangePassword';
    final requestBody = {
      "GrpCode": widget.groupCode,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": "1",
      "UserId": "1",
      "UserType": "2",
      "UserName": widget.username,
      "OldPassword": "",
      "NewPassword": _passwordController.text,
      "ConfirmPassword": _confirmPasswordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['message'] == "Password Changed Successfuly") {
          Fluttertoast.showToast(
            msg: responseBody['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyApp(),
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: responseBody['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.statusCode}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "    Enter Password",
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: "    Re-enter Password",
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please re-enter your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Implement your logic here
                // For example, you can call a method to handle changing the password
                _changePassword();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                minimumSize: Size(150, 50),
              ),
              child: Text(
                "Change Password",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
