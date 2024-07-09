import 'dart:convert';

import 'package:betplus_ios/views/ForgotPasswordScreen.dart';
import 'package:betplus_ios/views/MainPage.dart';
import 'package:betplus_ios/views/NewLogin.dart';
import 'package:betplus_ios/views/PROVIDER.dart';

import 'package:betplus_ios/views/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onBoarding_screens/onboardingscreen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  bool isChecked = false;
  TextEditingController password = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController grpCode = TextEditingController();
  String? groupPhotoUrl;
  bool _obscureText = false;
  bool _isFirstTime = true; // Define _obscureText variable in your widget state

  Future<void> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
      prefs.setBool('isFirstTime', false);
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirstTime();

    loadSavedCredentials();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
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
        print("ssss" + responseBody.toString());
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

  void showToast(String message, {required BuildContext context}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      grpCode.text = prefs.getString('grpCode') ?? '';
      userName.text = prefs.getString('userName') ?? '';
      password.text = prefs.getString('password') ?? '';
      isChecked = prefs.getBool('isChecked') ?? false;
    });
  }

  Future<void> login(BuildContext context, String grpCode, String userName, String password) async {
    if (grpCode.isEmpty || userName.isEmpty || password.isEmpty) {
      showToast('Please enter all fields', context: context);
      return;
    }

    final payload = jsonEncode({
      "GrpCode": grpCode,
      "ColCode": "PSS",
      "UserName": userName,
      "Password": password,
    });

    final apiUrl =
        'https://beessoftware.cloud/CoreAPI/Flutter/GetUserDetails'; // Consider making this a constant

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: payload,
      );

      final responseBody =
          jsonDecode(response.body); // Parse response body here

      if (response.statusCode == 200) {
        // Check if response contains specific error message
        if (responseBody['message'] != null &&
            responseBody['message'] ==
                "Registration is not done. Go to Signup") {
          showToast(responseBody['message'], context: context);
          return;
        }

        final prefs = await SharedPreferences.getInstance();

        responseBody.forEach((key, value) {
          if (value is String) {
            prefs.setString(key, value);
          } else if (value is int) {
            prefs.setInt(key, value);
          } else if (value is bool) {
            prefs.setBool(key, value);
          } else if (value is double) {
            prefs.setDouble(key, value);
          } else if (value is List<String>) {
            prefs.setStringList(key, value);
          } else {
            prefs.setString(key, value.toString());
          }
        });

        // Navigate to the next screen if login is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
        showToast('Login Successfully',
            context: context); // Show success message
      } else {
        showToast(responseBody['message'],
            context: context); // Show error message
      }
    } catch (e) {
      print('Error during login: $e');
      showToast('Failed to login. Please try again later.',
          context: context); // Show generic error message
    }
  }

  Future<Map<String, dynamic>?> fetchBet() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String grpCodeValue = prefs.getString('grpCode') ?? '';
      String userNameValue = prefs.getString('userName') ?? '';

      String apiUrl =
          'https://beessoftware.cloud/CoreAPI/Flutter/BETStudentInformation';
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
        print("zzzzzzz" + responseBody.toString());
        List<dynamic>? detailsList =
            responseBody['betStudentInformationList'] as List?;

        if (detailsList != null && detailsList.isNotEmpty) {
          return responseBody; // Return the fetched data
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null; // Return null in case of failure or empty response
  }

  late AnimationController _animationController;
  late Animation<double> _animation;

  void _animateTextField() {
    _animationController
        .forward()
        .then((value) => _animationController.reverse());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back navigation from SplashScreen
        // Pop until you reach the first route (probably the home page)
        Navigator.popUntil(context, (route) => route.isFirst);
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Light green curved background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 370,
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
            // Foreground content
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 65.0, bottom: 1),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 125,
                          height: 125,
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
                                          color: Colors.white, width: 2),
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
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        height: 350,
                        width: 300,
                        child: Center(
                          child: Form(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 10, right: 10),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: TextField(
                                      controller: grpCode,
                                      decoration: InputDecoration(
                                        icon: Icon(
                                          FontAwesomeIcons.users,
                                          color: Colors.grey,
                                        ),
                                        labelText: "Group Code",
                                        labelStyle:
                                            TextStyle(color: Colors.grey),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        fetchGroupPhoto(value);
                                        _animateTextField();
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 10, right: 10),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: TextFormField(
                                      controller: userName,
                                      decoration: InputDecoration(
                                        icon: Icon(
                                          FontAwesomeIcons.user,
                                          color: Colors.grey,
                                        ),
                                        labelText: "User Id",
                                        labelStyle:
                                            TextStyle(color: Colors.grey),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                      onTap: _animateTextField,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 10, right: 10),
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 22),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: TextFormField(
                                      controller: password,
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        icon: Icon(
                                          FontAwesomeIcons.lock,
                                          color: Colors.grey,
                                        ),
                                        labelText: "Password",
                                        labelStyle:
                                            TextStyle(color: Colors.grey),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                          icon: Icon(
                                            _obscureText
                                                ? FontAwesomeIcons.eyeSlash
                                                : FontAwesomeIcons.eye,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      onTap: _animateTextField,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 18.0),
                                  child: SizedBox(
                                    width: 175,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await login(context, grpCode.text,
                                            userName.text, password.text);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.lightGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value ?? false;
                                  });
                                },
                              ),
                            ),
                            Text(
                              "Remember credentials",
                              style: TextStyle(color: Colors.lightGreen),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 25),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Forgot password",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewLogin(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            const Text("Powered by"),
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: Image.asset("asset/splash.png"),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
