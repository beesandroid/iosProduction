import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: OverallPerformance(),
  ));
}

class OverallPerformance extends StatefulWidget {
  @override
  _OverallPerformanceState createState() => _OverallPerformanceState();
}

class _OverallPerformanceState extends State<OverallPerformance> {
  String? _selectedSemester;
  List<String> _semesterList = [];
  List<dynamic> finalInternalMarksList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSemesters();
  }

  Future<void> fetchSemesters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String grpCodeValue = prefs.getString('grpCode') ?? '';
    int schoolId = prefs.getInt('schoolId') ?? 0;
    int studId = prefs.getInt('studId') ?? 0;
    final url = 'https://mritsexams.com/CoreApi/Android/AllSems';
    final requestPayload = {
      "GrpCode": grpCodeValue,
      "ColCode": "pss",
      "CollegeId": "0001",
      "SchoolId": schoolId,
      "StudId": studId
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestPayload),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> semesters = data['showAllStudSemsList'];

      setState(() {
        _semesterList = semesters.map((semester) => semester['sem'].toString()).toList();
        _selectedSemester = _semesterList.isNotEmpty ? _semesterList[0] : null;
      });
    } else {
      throw Exception('Failed to load semesters');
    }
  }

  Future<void> fetchFinalInternalMarks(String semester) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolId = prefs.getInt('schoolId') ?? 0;
      int studId = prefs.getInt('studId') ?? 0;

      setState(() {
        isLoading = true;
      });

      final response = await http.post(
        Uri.parse('https://mritsexams.com/CoreApi/Android/OverAllMarksSemWise'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCodeValue,
          "ColCode": "pss",
          "CollegeId": "0001",
          "SchoolId": schoolId,
          "StudId": studId,
          "Semester": semester
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        setState(() {
          finalInternalMarksList = responseData['overallMarksFinalList'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load final internal marks');
      }
    } catch (error) {
      print('Error fetching final internal marks: $error');
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
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Overall Performance',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Sem",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              isExpanded: true,
              value: _selectedSemester,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSemester = newValue;
                  if (_selectedSemester != null && _selectedSemester != '--Select Semester--') {
                    finalInternalMarksList.clear();
                    fetchFinalInternalMarks(_selectedSemester!);
                  }
                });
              },
              items: _semesterList.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())

                : ListView.builder(
              itemCount: finalInternalMarksList.length,
              itemBuilder: (context, index) {
                var marksData = finalInternalMarksList[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  child: ListTile(
                    title: Text(
                      marksData['subName'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grade',
                              style: TextStyle(color: Colors.yellow[800], fontWeight: FontWeight.bold),
                            ),
                            Text('Credits',
                                style: TextStyle(color: Colors.yellow[800], fontWeight: FontWeight.bold))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${marksData['grade']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${marksData['credits']}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Status',
                                style: TextStyle(color: Colors.yellow[800], fontWeight: FontWeight.bold)),
                            Text('Month/Year',
                                style: TextStyle(color: Colors.yellow[800], fontWeight: FontWeight.bold))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${marksData['status']}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${marksData['monthYear']}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
