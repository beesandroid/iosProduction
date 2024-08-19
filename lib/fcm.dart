import 'package:betplus_ios/Appdrawer/Notifications_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init(BuildContext context) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Listen for messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message notification title: ${message.notification!.title}');
        print('Message notification body: ${message.notification!.body}');
      } else {
        print('No notification payload');
      }

      // If you need to handle specific data payload
      if (message.data.isNotEmpty) {
        print('Handling data payload: ${message.data}');
        // Handle your data logic here
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened app: ${message.data}');

      if (message.data.isNotEmpty) {
        String screen = message.data['click_action'] ?? 'notification_screen()';
        debugPrint('Navigating to screen: $screen');

        if (screen == 'notification_screen()') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => notification_screen()),
          );
        }
        // Handle other screens if necessary
      }
    });


    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print(
          'App opened from terminated state via notification: ${initialMessage.notification?.title}');
      String screenToNavigate =
          initialMessage.data['screen'] ?? 'notification_screen()';

      // Ensure correct screen navigation
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            if (screenToNavigate == 'notification_screen()') {
              return notification_screen(); // Adjust this to match your actual screen
            }
            // Add more conditions here if navigating to other screens
            return notification_screen(); // Fallback
          },
        ),
      ).then((_) {
        print('Navigation complete from terminated state');
      }).catchError((e) {
        print('Error navigating from terminated state: $e');
      });
    }

    // Handle notification that opened the app from a terminated state

    // Fetch and save the token with retry mechanism
    await _fetchAndSaveTokenWithRetry();
  }

  Future<void> _fetchAndSaveTokenWithRetry({int retries = 1}) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        await _getToken();
        return;
      } catch (e) {
        print('Attempt ${attempt + 1} failed: $e');
        if (attempt < retries - 1) {
          await Future.delayed(Duration(seconds: 1));
        } else {
          print('Failed to get token after $retries attempts');
        }
      }
    }
  }

  Future<void> _getToken() async {
    // Retrieve the APNS token for iOS devices
    String? apnsToken = await _firebaseMessaging.getAPNSToken();
    print('APNS Token: $apnsToken'); // Print the APNS token for debugging

    if (apnsToken == null) {
      throw Exception('APNS token is not set');
    }

    // Retrieve the FCM token
    String? fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken'); // Print the FCM token for debugging

    if (fcmToken != null) {
      await saveTokenToServer(fcmToken); // Save the token
    } else {
      throw Exception('FCM token is not set');
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

    print(
        'Request Body: ${json.encode(body)}'); // Print request body for debugging

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
