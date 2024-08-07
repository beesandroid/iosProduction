import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Handle notification
        print('Message title: ${message.notification!.title}');
        print('Message body: ${message.notification!.body}');
      }
    });
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap
    });

    // Fetch and save the token
    await _getToken();
  }

  Future<void> _getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token'); // Print the token for debugging
    if (token != null) {
      await saveTokenToServer(token); // Save the token
    }
  }

  Future<void> saveTokenToServer(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String collegeId = prefs.getString('collegeId') ?? '';
    String admnNo = prefs.getString('admnNo') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';

    final Map<String, dynamic> body = {
      "GrpCode": grpCodeValue,
      "CollegeId": collegeId,
      "ColCode": colCode,
      "Admnno": admnNo,
      "Token": token,
      "Flag": "0"
    };

    print('Request Body: ${json.encode(body)}'); // Print request body for debugging

    const url = 'https://beessoftware.cloud/CoreAPI/Android/FMCTokenSaving';
    final Map<String, String> headers = {'Content-Type': 'application/json'};

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
