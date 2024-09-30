import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../webview_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({
    Key? key,
    required this.grpCode,
    required this.phoneNumber,
    required this.userName,
  }) : super(key: key);

  final String grpCode;
  final String phoneNumber;
  final String userName;

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController retype = TextEditingController();
  bool showText = false;
  String fee = '';
  bool isButtonEnabled = false;
  bool isFormValid = false;
  bool isEmailValid = false;
  bool isPasswordValid = false;
  bool isRetypePasswordValid = false;
  bool obscureTextPassword = true;
  bool obscureTextRetype = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      String apiUrl =
          'https://mritsexams.com/CoreApi/Android/RegistrationFeeDisplay';
      Map<String, dynamic> requestBody = {
        'GrpCode': widget.grpCode,
        'CollegeId': '0001',
        'ColCode': 'PSS',
        'SchoolId': '1',
        'AdmnNo': widget.userName,
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
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody.toString());

        if (responseBody['singlRegistrationFeeDisplayList'] != null &&
            responseBody['singlRegistrationFeeDisplayList']['status'] == 0) {
          setState(() {
            showText = true;
            fee = responseBody['singlRegistrationFeeDisplayList']
                    ['registrationFee']
                .toString();
            print("ffffffff" + fee);
          });
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> register() async {
    try {
      String emailValue = email.text;
      String passwordValue = password.text;
      String retypeValue = retype.text;

      if (passwordValue != retypeValue) {
        showToast("Password mismatch.", context: context);
        return;
      }

      String apiUrl =
          'https://mritsexams.com/CoreApi/Android/AndroidOnlineBilldeskPaymentProcess';
      Map<String, dynamic> requestBody = {
        'grpCode': widget.grpCode,
        'colCode': 'PSS',
        'collegeId': '0001',
        'adminNo': widget.userName,
        'regfee': fee,
        'email': emailValue,
        'password': passwordValue,
        'userType': 2,
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

        String rdata = responseBody['links'] != null &&
                responseBody['links'].length >= 2 &&
                responseBody['links'][1]['parameters'] != null
            ? responseBody['links'][1]['parameters']['rdata']
            : '';

        String bdorderid = responseBody['bdorderid'] ?? '';
        String orderid = responseBody['orderid'] ?? '';
        String mercid = responseBody['mercid'] ?? '';

        await callSecondAPI(bdorderid, mercid, orderid);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              initialUrl: '',
              bdorderid: bdorderid,
              mercid: mercid,
              rdata: rdata,
            ),
          ),
        );
      } else {
        showToast("Failed to register. Please try again.", context: context);
      }
    } catch (e) {
      print('Error: $e');
      showToast("An error occurred. Please try again later.", context: context);
    }
  }

  Future<void> callSecondAPI(
      String bdorderid, String mercid, String orderid) async {
    try {
      String emailValue = email.text.trim();
      String pass = password.text.trim();
      String apiUrl =
          'https://mritsexams.com/CoreApi/Android/BilldeskPaymentLogs';
      Map<String, dynamic> requestBody = {
        'mercId': mercid,
        'orderId': orderid,
        'transactionDate': DateTime.now().toIso8601String(),
        'amount': fee,
        'grpCode': widget.grpCode,
        'colCode': 'pss',
        'collegeId': '0001',
        'username': widget.userName,
        'email': emailValue,
        'password': pass,
        'userType': '2',
      };
      print(requestBody);

      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 204) {
        print("Second API call successful.");
      } else {
        print("Second API call failed.");
      }
    } catch (e) {
      print('Error in second API call: $e');
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
              height: 400,
              decoration: BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 58.0, bottom: 55),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Image.asset("asset/ic_launcher_foreground.png"),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 22),
                    child: Material(
                      elevation: 5,
                      shadowColor: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: TextFormField(
                                    controller: email,
                                    decoration: InputDecoration(
                                      icon: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          Icons.email,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      labelText: "Email",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        Fluttertoast.showToast(
                                          msg: "Please enter your email",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          fontSize: 16.0,
                                        );
                                        return null;
                                      }
                                      final RegExp emailRegex = RegExp(
                                        r'^[^@]+@[^@]+\.[^@]+$',
                                      );
                                      if (!emailRegex.hasMatch(value)) {
                                        Fluttertoast.showToast(
                                          msg: "Please enter a valid email",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          fontSize: 16.0,
                                        );
                                        return null;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: TextFormField(
                                    controller: password,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: obscureTextPassword,
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscureTextPassword =
                                                !obscureTextPassword;
                                          });
                                        },
                                        icon: Icon(
                                          obscureTextPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      icon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.lock,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        Fluttertoast.showToast(
                                          msg: "Please enter your password",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          fontSize: 16.0,
                                        );
                                        return null;
                                      } else if (value.length < 8) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "Password must be at least 8 characters",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          fontSize: 16.0,
                                        );
                                        return null;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: TextFormField(
                                      controller: retype,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      obscureText: obscureTextRetype,
                                      decoration: InputDecoration(
                                        icon: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            Icons.lock,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        labelText: "Retype Password",
                                        labelStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obscureTextRetype =
                                                  !obscureTextRetype;
                                            });
                                          },
                                          icon: Icon(
                                            obscureTextRetype
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          Fluttertoast.showToast(
                                            msg: "Please retype your password",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            fontSize: 16.0,
                                          );
                                          return null;
                                        } else if (value != password.text) {
                                          Fluttertoast.showToast(
                                            msg: "Passwords do not match",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.white,
                                            textColor: Colors.black,
                                            fontSize: 16.0,
                                          );
                                          return null;
                                        }
                                        ;
                                      }),
                                ),
                              ),
                              if (showText)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Registration Fee : ",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Text(
                                        fee,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: SizedBox(
                                  width: 250,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        if (password.text.length >= 8) {
                                          if (password.text == retype.text) {
                                            register();
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "Passwords do not match",
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
                                            msg:
                                                "Password must be at least 8 characters",
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
                                          msg: "Enter all the fields",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.white,
                                          textColor: Colors.black,
                                          fontSize: 16.0,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      "Register",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
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
