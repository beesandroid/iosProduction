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

  @override
  void initState() {
    super.initState();
    _marksDetailsListFuture = fetchMarksDetailsList();
  }

  Future<List<MarksDetailsList>> fetchMarksDetailsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String userNameValue = prefs.getString('userName') ?? '';

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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => notification_screen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_active),
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
                          // Use the imagePath from your data
                          width: 50, // Set width as needed
                          height: 50, // Set height as needed
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
                            // Navigate to Marks Entry screen
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => midMarks()));
                          } else if (index == 1) {
                            // Navigate to Marks Report screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FinalInternalMarks()),
                            );
                          } else if (index == 2) {
                            // Navigate to Other Marks Details screen
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
