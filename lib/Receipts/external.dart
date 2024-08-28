import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/PROVIDER.dart';
import '../views/betprovider.dart';

class ExternalView extends StatefulWidget {
  @override
  _ExternalViewState createState() => _ExternalViewState();
}

class _ExternalViewState extends State<ExternalView> {
  String? _selectedExamType;
  List<String> _examTypes = [];

  String? _selectedSemester;
  List<String> _semesters = [];

  String? _selectedMonthYear;
  List<String> _monthYears = [];

  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _fetchExamTypes();
    _fetchSemesters();
  }

  Future<void> _fetchExamTypes() async {
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
    int betStudUserId = prefs.getInt('betStudUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/ExternalExamTimeTableExamTypeDropdown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "GrpCode": grpCodeValue,
        "ColCode": colCode,
        "CollegeId": "0001",
        "SchoolId": schoolid.toString(),
        "StudId": studId.toString(),
        "Sem": ""
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> examTypesList = data['examTypesList'];
      setState(() {
        _examTypes = examTypesList.map((e) => e['examType'] as String).toList();
        _selectedExamType = _examTypes.isNotEmpty ? _examTypes[0] : null;
      });
    } else {
      throw Exception('Failed to load exam types');
    }

    // Set _isLoading to false after fetching exam types
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchSemesters() async {
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
    int betStudUserId = prefs.getInt('betStudUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/SemDropDown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid.toString() ?? '',
        "CourseId": betCourseId.toString(),
        "AdmnNo": userName
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> semDropDownList = data['semDropDownList'];
      setState(() {
        _semesters =
            semDropDownList.map((e) => e['semester'] as String).toList();
        _selectedSemester = _semesters.isNotEmpty ? _semesters[0] : null;
      });
    } else {
      throw Exception('Failed to load semesters');
    }

    // Set _isLoading to false after fetching semesters
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMonthYears() async {
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
    int betStudUserId = prefs.getInt('betStudUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';
    if (_selectedExamType == null || _selectedSemester == null) {
      return;
    }

    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/ExamTimeTableMonthYearDropDown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid.toString() ?? '',
        "CourseId": betCourseId.toString(),
        "Sem": _selectedSemester!,
        "ExamType": _selectedExamType!,
        "StudId": "593"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> examTimeTableMonthYearDropDownList =
          data['examTimeTableMonthYearDropDownList'];
      setState(() {
        _monthYears = examTimeTableMonthYearDropDownList
            .map((e) => e['monthYear'] as String)
            .toList();
        _selectedMonthYear = _monthYears.isNotEmpty ? _monthYears[0] : null;
      });
    } else {
      throw Exception('Failed to load month/years');
    }
  }

  Future<void> _downloadHallTicket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String betBatch = prefs.getString('betBatch') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int betStudUserId = prefs.getInt('betStudUserId') ?? 00;
    String betCourseId = prefs.getString('betCourseId') ?? '';

    String studentInformation = prefs.getString('studentInformation') ?? '';
    if (_selectedExamType == null ||
        _selectedSemester == null ||
        _selectedMonthYear == null ||
        studentInformation == null) {
      return;
    }

    // Set the flag value based on the selected exam type index
    String flag = _examTypes.indexOf(_selectedExamType!) == 1 ? "1" : "0";

    final response = await http.post(
      Uri.parse(
          'https://mritsexams.com/CoreApi/Android/HallTicketsDownloadReports'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "GrpCode": grpCodeValue,
        "CollegeId": "0001",
        "ColCode": "PSS",
        "SchoolId": schoolid.toString(),
        "AcYearId": acYearId.toString(),
        "CourseId": betCourseId.toString(),
        "Sem": _selectedSemester!,
        "Mon": _selectedMonthYear!,
        "Flag": flag, // Set the flag value here
        "Batch": betBatch,
        "Studid": studId.toString(),
        "NoCopies": "1"
      }),
    );

    if (response.statusCode == 200) {
      print(response.body.toString());
      final String fileName = 'hall_ticket.pdf';
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(response.bodyBytes);

      OpenFile.open(file.path);
    } else {
      throw Exception('Failed to download hall ticket');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Semester",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              value: _selectedSemester,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSemester = newValue;
                  _fetchMonthYears(); // Fetch month/years when semester changes
                });
              },
              items: _semesters.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Exam Type",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              value: _selectedExamType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedExamType = newValue;
                  _fetchMonthYears(); // Fetch month/years when exam type changes
                });
              },
              items: _examTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Month/Year",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              value: _selectedMonthYear,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMonthYear = newValue;
                });
              },
              items: _monthYears.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 24.0),
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ElevatedButton(
              onPressed: _downloadHallTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: Text(
                'Download',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
