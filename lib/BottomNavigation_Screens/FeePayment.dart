import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Appdrawer/Notifications_view.dart';
import '../Appdrawer/customDrawer.dart';
import '../Fee_payment/CertificatesFeePayments.dart';
import '../Fee_payment/Fee_information.dart';
import '../Fee_payment/Re-evaluation_payment.dart';
import '../Fee_payment/Supply_payment.dart';
import '../Fee_payment/regular_payment.dart';

class FeePayments extends StatefulWidget {
  const FeePayments({Key? key}) : super(key: key);

  @override
  State<FeePayments> createState() => _FeePaymentsState();
}

class _FeePaymentsState extends State<FeePayments> {
  late Future<List<MenuDetailsList>> _menuDetailsListFuture;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _menuDetailsListFuture = fetchMenuDetailsList();
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

  Future<List<MenuDetailsList>> fetchMenuDetailsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String apiUrl = 'https://beessoftware.cloud/CoreAPI/Flutter/MenuDetails';
    Map<String, dynamic> requestBody = {
      'grpCode': grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "Category": "Fee Payments"
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
        return data.map((e) => MenuDetailsList.fromJson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        final List<dynamic> menuDetails = data['menuDetailsList'];
        return menuDetails.map((e) => MenuDetailsList.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load menu details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fee Payments',
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
      body: FutureBuilder<List<MenuDetailsList>>(
        future: _menuDetailsListFuture,
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
            final List<MenuDetailsList> menuDetailsList = snapshot.data!;
            return ListView.builder(
              itemCount: menuDetailsList.length,
              itemBuilder: (context, index) {
                final menu = menuDetailsList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(9.00)),
                    child: Center(
                      child: ListTile(
                        leading: Image.network(
                          menu.imagePath ?? '',
                          // Use the imagePath from your data
                          width: 50, // Set width as needed
                          height: 50, // Set height as needed
                        ),
                        title: Text(
                          menu.subCategory ?? '',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        onTap: () {
                          if (index == 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegularFeePayment()));
                          } else if (index == 3) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FeeInformation()));
                          }else if (index == 1) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SupplyFeePayment()));
                          }else if (index == 2) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Reevaluation()));
                          }else if (index == 7) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CertificateFeePayments()));
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

class MenuDetailsList {
  final String? subCategory;
  final String? imagePath;

  MenuDetailsList({this.subCategory, this.imagePath});

  factory MenuDetailsList.fromJson(Map<String, dynamic> json) {
    return MenuDetailsList(
      subCategory: json['subCategory'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }
}
