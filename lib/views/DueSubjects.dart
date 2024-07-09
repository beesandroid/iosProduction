import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DueSubjectsTable extends StatefulWidget {
  @override
  _DueSubjectsTableState createState() => _DueSubjectsTableState();
}

class _DueSubjectsTableState extends State<DueSubjectsTable> {
  late List<Map<String, dynamic>> dueSubjectDetailsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDueSubjects();
  }

  Future<void> fetchDueSubjects() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      String colCode = prefs.getString('colCode') ?? '';
      String userName = prefs.getString('userName') ?? '';
      String email = prefs.getString('email') ?? '';
      String betStudMobile = prefs.getString('betStudMobile') ?? '';
      int schoolid = prefs.getInt('schoolId') ?? 0;
      int studId = prefs.getInt('studId') ?? 0;
      int fYearId = prefs.getInt('fYearId') ?? 0;
      int acYearId = prefs.getInt('acYearId') ?? 0;
      int userType = prefs.getInt('userType') ?? 0;

      Map<String, String> requestBody = {
        'GrpCode': grpCodeValue,
        'ColCode': 'pss',
        'CollegeId': '0001',
        'SchoolId': schoolid.toString(),
        'AdmnNo': userName, // Use userNameValue for AdmnNo
        'Flag': '0'
      };

      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPI/Android/StudDueSubjectDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add any headers if required
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);
        setState(() {
          dueSubjectDetailsList = List<Map<String, dynamic>>.from(data['dueSubjectDetailsList']);
          isLoading = false; // Set isLoading to false after fetching data
        });
      } else {
        throw Exception('Failed to load due subjects');
      }
    } catch (error) {
      print('Error fetching due subjects: $error');
      setState(() {
        isLoading = false; // Set isLoading to false in case of error
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Due Subjects',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading // Display a circular progress indicator while loading data
          ? Center(
        child: CircularProgressIndicator(),
      )
          : dueSubjectDetailsList.isEmpty
          ? Center(
        child: Text(
          'No Subjects Due',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ) // Display "No Subjects Due" if there is no data
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration:
            BoxDecoration(border: Border.all(color: Colors.grey)),
            child: DataTable(
              headingRowHeight: 40,
              columns: [
                DataColumn(
                  label: Text(
                    'Semester',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Subject Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: dueSubjectDetailsList.map((subject) {
                return DataRow(cells: [
                  DataCell(
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            subject['sem'] ?? 'null',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ), // Display "null" if data is null
                  DataCell(
                    Text(
                      subject['name'] ?? 'null',
                      softWrap: true, // Wrap text if it's too long
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DueSubjectsTable(),
  ));
}
