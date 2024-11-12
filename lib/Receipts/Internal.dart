import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InternalView extends StatefulWidget {
  const InternalView({Key? key}) : super(key: key);

  @override
  State<InternalView> createState() => _InternalViewState();
}

class _InternalViewState extends State<InternalView> {
  List<Map<String, dynamic>> _examList = [];
  List<Map<String, dynamic>> _semList = [];
  List<Map<String, dynamic>> _examDivisionList = [];
  List<Map<String, dynamic>> _monthYearList = [];
  String? _selectedExam;
  String? _selectedSem;
  String? _selectedExamDivision;
  String? _selectedMonthYear;

  @override
  void initState() {
    super.initState();
    fetchExams();
    fetchSems();
    fetchExamDivisions();
  }

  Future<void> fetchExams() async {
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
    String betCurid = prefs.getString('betCurid') ??'';

    String betCourseId = prefs.getString('betCourseId') ?? '';
    final url =
        'https://mritsexams.com/CoreApi/Android/InternalExamDropDown';
    final requestPayload = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "CourseId": betCourseId,
      "CurId": betCurid
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestPayload),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _examList =
        List<Map<String, dynamic>>.from(data['internalExamDropDownList']);
        if (_examList.isNotEmpty) {
          _selectedExam = _examList[0]['examName'];
        }
      });
    } else {
      throw Exception('Failed to load exams');
    }
  }

  Future<void> fetchSems() async {
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
    String betCurid = prefs.getString('betCurid') ??'';

    String betCourseId = prefs.getString('betCourseId') ?? '';
    final url = 'https://mritsexams.com/CoreApi/Android/SemDropDown';
    final requestPayload = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId":schoolid,
      "CourseId": betCourseId,
      "AdmnNo": userName
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestPayload),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _semList = List<Map<String, dynamic>>.from(data['semDropDownList']);
        if (_semList.isNotEmpty) {
          _selectedSem = _semList[0]['semester'];
          fetchMonthYears(_selectedSem!);
        }
      });
    } else {
      throw Exception('Failed to load semesters');
    }
  }

  Future<void> fetchExamDivisions() async {
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
    String betCurid = prefs.getString('betCurid') ??'';

    String betCourseId = prefs.getString('betCourseId') ?? '';
    final url =
        'https://mritsexams.com/CoreApi/Android/InternalExamDivisionDropDown';
    final requestPayload = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolid,
      "ExamId": _examList,
      "CourseId": betCourseId,
      "CurId": betCurid
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestPayload),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _examDivisionList = List<Map<String, dynamic>>.from(
            data['internalExamDivisionDropDownList']);
        if (_examDivisionList.isNotEmpty) {
          _selectedExamDivision = _examDivisionList[0]['examDivName'];
        }
      });
    } else {
      throw Exception('Failed to load exam divisions');
    }
  }

  Future<void> fetchMonthYears(String selectedSem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String ColCode = prefs.getString('ColCode') ?? '';
    String CollegeId = prefs.getString('CollegeId') ?? '';
    String email = prefs.getString('email') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    int betStudUserId = prefs.getInt('betStudUserId') ?? 00;
    String betCurid = prefs.getString('betCurid') ??'';

    String betCourseId = prefs.getString('betCourseId') ?? '';
    final url = 'https://mritsexams.com/CoreApi/Android/InternalExamMonthYearDropDown';
    final requestPayload = {
      "GrpCode": grpCodeValue,
      "CollegeId": "0001",
      "ColCode": "PSS",
      "SchoolId": schoolid,
      "CourseId": betCourseId,
      "Sem": selectedSem,
      "ExamId": _examList,
      "ExamDivId": _examDivisionList,
      "StudId": studId
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestPayload),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _monthYearList = List<Map<String, dynamic>>.from(
            data['internalExamMonthYearDropDownList']);
        if (_monthYearList.isNotEmpty) {
          _selectedMonthYear = _monthYearList[0]['monthYear'];
        }
      });
    } else {
      throw Exception('Failed to load month years');
    }
  }

  Future<void> downloadPDF() async {
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
    String betCurid = prefs.getString('betCurid') ??'';

    String betCourseId = prefs.getString('betCourseId') ?? '';
    if (_selectedSem != null &&
        _selectedExam != null &&
        _selectedExamDivision != null &&
        _selectedMonthYear != null) {
      final url =
          'https://mritsexams.com/CoreApi/Android/HallTicketsDownloadReports';
      final requestPayload = {
        "GrpCode": grpCodeValue,
        "CollegeId": "0001",
        "ColCode": "PSS",
        "SchoolId": schoolid,
        "AcYearId": acYearId,
        "CourseId": betCourseId,
        "Sem": _selectedSem!,
        // "Sem": _selectedSem!,
        "Mon": _selectedMonthYear!,

        // "Mon": _selectedMonthYear!,
        "Flag": 0,
        "Batch": "2019 - 2020",
        "ExamId":_examList,
        "ExamDivId":_examDivisionList,

        "Studid": studId,

      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestPayload),
      );

      if (response.statusCode == 200) {
        final String fileName = 'hall_ticket.pdf';
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');

        await file.writeAsBytes(response.bodyBytes);

        OpenFile.open(file.path);
      } else {
        throw Exception('Failed to download hall ticket');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select all options.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            _semList.isEmpty
                ? CircularProgressIndicator()
                : DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Semester",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              value: _selectedSem,
              items: _semList.map((sem) {
                return DropdownMenuItem<String>(
                  value: sem['semester'],
                  child: Text(sem['semester']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSem = newValue;
                  fetchMonthYears(newValue!);
                });
              },
              icon: Icon(Icons.arrow_drop_down),
            ),
            SizedBox(height: 12),
            _examList.isEmpty
                ? CircularProgressIndicator()
                : DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Exam",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              value: _selectedExam,
              items: _examList.map((exam) {
                return DropdownMenuItem<String>(
                  value: exam['examName'],
                  child: Text(exam['examName']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedExam = newValue;
                });
              },
              icon: Icon(Icons.arrow_drop_down),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Exam Division",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              value: _selectedExamDivision,
              items: _examDivisionList.map((examDivision) {
                return DropdownMenuItem<String>(
                  value: examDivision['examDivName'],
                  child: Text(examDivision['examDivName']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedExamDivision = newValue;
                });
              },
              icon: Icon(Icons.arrow_drop_down),
            ),
            SizedBox(height: 12),
           DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Month/Year",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              value: _selectedMonthYear,
              items: _monthYearList.map((monthYear) {
                return DropdownMenuItem<String>(
                  value: monthYear['monthYear'],
                  child: Text(monthYear['monthYear']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMonthYear = newValue;
                });
              },
              icon: Icon(Icons.arrow_drop_down),
            ),
            SizedBox(height: 24.0),
            Center(
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ElevatedButton(
                  onPressed: downloadPDF,
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
            ),
          ],
        ),
      ),
    );
  }
}