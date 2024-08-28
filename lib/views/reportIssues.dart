import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BottomNavigation_Screens/Dashboard.dart';
import 'PROVIDER.dart';
import 'betprovider.dart';

class DropdownMenus extends StatefulWidget {
  const DropdownMenus({Key? key}) : super(key: key);

  @override
  _DropdownMenusState createState() => _DropdownMenusState();
}

class _DropdownMenusState extends State<DropdownMenus> {
  String selectedMainTab = 'Timetable';
  String selectedSubTab = 'Internal';
  String selectedIssueType = 'Defect';
  String selectedSeverity = 'Critical';
  final TextEditingController _textController = TextEditingController();

  late String? betStudId;
  bool _isLoading = false;

  final List<String> mainTabs = [
    'Timetable',
    'Fee Payments',
    'Downloads',
    'Marks Details',
    'Basic Information',
  ];

  final Map<String, List<String>> subTabs = {
    'Timetable': ['Internal', 'External'],
    'Fee Payments': [
      'Regular',
      'Supplementary',
      'Re-evaluation',
      'Fee Information'
    ],
    'Downloads': ['None'],
    'Marks Details': [
      'Mid Marks',
      'Final Internal Marks',
      'Overall Performance'
    ],
    'Basic Information': ['None'],
  };

  final List<String> issueTypes = ['Defect', 'Enhancement'];
  final List<String> severities = ['Critical', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightGreen,
        title: const Text(
          'Report Issues',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDropdownMenu(mainTabs, selectedMainTab, (String? value) {
                if (value != null) {
                  setState(() {
                    selectedMainTab = value;
                    selectedSubTab = subTabs[value]!.first;
                  });
                }
              }),
              const SizedBox(height: 20),
              buildDropdownMenu(subTabs[selectedMainTab]!, selectedSubTab,
                      (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedSubTab = value;
                      });
                    }
                  }),
              const SizedBox(height: 20),
              buildDropdownMenu(issueTypes, selectedIssueType,
                      (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedIssueType = value;
                      });
                    }
                  }),
              const SizedBox(height: 20),
              buildDropdownMenu(severities, selectedSeverity,
                      (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedSeverity = value;
                      });
                    }
                  }),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  height: 220,
                  child: TextFormField(
                    controller: _textController,
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22.0),
              Center(
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {
                      _submitData(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.lightGreen),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdownMenu(
      List<String> items, String selectedValue, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedValue,
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(item),
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    betStudId = prefs.getString('betStudId');

    // Simulated fetch data delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _submitData(BuildContext context) async {
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

    final apiUrl =
        'https://mritsexams.com/CoreApi/Android/BETAppComplaintsSaving';
    final requestBody = {
      "GrpCode": grpCodeValue,
      "CollegeId": "0001",
      "ColCode": "pss",
      "IssueId": "1",
      "Studid": studId,
      "userType":userType,
      "MenuCategory": selectedMainTab,
      "SubMenuCategory": selectedSubTab,
      "IssueType": selectedIssueType,
      "severity": selectedSeverity,
      "FilePath": "",
      "Description": _textController.text,
      "UserId": "1",
      "Flag": "0",
      "Confirm": "0"
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final message = responseBody['message'] ?? 'Issue submitted successfully';
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to submit issue",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: DropdownMenus(),
  ));
}
