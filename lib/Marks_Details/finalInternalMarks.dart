import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/PROVIDER.dart';
import '../views/betprovider.dart';

class FinalInternalMarks extends StatefulWidget {
  @override
  _FinalInternalMarksState createState() => _FinalInternalMarksState();
}

class _FinalInternalMarksState extends State<FinalInternalMarks> {
  String? selectedSemester;
  List<dynamic> semesters = [];
  List<dynamic> finalInternalMarksList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSemesters();
  }

  Future<void> fetchSemesters() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolId = prefs.getInt('schoolId') ?? 0;
      String betCourseId = prefs.getString('betCourseId') ?? '';
      String userName = prefs.getString('userName') ?? '';

      setState(() {
        isLoading = true;
      });
      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPI/Android/SemDropDown'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCodeValue,
          "ColCode": "pss",
          "CollegeId": "0001",
          "SchoolId": schoolId,
          "CourseId": betCourseId,
          "AdmnNo": userName,
        }),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print(responseData);
        setState(() {
          semesters = responseData['semDropDownList'];
          if (semesters.isNotEmpty) {
            selectedSemester = semesters[0]['semester'];
            fetchFinalInternalMarks(selectedSemester!);
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load semesters');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFinalInternalMarks(String semester) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String grpCodeValue = prefs.getString('grpCode') ?? '';
      int schoolId = prefs.getInt('schoolId') ?? 0;
      int studId = prefs.getInt('studId') ?? 0;
      String betBranchcode = prefs.getString('betBranchCode') ?? '';
      String betBatch = prefs.getString('betBatch') ?? '';

      setState(() {
        isLoading = true;
      });
      final response = await http.post(
        Uri.parse('https://beessoftware.cloud/CoreAPI/Android/FinalInternalMarksDisplay'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "GrpCode": grpCodeValue,
          "ColCode": "pss",
          "CollegeId": "0001",
          "SchoolId": schoolId,
          "BranchCode": betBranchcode,
          "Sem": semester,
          "Batch": betBatch,
          "StudId": studId,
        }),
      );

      if (response.statusCode == 200) {
        print(response.body.toString());
        var responseData = jsonDecode(response.body);
        setState(() {
          finalInternalMarksList = responseData['finalInternalMarksDisplayList'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load final internal marks');
      }
    } catch (error) {
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
          'Final Internal Marks',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: Column(
        children: [
          Container(
            width: double.maxFinite,
            margin: EdgeInsets.all(20),
            child: Center(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Select Sem",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                value: selectedSemester,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSemester = newValue;
                    if (selectedSemester != null) {
                      finalInternalMarksList.clear(); // Clear the list before fetching new data
                      fetchFinalInternalMarks(selectedSemester!);
                    }
                  });
                },
                items: semesters.map<DropdownMenuItem<String>>((semester) {
                  return DropdownMenuItem<String>(
                    value: semester['semester'],
                    child: Text(semester['semester']),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : finalInternalMarksList.isEmpty && !isLoading
                ? Center(child: Text('No Data'))
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
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 100,
                      child: ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            marksData['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Max Marks: ${marksData['intMax']}',
                              style: TextStyle(
                                color: Colors.yellow[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Obtained Marks: ${marksData['marks']}',
                              style: TextStyle(
                                color: Colors.yellow[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BetStudentProvider()),
      ],
      child: MaterialApp(
        home: FinalInternalMarks(),
      ),
    ),
  );
}
