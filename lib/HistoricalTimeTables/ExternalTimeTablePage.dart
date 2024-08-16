import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExternalTimeTablePage extends StatefulWidget {
  const ExternalTimeTablePage({Key? key}) : super(key: key);
  @override
  State<ExternalTimeTablePage> createState() => _ExternalTimeTablePageState();
}
class _ExternalTimeTablePageState extends State<ExternalTimeTablePage> {
  List<String> examTypes = [];
  String? selectedExamType;
  List<String> semesters = [];
  String? selectedSemester;
  List<String> monthYears = [];
  String? selectedMonthYear;
  List<Map<String, dynamic>> timetableEntries = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchExamTypes();
  }

  Future<void> fetchExamTypes() async {
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
    String collegeId = prefs.getString('collegeId') ?? '';
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPI/Android/ExternalExamTimeTableExamTypeDropdown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "StudId": studId,
        "Sem": ""
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        examTypes = List<String>.from(
            responseData['examTypesList'].map((item) => item['examType']));
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load exam types';
      });
    }
  }

  Future<void> fetchSemesters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String betCourseId = prefs.getString('betCourseId') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    String collegeId = prefs.getString('collegeId') ?? '';
    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPI/Android/SemDropDown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "CourseId": betCourseId,
        "AdmnNo": userName
      }),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        semesters = List<String>.from(
            responseData['semDropDownList'].map((item) => item['semester']));
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load semesters';
      });
    }
  }

  Future<void> fetchMonthYears() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String colCode = prefs.getString('colCode') ?? '';
    String userName = prefs.getString('userName') ?? '';
    String betCourseId = prefs.getString('betCourseId') ?? '';
    String betStudMobile = prefs.getString('betStudMobile') ?? '';
    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;
    int fYearId = prefs.getInt('fYearId') ?? 00;
    int acYearId = prefs.getInt('acYearId') ?? 00;
    String collegeId = prefs.getString('collegeId') ?? '';
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPI/Android/ExamTimeTableMonthYearDropDown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "CourseId": betCourseId,
        "Sem": selectedSemester,
        "ExamType": selectedExamType,
        "StudId": studId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        monthYears = List<String>.from(
            responseData['examTimeTableMonthYearDropDownList']
                .map((item) => item['monthYear']));
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load month years';
      });
    }
  }

  Future<void> fetchTimetableEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';

    String betCourseId = prefs.getString('betCourseId') ?? '';

    int schoolid = prefs.getInt('schoolId') ?? 00;
    int studId = prefs.getInt('studId') ?? 00;

    String betBranchcode = prefs.getString('betBranchcode') ?? '';
    final response = await http.post(
      Uri.parse(
          'https://beessoftware.cloud/CoreAPI/Android/ExternalExamTimeTableDisplay'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "ExamType": selectedExamType,
        "CourseId": betCourseId,
        "BranchCode": betBranchcode,
        "Sem": selectedSemester,
        "MonthYear": selectedMonthYear,
        "StudId": studId
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        timetableEntries = List<Map<String, dynamic>>.from(
            responseData['externalExamTimeTableDisplayList']);
        if (timetableEntries.isEmpty) {
          errorMessage = 'No data available';
        } else {
          errorMessage = '';
        }
      });
    } else {
      setState(() {
        errorMessage = 'Failed to load timetable entries';
      });
    }
  }

  // Function to check if all dropdowns are selected
  bool allDropdownsSelected() {
    return selectedExamType != null &&
        selectedSemester != null &&
        selectedMonthYear != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text(
          'External Exam TimeTable',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Exam Type',
              ),
              value: selectedExamType,
              items: examTypes.map((String examType) {
                return DropdownMenuItem<String>(
                  value: examType,
                  child: Text(examType),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedExamType = newValue;
                  selectedSemester = null;
                  selectedMonthYear = null;
                  semesters.clear();
                  monthYears.clear();
                  timetableEntries.clear();
                });
                if (newValue != null) {
                  fetchSemesters();
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Semester',
              ),
              value: selectedSemester,
              items: semesters.map((String semester) {
                return DropdownMenuItem<String>(
                  value: semester,
                  child: Text(semester),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSemester = newValue;
                  selectedMonthYear = null;
                  monthYears.clear();
                  timetableEntries.clear();
                });
                if (newValue != null && selectedExamType != null) {
                  fetchMonthYears();
                }
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select MonthYear',
              ),
              value: selectedMonthYear,
              items: monthYears.map((String monthYear) {
                return DropdownMenuItem<String>(
                  value: monthYear,
                  child: Text(monthYear),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedMonthYear = newValue;
                  timetableEntries.clear();
                });
                if (newValue != null &&
                    selectedSemester != null &&
                    selectedExamType != null) {
                  fetchTimetableEntries();
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: timetableEntries.isEmpty && allDropdownsSelected()
                  ? Center(
                      child: Text(
                        errorMessage.isNotEmpty
                            ? errorMessage
                            : 'No data available',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : ListView.builder(
                      itemCount: timetableEntries.length,
                      itemBuilder: (context, index) {
                        final entry = timetableEntries[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry['subjectName'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Time",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow[800],
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    entry['sessionName'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow[800],
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    entry['date'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
