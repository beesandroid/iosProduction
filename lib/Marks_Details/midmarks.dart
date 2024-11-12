import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/PROVIDER.dart';
import '../views/betprovider.dart';

class MidMarks extends StatefulWidget {

  @override
  _MidMarksState createState() => _MidMarksState();
}

class _MidMarksState extends State<MidMarks> {
  String? selectedExamName;
  bool isLoading = false;
  String errorMessage = '';
  List<dynamic> examList = [];
  List<dynamic>? midExamResultsDisplayListData;

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

    final requestBody = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolId,
      "ExamId": "0",
      "StudId": studId,
      "Flag": "0"
    };

    print("Request Body: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        Uri.parse('https://mritsexams.com/CoreApi/Android/IntMarksDetails'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print("Exam List Response Data: ${responseData}");

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
      midExamResultsDisplayListData = null;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolId = prefs.getInt('schoolId') ?? 0;
      int studId = prefs.getInt('studId') ?? 0;
      String betSem = prefs.getString('betSem') ?? '';

      final requestBody = {
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolId,
        "ExamId": examId,
        "StudId": studId,
        "Flag": "1",
        "Semester": betSem
      };

      print("Request Body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(
            'https://mritsexams.com/CoreAPI/Android/MidExamResultsDisplay'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      print('API Response Data: $responseData');

      // Adjust the key based on the actual response
      List<dynamic>? dataList;
      if (responseData['midExamResultsDisplayList'] != null) {
        dataList = responseData['midExamResultsDisplayList'];
      } else if (responseData['intMarksDetailsList1'] != null) {
        dataList = responseData['intMarksDetailsList1'];
      } else if (responseData['marksList'] != null) {
        dataList = responseData['marksList'];
      } else {
        dataList = null;
      }

      if (dataList != null && dataList.isNotEmpty) {
        setState(() {
          midExamResultsDisplayListData = dataList;
        });
      } else {
        setState(() {
          midExamResultsDisplayListData = null;
          errorMessage = responseData['message'] ?? 'No data available';
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

  // Remove the buildExamDetails method if it's no longer needed

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
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Mid Marks',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Select Exam",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        value: selectedExamName,
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedExamName = newValue;
                            // Find the exam element matching the newValue
                            var examElement = examList.firstWhere(
                              (element) => element['examName'] == newValue,
                              orElse: () => null,
                            );
                            if (examElement != null) {
                              var examId = examElement['examId'].toString();
                              fetchUpdatedExamDetails(examId);
                            } else {
                              // Handle the case where examElement is null
                              errorMessage = 'Exam not found';
                              midExamResultsDisplayListData = null;
                            }
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
                    if (midExamResultsDisplayListData != null &&
                        midExamResultsDisplayListData!.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: midExamResultsDisplayListData!.length,
                        itemBuilder: (context, index) {
                          var item = midExamResultsDisplayListData![index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                item['subName']?.toString() ?? 'N/A',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Total Marks: ${item['totalTotMarks']?.toString() ?? 'N/A'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[800],
                                ),
                              ),
                              children: [
                                // Display Exam Division Details if available
                                if (item['examDivDetails'] != null &&
                                    item['examDivDetails'].isNotEmpty)
                                  ...item['examDivDetails']
                                      .map<Widget>((detail) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Divider(),
                                          Text(
                                            detail['examDivName']?.toString() ??
                                                'N/A',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // Marks and Max Marks Labels for each Exam Division
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Marks',
                                                style: TextStyle(
                                                    color: Colors.yellow[800],
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                'Max Marks',
                                                style: TextStyle(
                                                    color: Colors.yellow[800],
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          // Marks and Max Marks Values for each Exam Division
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${detail['totMarks']?.toString() ?? 'N/A'}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                '${detail['intMax']?.toString() ?? 'N/A'}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          );
                        },
                      )
                    else if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            Text(errorMessage, style: TextStyle(fontSize: 16)),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('No data available',
                            style: TextStyle(fontSize: 16)),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}


