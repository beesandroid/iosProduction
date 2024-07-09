class DashboardResponse {
  final List<StudDashBoardDetailsList> studDashBoardDetailsList;
  final String message;

  DashboardResponse({
    required this.studDashBoardDetailsList,
    required this.message,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      studDashBoardDetailsList: (json['studDashBoardDetailsList'] as List)
          .map((e) => StudDashBoardDetailsList.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
    );
  }
}

class StudDashBoardDetailsList {
  final dynamic grpCode;
  final dynamic colCode;
  final dynamic collegeId;
  final int schoolId;
  final dynamic htNo;
  final String courseId;
  final String studId;
  final String semNo;
  final String marksObtained;
  final String totMax;
  final String totPerc;
  final String totCredits;
  final String finalCgpa;
  final String sgpa;
  final String examFee;
  final String recentSem;
  final String subjectsDue;
  final String totalSubjects;
  final String gradeSystem;

  StudDashBoardDetailsList({
    required this.grpCode,
    required this.colCode,
    required this.collegeId,
    required this.schoolId,
    required this.htNo,
    required this.courseId,
    required this.studId,
    required this.semNo,
    required this.marksObtained,
    required this.totMax,
    required this.totPerc,
    required this.totCredits,
    required this.finalCgpa,
    required this.sgpa,
    required this.examFee,
    required this.recentSem,
    required this.subjectsDue,
    required this.totalSubjects,
    required this.gradeSystem,
  });

  factory StudDashBoardDetailsList.fromJson(Map<String, dynamic> json) {
    return StudDashBoardDetailsList(
      grpCode: json['grpCode'],
      colCode: json['colCode'],
      collegeId: json['collegeId'],
      schoolId: json['schoolId'],
      htNo: json['htNo'],
      courseId: json['courseId'],
      studId: json['studId'],
      semNo: json['semNo'],
      marksObtained: json['marksObtained'],
      totMax: json['totMax'],
      totPerc: json['totPerc'],
      totCredits: json['totCredits'],
      finalCgpa: json['finalCGPA'],
      sgpa: json['sgpa'],
      examFee: json['examFee'],
      recentSem: json['recentSem'],
      subjectsDue: json['subjectsDue'],
      totalSubjects: json['totalSubjects'],
      gradeSystem: json['gradeSystem'],
    );
  }
}