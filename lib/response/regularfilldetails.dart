class StudFeeFillDetails {
  final String? grpCode;
  final String? colCode;
  final String? collegeId;
  final String? htNo;
  final int schoolId;
  final int acYearId;
  final String? regDt;
  final String? regFineDt;
  final String? supDt;
  final String? supFineDt;
  final int entryNo;
  final int courseId;
  final String? sem;
  final String? regIIndFine;
  final String? regIIIrdFine;
  final String? supIIndFine;
  final String? supIIIrdFine;
  final int type;
  final String? regStartDt;
  final String? supStartDt;
  final int suppleExamMonth;
  final int suppleExamYear;
  final int examMonth;
  final int examYear;
  final String? regIVthFine;
  final String? regVthFine;
  final String? supIVthFine;
  final String? regExamMonth;
  final String? suppExamMonth;
  final String? curDate;
  final int restrictGrade;
  final int curId;
  final String? batch;
  final int studFee;
  final int studFine;
  final int feeCollStatus;
  final String? message;
  final int feeStructId;
  final int userId;

  StudFeeFillDetails({
    this.grpCode,
    this.colCode,
    this.collegeId,
    this.htNo,
    required this.schoolId,
    required this.acYearId,
    this.regDt,
    this.regFineDt,
    this.supDt,
    this.supFineDt,
    required this.entryNo,
    required this.courseId,
    this.sem,
    this.regIIndFine,
    this.regIIIrdFine,
    this.supIIndFine,
    this.supIIIrdFine,
    required this.type,
    this.regStartDt,
    this.supStartDt,
    required this.suppleExamMonth,
    required this.suppleExamYear,
    required this.examMonth,
    required this.examYear,
    this.regIVthFine,
    this.regVthFine,
    this.supIVthFine,
    this.regExamMonth,
    this.suppExamMonth,
    this.curDate,
    required this.restrictGrade,
    required this.curId,
    this.batch,
    required this.studFee,
    required this.studFine,
    required this.feeCollStatus,
    this.message,
    required this.feeStructId,
    required this.userId,
  });

  factory StudFeeFillDetails.fromJson(Map<String, dynamic> json) {
    return StudFeeFillDetails(
      grpCode: json['grpCode'],
      colCode: json['colCode'],
      collegeId: json['collegeId'],
      htNo: json['htNo'],
      schoolId: json['schoolId'],
      acYearId: json['acYearId'],
      regDt: json['regDt'],
      regFineDt: json['regFineDt'],
      supDt: json['supDt'],
      supFineDt: json['supFineDt'],
      entryNo: json['entryNo'],
      courseId: json['courseId'],
      sem: json['sem'],
      regIIndFine: json['regIIndFine'],
      regIIIrdFine: json['regIIIrdFine'],
      supIIndFine: json['supIIndFine'],
      supIIIrdFine: json['supIIIrdFine'],
      type: json['type'],
      regStartDt: json['regStartDt'],
      supStartDt: json['supStartDt'],
      suppleExamMonth: json['suppleExamMonth'],
      suppleExamYear: json['suppleExamYear'],
      examMonth: json['examMonth'],
      examYear: json['examYear'],
      regIVthFine: json['regIVthFine'],
      regVthFine: json['regVthFine'],
      supIVthFine: json['supIVthFine'],
      regExamMonth: json['regExamMonth'],
      suppExamMonth: json['suppExamMonth'],
      curDate: json['curDate'],
      restrictGrade: json['restrictGrade'],
      curId: json['curId'],
      batch: json['batch'],
      studFee: json['studFee'],
      studFine: json['studFine'],
      feeCollStatus: json['feeCollStatus'],
      message: json['message'],
      feeStructId: json['feeStructId'],
      userId: json['userId'],
    );
  }
}
