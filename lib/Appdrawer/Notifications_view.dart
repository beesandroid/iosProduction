import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationModel {
  final int notId;
  final String notificationMessage;
  final String notifiedDt;
  final int readStatus;

  NotificationModel({
    required this.notId,
    required this.notificationMessage,
    required this.notifiedDt,
    required this.readStatus,
  });
}

class notification_screen extends StatefulWidget {
  const notification_screen({Key? key}) : super(key: key);

  @override
  State<notification_screen> createState() => _notification_screenState();
}

class _notification_screenState extends State<notification_screen> {
  late Future<List<NotificationModel>> _notificationListFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationListFuture = fetchNotifications(markAsRead: true);

    _notificationListFuture.then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<List<NotificationModel>> fetchNotifications({bool markAsRead = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;

    final apiUrl = 'https://mritsexams.com/CoreApi/Android/GetNotificationDetails';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "StudId": studId,
      "flag":0,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );
    print(requestBody);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body)['getNotificationsList'];
      print(jsonResponse);
      return jsonResponse.map((json) {
        return NotificationModel(
          notId: json['notId'],
          notificationMessage: json['notificationMessage'],
          notifiedDt: json['notifiedDt'],
          readStatus: json['readStatus'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> markNotificationAsRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;

    final apiUrl = 'https://mritsexams.com/CoreApi/Android/GetNotificationDetails';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "StudId": studId,
      "flag": 1,

    };
    print(requestBody);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Notification marked as read');
    } else {
      print('Failed to mark notification as read');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        leading: IconButton(
          onPressed: () {
            markNotificationAsRead();
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 29,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<NotificationModel>>(
        future: _notificationListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<NotificationModel> notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return Center(child: Text('No notifications available'));
            }
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final NotificationModel notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        notification.notifiedDt,
                        style: TextStyle(
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        notification.notificationMessage,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        await markNotificationAsRead();
                        setState(() {
                          _notificationListFuture = fetchNotifications(markAsRead: false);
                        });
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
