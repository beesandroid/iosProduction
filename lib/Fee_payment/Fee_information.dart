import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/PROVIDER.dart';
import '../views/betprovider.dart';

class FeeInformation extends StatefulWidget {
  const FeeInformation({Key? key}) : super(key: key);

  @override
  State<FeeInformation> createState() => _FeeInformationState();
}

class _FeeInformationState extends State<FeeInformation> {
  late Future<List<FeeDetails>> feeDetailsFuture;
  late Future<List<SupplyDetails>> supplyDetailsFuture;
  late Future<List<RevalFeeDetails>> revalFeeDetailsFuture;
  late Future<List<RevalFeeDateDetails>> revalFeeDateDetailsFuture;

  @override
  void initState() {
    super.initState();
    feeDetailsFuture = fetchFeeDetails();
    supplyDetailsFuture = fetchSupplyDetails();
    revalFeeDetailsFuture = fetchRevalFeeDetails();
    revalFeeDateDetailsFuture = fetchRevalFeeDateDetails();
  }

  Future<List<FeeDetails>> fetchFeeDetails() async {
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
    String collegeId = prefs.getString('collegeId') ?? '';
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/FeeDetials'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "HtNo": userName,
        "Sem": "",
        "Flag": "0"
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['feeDetialsList'];
      return data.map((json) => FeeDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load fee details');
    }
  }

  Future<List<SupplyDetails>> fetchSupplyDetails() async {
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
    String collegeId = prefs.getString('collegeId') ?? '';
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/FeeDetials'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "HtNo": userName,
        "Sem": "",
        "Flag": "1"
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['feeDetialsList1'];
      return data.map((json) => SupplyDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load supply details');
    }
  }

  Future<List<RevalFeeDetails>> fetchRevalFeeDetails() async {
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
    String collegeId = prefs.getString('collegeId') ?? '';
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/FeeDetials'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode": grpCodeValue,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "HtNo":userName,
        "Sem": "",
        "Flag": "2"
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body)['revalFeeDetailsList'];
      return data.map((json) => RevalFeeDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load revaluation fee details');
    }
  }

  Future<List<RevalFeeDateDetails>> fetchRevalFeeDateDetails() async {
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
    String collegeId = prefs.getString('collegeId') ?? '';
    final response = await http.post(
      Uri.parse('https://mritsexams.com/CoreApi/Android/FeeDetials'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "GrpCode":grpCodeValue ,
        "ColCode": "pss",
        "CollegeId": "0001",
        "SchoolId": schoolid,
        "HtNo": userName,
        "Sem": "",
        "Flag": "2"
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body)['revalFeeDateDetailsList'];
      return data.map((json) => RevalFeeDateDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load revaluation fee date details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text(
          'Fee Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(height: 50,
                width: double.maxFinite,
                decoration: BoxDecoration(color: Colors.lightGreen),
                child: Center(child: Text("Regular Fee Informations",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),))),
          ),
          FutureBuilder<List<FeeDetails>>(
            future: feeDetailsFuture,
            builder: (context, feeSnapshot) {
              if (feeSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (feeSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${feeSnapshot.error}'),
                );
              } else if (feeSnapshot.hasData) {
                final List<FeeDetails> feeDetails = feeSnapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:
                   Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: DataTable(
                      columns: const [   DataColumn(label: Text('Fine Date')),
                        DataColumn(label: Text('Semester')),

                        DataColumn(label: Text('Fines')),
                      ],
                      rows: feeDetails.map((feeDetail) {
                        return DataRow(
                          cells: [DataCell(Text(feeDetail.fineDate ?? '')),
                            DataCell(Text(feeDetail.sem ?? '')),

                            DataCell(Text(feeDetail.fines ?? '')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Text('No fee data available'),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(height: 50,
                width: double.maxFinite,
                decoration: BoxDecoration(color: Colors.lightGreen),
                child: Center(child: Text("Supply Fee Informations",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),))),
          ),
          FutureBuilder<List<SupplyDetails>>(
            future: supplyDetailsFuture,
            builder: (context, supplySnapshot) {
              if (supplySnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (supplySnapshot.hasError) {
                return Center(
                  child: Text('Error: ${supplySnapshot.error}'),
                );
              } else if (supplySnapshot.hasData) {
                final List<SupplyDetails> supplyDetails = supplySnapshot.data!;
                if (supplyDetails.isEmpty) {
                  return Center(
                    child: Text('No data'),
                  );
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Semester')),
                          DataColumn(label: Text('One Sub')),
                          DataColumn(label: Text('Two Sub')),

                          DataColumn(label: Text('Three Sub')),
                          DataColumn(label: Text('Four Sub')),
                          DataColumn(label: Text('Proj Work')),
                          DataColumn(label: Text('Grade Sub')),
                          DataColumn(label: Text('Grade Fee')),
                          DataColumn(label: Text('Fine')),
                          DataColumn(label: Text('IInd Fine')),
                          DataColumn(label: Text('IIIrd Fine')),
                          DataColumn(label: Text('IVth Fine')),
                          DataColumn(label: Text('Vth Fine')),

                        ],
                        rows: supplyDetails.map((supplyDetail) {
                          return DataRow(
                            cells: [
                              DataCell(Text(supplyDetail.sem ?? '')),
                              DataCell(Text(supplyDetail.oneSub ?? '')),
                              DataCell(Text(supplyDetail.twoSub ?? '')),

                              DataCell(Text(supplyDetail.threeSub ?? '')),
                              DataCell(Text(supplyDetail.fourSub ?? '')),
                              DataCell(Text(supplyDetail.projWork ?? '')),
                              DataCell(Text(supplyDetail.gradeSub ?? '')),
                              DataCell(Text(supplyDetail.gradeFee ?? '')),
                              DataCell(Text(supplyDetail.fine ?? '')),
                              DataCell(Text(supplyDetail.iIndFine ?? '')),
                              DataCell(Text(supplyDetail.iiIrdFine ?? '')),
                              DataCell(Text(supplyDetail.iVthFine ?? '')),
                              DataCell(Text(supplyDetail.vthFine ?? '')),

                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }
              } else {
                return Center(
                  child: Text('No data'),
                );
              }
            },
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(height: 50,
                width: double.maxFinite,
                decoration: BoxDecoration(color: Colors.lightGreen),
                child: Center(child: Text("Re-Evaluation Informations",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20),))),
          ),
          FutureBuilder<List<RevalFeeDateDetails>>(
            future: revalFeeDateDetailsFuture,
            builder: (context, revalFeeDateSnapshot) {
              if (revalFeeDateSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (revalFeeDateSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${revalFeeDateSnapshot.error}'),
                );
              } else if (revalFeeDateSnapshot.hasData) {
                final List<RevalFeeDateDetails> revalFeeDateDetails =
                    revalFeeDateSnapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Semester')),
                          DataColumn(label: Text('Month Year')),
                          DataColumn(label: Text('Exam Type')),
                          DataColumn(label: Text('Start Date')),
                          DataColumn(label: Text('End Date')),
                          DataColumn(label: Text('Fine End Date')),
                        ],
                        rows: revalFeeDateDetails.map((revalFeeDateDetail) {
                          return DataRow(
                            cells: [
                              DataCell(Text(revalFeeDateDetail.sem ?? '')),
                              DataCell(Text(revalFeeDateDetail.monthYear ?? '')),
                              DataCell(Text(revalFeeDateDetail.examType ?? '')),
                              DataCell(Text(revalFeeDateDetail.startDt ?? '')),
                              DataCell(Text(revalFeeDateDetail.endDt ?? '')),
                              DataCell(Text(revalFeeDateDetail.fineEndDt ?? '')),
                            ],
                          );
                        }).toList(),
                      ),
                                       ),
                   ),
                );
              } else {
                return Center(
                  child: Text('No revaluation fee date details available'),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class FeeDetails {
  final String? sem;
  final String? entryNo;
  final String? fineDate;
  final String? fines;

  FeeDetails({
    required this.sem,
    required this.entryNo,
    required this.fineDate,
    required this.fines,
  });

  factory FeeDetails.fromJson(Map<String, dynamic> json) {
    return FeeDetails(
      sem: json['sem'] as String?,
      entryNo: json['entryNo'] as String?,
      fineDate: json['fineDate'] as String?,
      fines: json['fines'] as String?,
    );
  }
}

class SupplyDetails {
  final String? sem;
  final String? courseId;
  final String? feeStructId;
  final String? twoSub;
  final String? oneSub;
  final String? threeSub;
  final String? fourSub;
  final String? projWork;
  final String? gradeSub;
  final String? gradeFee;
  final String? fine;
  final String? iIndFine;
  final String? iiIrdFine;
  final String? iVthFine;
  final String? vthFine;
  final String? curId;
  final String? batch;

  SupplyDetails({
    required this.sem,
    required this.courseId,
    required this.feeStructId,
    required this.twoSub,
    required this.oneSub,
    required this.threeSub,
    required this.fourSub,
    required this.projWork,
    required this.gradeSub,
    required this.gradeFee,
    required this.fine,
    required this.iIndFine,
    required this.iiIrdFine,
    required this.iVthFine,
    required this.vthFine,
    required this.curId,
    required this.batch,
  });

  factory SupplyDetails.fromJson(Map<String, dynamic> json) {
    return SupplyDetails(
      sem: json['sem'] as String?,
      courseId: json['courseId'] as String?,
      feeStructId: json['feeStructId'] as String?,
      twoSub: json['twoSub'] as String?,
      oneSub: json['oneSub'] as String?,
      threeSub: json['threeSub'] as String?,
      fourSub: json['fourSub'] as String?,
      projWork: json['projWork'] as String?,
      gradeSub: json['gradeSub'] as String?,
      gradeFee: json['gradeFee'] as String?,
      fine: json['fine'] as String?,
      iIndFine: json['iIndFine'] as String?,
      iiIrdFine: json['iiIrdFine'] as String?,
      iVthFine: json['iVthFine'] as String?,
      vthFine: json['vthFine'] as String?,
      curId: json['curId'] as String?,
      batch: json['batch'] as String?,
    );
  }
}

class RevalFeeDetails {
  final String? reValFee;
  final String? reCountFee;
  final String? reValFine;
  final int? entryNo;

  RevalFeeDetails({
    required this.reValFee,
    required this.reCountFee,
    required this.reValFine,
    required this.entryNo,
  });

  factory RevalFeeDetails.fromJson(Map<String, dynamic> json) {
    return RevalFeeDetails(
      reValFee: json['reValFee'] as String?,
      reCountFee: json['reCountFee'] as String?,
      reValFine: json['reValFine'] as String?,
      entryNo: json['entryNo'] as int?,
    );
  }
}

class RevalFeeDateDetails {
  final String? sem;
  final String? monthYear;
  final String? examType;
  final String? startDt;
  final String? endDt;
  final String? fineEndDt;

  RevalFeeDateDetails({
    required this.sem,
    required this.monthYear,
    required this.examType,
    required this.startDt,
    required this.endDt,
    required this.fineEndDt,
  });

  factory RevalFeeDateDetails.fromJson(Map<String, dynamic> json) {
    return RevalFeeDateDetails(
      sem: json['sem'] as String?,
      monthYear: json['monthYear'] as String?,
      examType: json['examType'] as String?,
      startDt: json['startDt'] as String?,
      endDt: json['endDt'] as String?,
      fineEndDt: json['fineEndDt'] as String?,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FeeInformation(),
  ));
}
