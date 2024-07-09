import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/PROVIDER.dart';
import '../views/betprovider.dart';

class midMarks extends StatefulWidget {
  @override
  _midMarksState createState() => _midMarksState();
}

class _midMarksState extends State<midMarks> {
  String? selectedExamName;
  bool isLoading = false;
  String errorMessage = '';
  List<dynamic> examList = [];
  Map<String, dynamic>? intMarksDetailsList1Data;

  @override
  void initState() {
    super.initState();
    fetchExamDetails();
  }

  Future<void> fetchExamDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;

    int studId = prefs.getInt('studId') ?? 0;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPI/Android/IntMarksDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCodeValue,
          "ColCode": "pss",
          "CollegeId": "0001",
          "SchoolId": schoolId,
          "ExamId": "0",
          "StudId": studId,
          "Flag": "0"
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        examList = responseData['intMarksDetailsList2'];

        setState(() {
          if (examList.isNotEmpty) {
            selectedExamName = examList[0]['examName'];
            fetchUpdatedExamDetails(examList[0]['examId'].toString());
          }
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load exam details';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching exam details: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUpdatedExamDetails(String examId) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      intMarksDetailsList1Data = null;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolId = prefs.getInt('schoolId') ?? 0;

      int studId = prefs.getInt('studId') ?? 0;
      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPI/Android/IntMarksDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCodeValue,
          "ColCode": "pss",
          "CollegeId": "0001",
          "SchoolId": schoolId,
          "ExamId": examId,
          "StudId":studId,
          "Flag": "1"
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData['intMarksDetailsList1'] != null && responseData['intMarksDetailsList1'].isNotEmpty) {
          setState(() {
            intMarksDetailsList1Data = responseData['intMarksDetailsList1'][0];
          });
        } else {
          setState(() {
            intMarksDetailsList1Data = null;
            errorMessage = 'No data available';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load updated exam details';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching updated exam details: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Add navigation functionality
          },
        ),
        title: const Text(
          'Mid Marks',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body:
           SingleChildScrollView(
        child: Container(
          width: double.maxFinite,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Sem",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  value: selectedExamName,
                  isExpanded: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedExamName = newValue!;
                      fetchUpdatedExamDetails(
                        examList.firstWhere((element) => element['examName'] == newValue)['examId']
                            .toString(),
                      );
                    });
                  },
                  items: examList
                      .map(
                        (exam) => DropdownMenuItem<String>(
                      value: exam['examName'],
                      child: Text(exam['examName']),
                    ),
                  )
                      .toList(),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                ),
              ),
              if (intMarksDetailsList1Data != null)
                DataTable(
                  columns: [
                    DataColumn(label: Text('Subject Name')),
                    DataColumn(label: Text('Marks')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text(intMarksDetailsList1Data!['subjectName'])),
                      DataCell(Text(intMarksDetailsList1Data!['marks'])),
                    ]),
                  ],
                )
              else if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(errorMessage, style: TextStyle(fontSize: 16)),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No data available', style: TextStyle(fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BetStudentProvider()),
      ],
      child: MaterialApp(
        home: midMarks(),
      ),
    ),
  );
}
