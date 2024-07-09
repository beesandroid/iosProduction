class DashboardModel {
  DashboardModel({
    required this.betStudentInformationList,
    required this.singleBetStudentInformationList,
    required this.status,
    required this.message,
  });

  final List<BetStudentInformationList> betStudentInformationList;
  final BetStudentInformationList? singleBetStudentInformationList;
  final int? status;
  final String? message;

  factory DashboardModel.fromJson(Map<String, dynamic> json){
    return DashboardModel(
      betStudentInformationList: json["betStudentInformationList"] == null ? [] : List<BetStudentInformationList>.from(json["betStudentInformationList"]!.map((x) => BetStudentInformationList.fromJson(x))),
      singleBetStudentInformationList: json["singleBETStudentInformationList"] == null ? null : BetStudentInformationList.fromJson(json["singleBETStudentInformationList"]),
      status: json["status"],
      message: json["message"],
    );
  }

}

class BetStudentInformationList {
  BetStudentInformationList({
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
    required this.betSmsUser,
    required this.betSmsPass,
    required this.smStype,
    required this.smsKey,
    required this.peId,
    required this.senderName,
    required this.userType,
    required this.userTypeName,
    required this.forgotTemplateSlNo,
    required this.photo,
    required this.photo1,
    required this.imagePath,
    required this.status,
  });

  final String? grpCode;
  final String? colCode;
  final String? collegeId;
  final String? userName;
  final String? admissionDate;
  final int? schoolId;
  final int? betStudId;
  final int? betStudUserId;
  final String? welcomeMessage;
  final String? rollNo;
  final String? name;
  final int? betCourseId;
  final String? betCourseName;
  final String? betBranchcode;
  final DateTime? commonDate;
  final String? dob;
  final String? aadharNo;
  final String? betSem;
  final int? betCurid;
  final String? betCurName;
  final int? betAcyearId;
  final String? betAcYear;
  final int? betFinYearId;
  final String? betFinYear;
  final String? betBatch;
  final int? betDetainee;
  final int? betSectionId;
  final String? betSectionName;
  final String? fatherName;
  final String? mobile;
  final String? email;
  final String? category;
  final String? betBranchId;
  final String? betSemId;
  final String? betStudMobile;
  final String? motherName;
  final String? betSmsUser;
  final String? betSmsPass;
  final String? smStype;
  final String? smsKey;
  final String? peId;
  final String? senderName;
  final int? userType;
  final String? userTypeName;
  final int? forgotTemplateSlNo;
  final String? photo;
  final String? photo1;
  final String? imagePath;
  final int? status;

  factory BetStudentInformationList.fromJson(Map<String, dynamic> json){
    return BetStudentInformationList(
      grpCode: json["grpCode"],
      colCode: json["colCode"],
      collegeId: json["collegeId"],
      userName: json["userName"],
      admissionDate: json["admissionDate"],
      schoolId: json["schoolId"],
      betStudId: json["betStudId"],
      betStudUserId: json["betStudUserId"],
      welcomeMessage: json["welcomeMessage"],
      rollNo: json["rollNo"],
      name: json["name"],
      betCourseId: json["betCourseId"],
      betCourseName: json["betCourseName"],
      betBranchcode: json["betBranchcode"],
      commonDate: DateTime.tryParse(json["commonDate"] ?? ""),
      dob: json["dob"],
      aadharNo: json["aadharNo"],
      betSem: json["betSem"],
      betCurid: json["betCurid"],
      betCurName: json["betCurName"],
      betAcyearId: json["betAcyearId"],
      betAcYear: json["betAcYear"],
      betFinYearId: json["betFinYearId"],
      betFinYear: json["betFinYear"],
      betBatch: json["betBatch"],
      betDetainee: json["betDetainee"],
      betSectionId: json["betSectionId"],
      betSectionName: json["betSectionName"],
      fatherName: json["fatherName"],
      mobile: json["mobile"],
      email: json["email"],
      category: json["category"],
      betBranchId: json["betBranchId"],
      betSemId: json["betSemId"],
      betStudMobile: json["betStudMobile"],
      motherName: json["motherName"],
      betSmsUser: json["betSMSUser"],
      betSmsPass: json["betSMSPass"],
      smStype: json["smStype"],
      smsKey: json["smsKey"],
      peId: json["peId"],
      senderName: json["senderName"],
      userType: json["userType"],
      userTypeName: json["userTypeName"],
      forgotTemplateSlNo: json["forgotTemplateSlNo"],
      photo: json["photo"],
      photo1: json["photo1"],
      imagePath: json["imagePath"],
      status: json["status"],
    );
  }

}