import 'dart:convert';

LocalUserRegisterModel localUserRegisterModelFromJson(String str) =>
    LocalUserRegisterModel.fromJson(json.decode(str));

String localUserRegisterModelToJson(LocalUserRegisterModel data) =>
    json.encode(data.toJson());

class LocalUserRegisterModel {
  String? grpCode;
  int? collegeId;
  String? colCode;
  int? schoolId;
  String? studId;
  int? uSerType;
  String? userName;
  String? password;
  int? mobile;
  String? email;
  int? registrationFee;
  String? modiDt;

  LocalUserRegisterModel({
    this.grpCode,
    this.collegeId,
    this.colCode,
    this.schoolId,
    this.studId,
    this.uSerType,
    this.userName,
    this.password,
    this.mobile,
    this.email,
    this.registrationFee,
    this.modiDt,
  });

  factory LocalUserRegisterModel.fromJson(Map<String, dynamic> json) =>
      LocalUserRegisterModel(
        grpCode: json["GrpCode"],
        collegeId: json["CollegeId"],
        colCode: json["ColCode"],
        schoolId: json["SchoolId"],
        studId: json["StudID"],
        uSerType: json["USerType"],
        userName: json["UserName"],
        password: json["Password"],
        mobile: json["Mobile"],
        email: json["Email"],
        registrationFee: json["RegistrationFee"],
        modiDt: json["ModiDt"],
      );

  Map<String, dynamic> toJson() => {
        "GrpCode": grpCode,
        "CollegeId": collegeId,
        "ColCode": colCode,
        "SchoolId": schoolId,
        "StudID": studId,
        "USerType": uSerType,
        "UserName": userName,
        "Password": password,
        "Mobile": mobile,
        "Email": email,
        "RegistrationFee": registrationFee,
        "ModiDt": modiDt,
      };
}
