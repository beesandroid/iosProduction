import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Appdrawer/Notifications_view.dart';
import '../Appdrawer/customDrawer.dart';
import '../HistoricalTimeTables/ExternalTimeTablePage.dart';
import '../HistoricalTimeTables/InternalTimeTablePage.dart';
import '../views/PROVIDER.dart';
import '../views/betprovider.dart';

class ExamTimeTable extends StatefulWidget {
  const ExamTimeTable({Key? key}) : super(key: key);

  @override
  State<ExamTimeTable> createState() => _ExamTimeTableState();
}

class _ExamTimeTableState extends State<ExamTimeTable> {
  int _expandedIndex = -1;
  List<Map<String, dynamic>> _upcomingTimeTableData = [];
  List<Map<String, dynamic>> _lastThirtyDaysTimeTableData = [];
  String? _selectedHistoricalTimeTable;

  @override
  void initState() {
    super.initState();
    fetchTimetableData();
  }

  Future<void> fetchTimetableData() async {
    try {
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
      String betCurid = prefs.getString('betCurid') ??'';

      final apiUrl =
          'https://beessoftware.cloud/CoreAPI/Android/StudentRecentTimeTable';
      final requestBody = {
        "GrpCode": grpCodeValue,
        "ColCode": "PSS",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "StudId": studId,
        "CurDate": DateFormat('yyyy-MM-dd').format(DateTime.now())
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> lastThirtyDaysTimeTableList =
            jsonResponse['lastThirtyDaysTimeTableList'] ?? [];
        final List<dynamic> upComingTimeTableList =
            jsonResponse['upComingTimeTableList'] ?? [];

        setState(() {
          _lastThirtyDaysTimeTableData =
              lastThirtyDaysTimeTableList.cast<Map<String, dynamic>>();
          _upcomingTimeTableData =
              upComingTimeTableList.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to fetch timetable data');
      }
    } catch (e) {
      print('Error fetching timetable data: $e');
      // Handle error here, show a snackbar or some other UI indication
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exam Time Table',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildExpansionPanel(
                1, _lastThirtyDaysTimeTableData, 'Last 30 Days Time Table'),
            buildExpansionPanel(
                0, _upcomingTimeTableData, 'Upcoming Time Table'),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              child:
              Container(
                height: 55,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey)),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  value:
                      _selectedHistoricalTimeTable ?? '- Select Time Table -',
                  items: [
                    '- Select Time Table -',
                    'Internal Time Table',
                    'External Time Table'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedHistoricalTimeTable = newValue;
                      });
                      if (newValue == 'Internal Time Table') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InternalTimeTablePage(),
                          ),
                        );
                      } else if (newValue == 'External Time Table') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExternalTimeTablePage(),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExpansionPanel(
      int index, List<Map<String, dynamic>> data, String title) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            color: Colors.grey.shade200,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedIndex = _expandedIndex == index ? -1 : index;
                      });
                    },
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _expandedIndex = _expandedIndex == index ? -1 : index;
                      });
                    },
                    child: Icon(
                      _expandedIndex == index
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _expandedIndex == index ? _calculateExpandedHeight(data) : 0,
          child: _expandedIndex == index
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DataTable(
                      columns: const [
                        DataColumn(
                            label: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Subject',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Semester',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Exam Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Internal/External',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataColumn(
                            label: Text(
                          'Attendance',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                        // Added attendance column
                      ],
                      rows: data.isNotEmpty
                          ? data.map((data) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(data['date'] ?? 'No Data')),
                                  DataCell(Text(data['time'] ?? 'No Data')),
                                  DataCell(
                                      Text(data['subjectName'] ?? 'No Data')),
                                  DataCell(Text(data['sem'] ?? 'No Data')),
                                  DataCell(Text(data['examType'] ?? 'No Data')),
                                  DataCell(Text(
                                      data['internalExternal'] ?? 'No Data')),
                                  DataCell(
                                      Text(data['attendance'] ?? 'No Data')),
                                  // Added attendance cell
                                ],
                              );
                            }).toList()
                          : [
                              DataRow(cells: [
                                DataCell(const Text('No Data')),
                                DataCell(const Text('No Data')),
                                DataCell(const Text('No Data')),
                                DataCell(const Text('No Data')),
                                DataCell(const Text('No Data')),
                                DataCell(const Text('No Data')),
                                DataCell(const Text('No Data')),
                              ])
                            ],
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

double _calculateExpandedHeight(List<Map<String, dynamic>> data) {
  const rowHeight = 56.0; // Height of each row in the DataTable
  const headerHeight = 150.0; // Height of the header
  final rowCount = data.length;
  return rowCount * rowHeight + headerHeight;
}


void main() {
  runApp(
    MultiProvider(
      providers: [
        // Add BetStudentProvider to the list of providers
        ChangeNotifierProvider(create: (_) => BetStudentProvider()),
        // Add other providers if needed...
      ],
      child: MaterialApp(
        home: ExamTimeTable(),
      ),
    ),
  );
}
