import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Appdrawer/student_info.dart';
import '../main.dart';
import '../views/PROVIDER.dart';
import '../views/splashscreen.dart';
import 'Feedback.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? clgLogoUrl;

  @override
  void initState() {
    super.initState();
    _fetchClgLogo();
  }

  Future<void> _fetchClgLogo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    String collegeId = prefs.getString('collegeId') ??'';
    final apiUrl = 'https://beessoftware.cloud/CoreApi/Android/GetClgLogo';

    final Map<String, String> requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": colCode,
      "CollegeId": collegeId.toString()
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {

        final data = json.decode(response.body);
        final byteImage = data['clgList']['clgLogo'];
        setState(() {
          clgLogoUrl = 'data:image/jpeg;base64,$byteImage';
        });
      } else {
        throw Exception('Failed to fetch clgLogo');
      }
    } catch (e) {
      print('Error fetching clgLogo: $e');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                // Assuming isChecked is defined in this screen
                logout(context);
// Navigate to the desired screen
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDetails =
        Provider.of<UserProvider>(context, listen: false).userDetails;
    print(userDetails);

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightGreen,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 55.0,
                    backgroundImage: clgLogoUrl != null
                        ? MemoryImage(base64Decode(clgLogoUrl!.split(',').last))
                        : null,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const student_profile(),
                ),
              );
            },
            leading: const Icon(
              Icons.person,
              color: Color(0xFF13497B),
            ),
            title: const Text(
              "Profile",
              style: TextStyle(color: Color(0xFF13497B)),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const feedback()),
              );
            },
            leading: const Icon(
              Icons.feedback,
              color: Color(0xFF13497B),
            ),
            title: const Text(
              "Feedback",
              style: TextStyle(color: Color(0xFF13497B)),
            ),
          ),
          const ListTile(
            leading: Icon(
              Icons.share,
              color: Color(0xFF13497B),
            ),
            title: Text(
              "Share",
              style: TextStyle(color: Color(0xFF13497B)),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.star, color: Color(0xFF13497B)),
            title: Text(
              "Rate us",
              style: TextStyle(color: Color(0xFF13497B)),
            ),
          ),
          ListTile(
            onTap: () {
              _showLogoutDialog(context);
            },
            leading: const Icon(
              Icons.logout,
              color: Color(0xFF13497B),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(color: Color(0xFF13497B)),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isChecked = prefs.getBool('isChecked') ?? false;

    if (!isChecked) {
      await prefs.remove('grpCode');
      await prefs.remove('userName');
      await prefs.remove('password');
    }

    await prefs.setBool('isLoggedIn', false);

    // Navigate back to the login screen or splash screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }




}
