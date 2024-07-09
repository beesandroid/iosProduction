import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Fee_payment/regular_payment.dart';

class BetStudentProvider extends ChangeNotifier {
  StudentInformation? _studentInformation;

  StudentInformation? get studentInformation => _studentInformation;

  Future<void> fetchStudentInformation() async {
    try {
      final studentInfo = await fetchStudentInfoFromAPI();
      _studentInformation = studentInfo;
      notifyListeners();
    } catch (e) {
      print('Error fetching student information: $e');
      // Handle error
    }
  }
  Future<StudentInformation?> fetchStudentInfoFromAPI() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String grpCodeValue = prefs.getString('grpCode') ?? '';
      String userNameValue = prefs.getString('userName') ?? '';

      String apiUrl =
          'https://beessoftware.cloud/CoreAPI/Flutter/BETStudentInformation';
      Map<String, String> requestBody = {
        'grpCode': grpCodeValue,
        'userName': userNameValue,
      };

      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );


      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        List<dynamic>? detailsList =
        responseBody['betStudentInformationList'] as List?;

        if (detailsList != null && detailsList.isNotEmpty) {
          // Create an instance of StudentInformation from the fetched data
          return StudentInformation.fromJson(detailsList.first);
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null; // Return null in case of failure or empty response
  }

}

class StudentInformation {
  final String grpCode;
  final String colCode;
  final String collegeId;
  final String userName;
  final String admissionDate;
  final int schoolId;
  final int betStudId;
  final int betStudUserId;
  final String welcomeMessage;
  final String rollNo;
  final String name;
  final int betCourseId;
  final String betCourseName;
  final String betBranchcode;
  final String commonDate;
  final String dob;
  final String aadharNo;
  final String betSem;
  final int betCurid;
  final String betCurName;
  final int betAcyearId;
  final String betAcYear;
  final int betFinYearId;
  final String betFinYear;
  final String betBatch;
  final int betDetainee;
  final int betSectionId;
  final String betSectionName;
  final String fatherName;
  final String mobile;
  final String email;
  final String category;
  final String betBranchId;
  final String betSemId;
  final String betStudMobile;
  final String motherName;
  final String betSMSUser;
  final String betSMSPass;
  final String smStype;
  final String smsKey;
  final String peId;

  StudentInformation({
    required this.grpCode,
    required this.colCode,
    required this.collegeId,
    required this.userName,
    required this.admissionDate,
    required this.schoolId,
    required this.betStudId,
    required this.betStudUserId,
    required this.welcomeMessage,
    required this.rollNo,
    required this.name,
    required this.betCourseId,
    required this.betCourseName,
    required this.betBranchcode,
    required this.commonDate,
    required this.dob,
    required this.aadharNo,
    required this.betSem,
    required this.betCurid,
    required this.betCurName,
    required this.betAcyearId,
    required this.betAcYear,
    required this.betFinYearId,
    required this.betFinYear,
    required this.betBatch,
    required this.betDetainee,
    required this.betSectionId,
    required this.betSectionName,
    required this.fatherName,
    required this.mobile,
    required this.email,
    required this.category,
    required this.betBranchId,
    required this.betSemId,
    required this.betStudMobile,
    required this.motherName,
    required this.betSMSUser,
    required this.betSMSPass,
    required this.smStype,
    required this.smsKey,
    required this.peId,
  });

  factory StudentInformation.fromJson(Map<String, dynamic> json) {
    return StudentInformation(
        grpCode: json['grpCode'] ?? '',
        colCode: json['colCode'] ?? '',
        collegeId: json['collegeId'] ?? '',
        userName: json['userName'] ?? '',
        admissionDate: json['admissionDate'] ?? '',
        schoolId: json['schoolId'] ?? 0,
        betStudId: json['betStudId'] ?? 0,
        betStudUserId: json['betStudUserId'] ?? 0,
        welcomeMessage: json['welcomeMessage'] ?? '',
        rollNo: json['rollNo'] ?? '',
        name: json['name'] ?? '',
        betCourseId: json['betCourseId'] ?? 0,
        betCourseName: json['betCourseName'] ?? '',
        betBranchcode: json['betBranchcode'] ?? '',
        commonDate: json['commonDate'] ?? '',
        dob: json['dob'] ?? '',
        aadharNo: json['aadharNo'] ?? '',
        betSem: json['betSem'] ?? '',
        betCurid: json['betCurid'] ?? 0,
        betCurName: json['betCurName'] ?? '',
        betAcyearId: json['betAcyearId'] ?? 0,
        betAcYear: json['betAcYear'] ?? '',
        betFinYearId: json['betFinYearId'] ?? 0,
        betFinYear: json['betFinYear'] ?? '',
        betBatch: json['betBatch'] ?? '',
        betDetainee: json['betDetainee'] ?? 0,
        betSectionId: json['betSectionId'] ?? 0,
        betSectionName: json['betSectionName'] ?? '',
        fatherName: json['fatherName'] ?? '',
        mobile: json['mobile'] ?? '',
        email: json['email'] ?? '',
        category: json['category'] ?? '',
        betBranchId: json['betBranchId'] ?? '',
      betSemId: json['betSemId'] ?? '',
      betStudMobile: json['betStudMobile'] ?? '',
      motherName: json['motherName'] ?? '',
      betSMSUser: json['betSMSUser'] ?? '',
      betSMSPass: json['betSMSPass'] ?? '',
      smStype: json['smStype'] ?? '',
      smsKey: json['smsKey'] ?? '',
      peId: json['peId'] ?? '',
    );
  }
}

