import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InternalTimeTablePage extends StatefulWidget {
  const InternalTimeTablePage({Key? key}) : super(key: key);

  @override
  State<InternalTimeTablePage> createState() => _InternalTimeTablePageState();
}

class _InternalTimeTablePageState extends State<InternalTimeTablePage> {
  late Future<List<InternalExam>> internalExamsFuture;
  List<InternalExamDivision> internalExamDivisions = [];
  InternalExam? selectedExam;
  InternalExamDivision? selectedExamDivision;
  List<Map<String, dynamic>> timetableEntries = [];

  @override
  void initState() {
    super.initState();
    internalExamsFuture = fetchInternalExams();
  }

  Future<List<InternalExam>> fetchInternalExams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String betCourseId = prefs.getString('betCourseId') ?? '';
    String betCurid = prefs.getString('betCurid') ?? '';

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPI/Android/InternalExamDropDown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": 1,  // Assuming this is an integer in your API request
        "CourseId": betCourseId,
        "CurId": betCurid,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> internalExamList =
      jsonDecode(response.body)['internalExamDropDownList'];
      return internalExamList
          .map((json) => InternalExam.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load internal exams');
    }
  }

  Future<List<InternalExamDivision>> fetchInternalExamDivisions(int examId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String betCourseId = prefs.getString('betCourseId') ?? '';
    String betCurid = prefs.getString('betCurid') ?? '';

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPI/Android/InternalExamDivisionDropDown'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": "1",
        "ExamId": examId.toString(),
        "CourseId": betCourseId,
        "CurId": betCurid,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> internalExamDivisionList =
      jsonDecode(response.body)['internalExamDivisionDropDownList'];

      // Check if the first index (0 index) has no response, then return an empty list
      if (internalExamDivisionList.isEmpty) {
        return [];
      }

      return internalExamDivisionList
          .map((json) => InternalExamDivision.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load internal exam divisions');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCourseAndCurId(int examId, int examDivId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    String betCourseId = prefs.getString('betCourseId') ?? '';
    String betBranchCode = prefs.getString('betBranchCode') ?? '';
    int studId = prefs.getInt('studId') ?? 0;
    String betSem = prefs.getString('betSem') ?? '';

    // Prepare the request body
    Map<String, dynamic> requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": "1",
      "ExamId": examId.toString(),
      "ExamDivId": examDivId.toString(),
      "CourseId": betCourseId,
      "BranchCode": betBranchCode,
      "Sem": betSem,
      "MonthYear": "",
      "StudId": studId,
    };

    // Print the request body for debugging
    print('Request Body: $requestBody');

    final response = await http.post(
      Uri.parse('https://beessoftware.cloud/CoreAPI/Android/InternalExamTimeTableDisplay'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print(responseData);
      final List<dynamic> timetableList = responseData['internalExamTimeTableDisplayList'];
      return timetableList.map((entry) => Map<String, dynamic>.from(entry)).toList();
    } else {
      throw Exception('Failed to fetch course and curriculum ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text(
          'Internal Timetable',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<InternalExam>>(
        future: internalExamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final List<InternalExam> internalExams = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<InternalExam>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Select Exam',
                    ),
                    items: internalExams.map((InternalExam exam) {
                      return DropdownMenuItem<InternalExam>(
                        value: exam,
                        child: Text(exam.examName ?? '-Select ExamName-'),
                      );
                    }).toList(),
                    onChanged: (InternalExam? newValue) {
                      setState(() {
                        selectedExam = newValue;
                        selectedExamDivision = null;
                        internalExamDivisions = [];
                        timetableEntries = [];
                      });
                      if (newValue != null) {
                        fetchInternalExamDivisions(newValue.examId).then((divisions) {
                          setState(() {
                            internalExamDivisions = divisions;
                          });
                        });
                      }
                    },
                  ),
                ),
                if (internalExamDivisions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<InternalExamDivision>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Exam Division',
                      ),
                      items: internalExamDivisions.map((InternalExamDivision division) {
                        return DropdownMenuItem<InternalExamDivision>(
                          value: division,
                          child: Text(division.examDivName ?? '-Select ExamDivision-'),
                        );
                      }).toList(),
                      onChanged: (InternalExamDivision? newValue) {
                        setState(() {
                          selectedExamDivision = newValue;
                          timetableEntries = [];
                        });
                        if (newValue != null && selectedExam != null) {
                          fetchCourseAndCurId(selectedExam!.examId, newValue.examDivId).then((entries) {
                            setState(() {
                              timetableEntries = entries;
                            });
                          });
                        }
                      },
                    ),
                  ),
                // Display list view or no data message based on selection
                if (selectedExamDivision != null && timetableEntries.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: timetableEntries.length,
                      itemBuilder: (context, index) {
                        final entry = timetableEntries[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black),
                          ),
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(
                              entry['subjectName'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Session',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.yellow[800],
                                  ),
                                ),
                                Text(
                                  '${entry['sessionName']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow[800],
                                  ),
                                ),
                                Text(
                                  '${entry['date']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else if (selectedExamDivision != null && timetableEntries.isEmpty)
                  const Center(
                    child: Text('No data available'),
                  ),
              ],
            );
          } else {
            return const Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }
}

class InternalExam {
  final int examId;
  final String? examName;

  InternalExam({required this.examId, this.examName});

  factory InternalExam.fromJson(Map<String, dynamic> json) {
    return InternalExam(
      examId: json['examId'] as int,
      examName: json['examName'] as String?,
    );
  }
}

class InternalExamDivision {
  final int examDivId;
  final String? examDivName;

  InternalExamDivision({required this.examDivId, this.examDivName});

  factory InternalExamDivision.fromJson(Map<String, dynamic> json) {
    return InternalExamDivision(
      examDivId: json['examDivId'] as int,
      examDivName: json['examDivName'] as String?,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InternalTimeTablePage(),
  ));
}
