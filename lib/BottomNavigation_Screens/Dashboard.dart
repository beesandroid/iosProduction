import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Appdrawer/Notifications_view.dart';
import '../Appdrawer/customDrawer.dart';
import '../Fee_payment/regular_payment.dart';
import '../Marks_Details/overallperf.dart';
import '../Marks_Details/overallperformance.dart';
import '../fcm.dart';
import '../firebase_options.dart';
import '../views/DueSubjects.dart';
import '../views/reportIssues.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String courseId = '';
  String studId = '';
  String semNo = '';
  String marksObtained = '';
  String totMax = '';
  String totPerc = '';
  String totCredits = '';
  String finalCGPA = '';
  String sgpa = '';
  String examFee = '';
  String recentSem = '';
  String subjectsDue = '';
  String totalSubjects = '';
  String gradeSystem = '';
  bool isLoading = true;
  String? name;
  String? rollNo;
  String? betBatch;
  String? betSem;

  String? admissionDate;
  String? welcomeMessage;
  String? imagePath;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _fetchProfileData();
    fetchUnreadNotificationsCount();

  }
  Future<void> fetchUnreadNotificationsCount() async {
    try {
      final List<NotificationModel> notifications = await fetchNotifications();
      setState(() {
        _unreadNotificationsCount = notifications.where((n) => n.readStatus == 0).length;
      });
    } catch (e) {
      setState(() {
        _unreadNotificationsCount = 0;
      });
      // Handle error if necessary
    }
  }

  Future<List<NotificationModel>> fetchNotifications({bool markAsRead = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;

    final apiUrl = 'https://beessoftware.cloud/CoreAPI/Android/GetNotificationDetails';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": 0,
      "StudId": 331,
      "Flag": markAsRead ? "1" : "0",
      "readStatus": markAsRead ? 1 : 0,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body)['getNotificationsList'];
      return jsonResponse.map((json) {
        return NotificationModel(
          notId: json['notId'],
          notificationMessage: json['notificationMessage'],
          notifiedDt: json['notifiedDt'],
          readStatus: json['readStatus'], // Add readStatus here
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 29,
            color: Color(0xFF13497B),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => notification_screen(),
                    ),
                  ).then((_) {
                    fetchUnreadNotificationsCount();
                  });
                },
                icon: const Icon(Icons.notifications_active),
              ),
              Positioned(
                right: 6,
                top: 3,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: _unreadNotificationsCount > 0 ? Colors.red : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$_unreadNotificationsCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.lightGreen,
                    height: 65,
                    child: Center(
                      child: Text(
                        welcomeMessage ?? 'Welcome!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 125,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundImage: imagePath != null
                                    ? NetworkImage(imagePath!)
                                    : null,
                                child: imagePath == null
                                    ? Icon(Icons.person, size: 45)
                                    : null,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: EdgeInsets.only(left: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    name ?? '',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(rollNo ?? ''),
                                  Text(betBatch ?? ''),
                                  Text(betSem ?? ''),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Container(
                          height: 90,
                          width: 170,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "SGPA",
                                  style: TextStyle(
                                      color: Color(0xFFFF9800),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(sgpa)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          height: 90,
                          width: 170,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Final CGPA",
                                  style: TextStyle(
                                      color: Color(0xFFFF9800),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(finalCGPA)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OverallPerformance()));
                          },
                          child: Container(
                            height: 90,
                            width: 170,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Total Credits",
                                    style: TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(totCredits)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DueSubjectsTable()),
                            );
                          },
                          child: Container(
                            height: 90,
                            width: 170,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Due Subjects",
                                    style: TextStyle(
                                      color: Color(0xFFFF9800),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(subjectsDue),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RegularFeePayment(), // Replace with your screen
                              ),
                            );
                          },
                          child: Container(
                            height: 90,
                            width: 170,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Regular exam fee",
                                    style: TextStyle(
                                        color: Color(0xFFFF9800),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(examFee),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OverallPerf(
                                    recentSem:
                                        recentSem), // Replace with your screen
                              ),
                            );
                          },
                          child: Container(
                            height: 90,
                            width: 170,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Recent Result",
                                    style: TextStyle(
                                      color: Color(0xFFFF9800),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(recentSem),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 22),
                        child: SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DropdownMenus()),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.lightGreen),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Report Issues',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
    );
  }

  Future<void> _fetchDashboardData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      String userNameValue = prefs.getString('userName') ?? '';

      String apiUrl =
          'https://beessoftware.cloud/CoreAPI/Flutter/StudDashBoardDetails';
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
        List<dynamic> detailsList = responseBody['studDashBoardDetailsList'];

        if (detailsList.isNotEmpty) {
          Map<String, dynamic> details = detailsList.first;
          setState(() {
            courseId = details['courseId'] ?? '';
            studId = details['studId'] ?? '';
            semNo = details['semNo'] ?? '';
            marksObtained = details['marksObtained'] ?? '';
            totMax = details['totMax'] ?? '';
            totPerc = details['totPerc'] ?? '';
            totCredits = details['totCredits'] ?? '';
            finalCGPA = details['finalCGPA'] ?? '';
            sgpa = details['sgpa'] ?? '';
            examFee = details['examFee'] ?? '';
            recentSem = details['recentSem'] ?? '';
            subjectsDue = details['subjectsDue'] ?? '';
            totalSubjects = details['totalSubjects'] ?? '';
            gradeSystem = details['gradeSystem'] ?? '';
            isLoading = false;
          });
        } else {
          print('Empty details list');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchProfileData() async {
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
        print("tttttt" + responseBody.toString());
        List<dynamic>? detailsList = responseBody['betStudentInformationList'];

        if (detailsList != null && detailsList.isNotEmpty) {
          Map<String, dynamic> details = detailsList.first;
          setState(() {
            name = details['name'];
            welcomeMessage = details['welcomeMessage'];
            admissionDate = details['admissionDate'];
            rollNo = details['rollNo'];
            betBatch = details['betBatch'];
            betSem = details['betSem'];
            imagePath = details['imagePath'];
          });
        } else {
          print('Empty or null details list');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

class SaveTokenToServer {
  Future<void> _saveTokenToServer(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String admnNo = prefs.getString('admnNo') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    const url = 'https://beessoftware.cloud/CoreAPI/Android/FMCTokenSaving';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, dynamic> body = {
      "GrpCode": grpCodeValue,
      "CollegeId": collegeId,
      "ColCode": colCode,
      "Admnno": admnNo,
      "Token": token,
      "Flag": "0"
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Handle successful response
        print('Token saved successfully');
      } else {
        // Handle server error
        print('Failed to save token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error saving token: $e');
    }
  }
}


void main() {

  runApp(const MaterialApp(

    home: Dashboard(),
  ));
}
