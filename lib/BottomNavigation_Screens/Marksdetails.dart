import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Appdrawer/Notifications_view.dart';
import '../Appdrawer/customDrawer.dart';
import '../Marks_Details/finalInternalMarks.dart';
import '../Marks_Details/midmarks.dart';
import '../Marks_Details/overallperformance.dart';
import '../response/marksdetails.dart';

class Marksdetails extends StatefulWidget {
  const Marksdetails({Key? key}) : super(key: key);

  @override
  State<Marksdetails> createState() => _MarksdetailsState();
}

class _MarksdetailsState extends State<Marksdetails> {
  late Future<List<MarksDetailsList>> _marksDetailsListFuture;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _marksDetailsListFuture = fetchMarksDetailsList();
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

  Future<List<MarksDetailsList>> fetchMarksDetailsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? grpCodeValue = prefs.getString('grpCode');

    if (grpCodeValue == null) {
      // Handle the null value here, maybe assign a default or show an error
      print('Group Code is null');
    } else {
      // Use grpCodeValue safely here
      print('Group Code is: $grpCodeValue');
    }

    String apiUrl = 'https://beessoftware.cloud/CoreAPI/Flutter/MenuDetails';
    Map<String, dynamic> requestBody = {
      'grpCode': grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "Category": "Marks Details"
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      if (data is List) {
        return data.map((e) => MarksDetailsList.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final List<dynamic> marksDetails = data['menuDetailsList'];
        return marksDetails.map((e) => MarksDetailsList.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load menu details');
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
      "StudId": studId,
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
          'Marks Details',
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
      body: FutureBuilder<List<MarksDetailsList>>(
        future: _marksDetailsListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final List<MarksDetailsList> marksDetailsList = snapshot.data!;
            return ListView.builder(
              itemCount: marksDetailsList.length,
              itemBuilder: (context, index) {
                final menu = marksDetailsList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(9.00),
                    ),
                    child: Center(
                      child: ListTile(
                        leading: Image.network(
                          menu.imagePath ?? '',
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          menu.subCategory ?? '',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        onTap: () {
                          if (index == 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => midMarks()));
                          } else if (index == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FinalInternalMarks()),
                            );
                          } else if (index == 2) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OverallPerformance()),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }
}

