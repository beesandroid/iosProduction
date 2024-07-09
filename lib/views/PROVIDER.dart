import 'package:flutter/material.dart';


class UserProvider with ChangeNotifier {
  UserDetails? _userDetails;

  UserDetails? get userDetails => _userDetails;

  void setUserDetails(UserDetails userDetails) {
    _userDetails = userDetails;
    notifyListeners();
  }
}

class UserDetails {
  final String grpCode;
  final String colCode;
  final String collegeId;
  final String userName;
  final String password;
  final int schoolId;
  final int studUserId;
  final int studId;
  final String dataBaseCode;
  final String schoolName;
  final String description;
  final int userType;
  final int userRole;
  final int type;
  final String email;
  final String admnNo;
  final String studentStatus;
  final String acYear;
  final String finYear;
  final int acYearId;
  final int fYearId;
  final String? photo;
  final String? photo1;
  late final String imagePath;

  UserDetails({
    required this.grpCode,
    required this.colCode,
    required this.collegeId,
    required this.userName,
    required this.password,
    required this.schoolId,
    required this.studUserId,
    required this.studId,
    required this.dataBaseCode,
    required this.schoolName,
    required this.description,
    required this.userType,
    required this.userRole,
    required this.type,
    required this.email,
    required this.admnNo,
    required this.studentStatus,
    required this.acYear,
    required this.finYear,
    required this.acYearId,
    required this.fYearId,
    this.photo,
    this.photo1,
    required this.imagePath,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      grpCode: json['grpCode'],
      colCode: json['colCode'],
      collegeId: json['collegeId'],
      userName: json['userName'],
      password: json['password'],
      schoolId: json['schoolId'],
      studUserId: json['studUserId'],
      studId: json['studId'],
      dataBaseCode: json['dataBaseCode'],
      schoolName: json['schoolName'],
      description: json['description'],
      userType: json['userType'],
      userRole: json['userRole'],
      type: json['type'],
      email: json['email'],
      admnNo: json['admnNo'],
      studentStatus: json['studentStatus'],
      acYear: json['acYear'],
      finYear: json['finYear'],
      acYearId: json['acYearId'],
      fYearId: json['fYearId'],
      photo: json['photo'],
      photo1: json['photo1'],
      imagePath: json['imagePath'],
    );
  }
}