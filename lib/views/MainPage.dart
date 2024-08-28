import 'dart:convert';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services library
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../BottomNavigation_Screens/Dashboard.dart';
import '../BottomNavigation_Screens/Downloads.dart';
import '../BottomNavigation_Screens/ExamTimeTable.dart';
import '../BottomNavigation_Screens/FeePayment.dart';
import '../BottomNavigation_Screens/Marksdetails.dart';
import 'betprovider.dart';

void main() {
  initializeDateFormatting().then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BetStudentProvider()),
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BETPlus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Profile(),
    );
  }
}

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _page = 2; // Set the initial index to the Dashboard
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _page);
    fetchBet();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Return true to allow popping, false to prevent it
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the a?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(), // Exit the app
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.white,
          buttonBackgroundColor: Colors.lightGreen,
          color: Colors.lightGreen,
          animationDuration: const Duration(milliseconds: 300),
          index: _page,
          // Set the initial index to the Dashboard
          items: const <Widget>[
            Icon(Icons.schedule_sharp, size: 26, color: Colors.white),
            Icon(Icons.credit_score, size: 26, color: Colors.white),
            Icon(Icons.home, size: 26, color: Colors.white),
            Icon(Icons.school, size: 26, color: Colors.white),
            Icon(Icons.file_download, size: 26, color: Colors.white),
          ],
          onTap: (index) {
            setState(() {
              _page = index;
              _pageController.animateToPage(
                _page,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
            });
          },
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _page = index;
            });
          },
          children: const <Widget>[
            ExamTimeTable(),
            FeePayments(),
            Dashboard(), // Dashboard screen
            Marksdetails(),
            DownloadsScreen()
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> fetchBet() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String userNameValue = prefs.getString('userName') ?? '';

    String apiUrl =
        'https://mritsexams.com/CoreApi/Flutter/BETStudentInformation';
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
