class marksDetailsList {
  List<MarksDetailsList>? markDetailsList;
  String? message;

  marksDetailsList({this.markDetailsList, this.message});

  marksDetailsList.fromJson(Map<String, dynamic> json) {
    if (json['menuDetailsList'] != null) {
      markDetailsList = <MarksDetailsList>[];
      json['menuDetailsList'].forEach((v) {
        markDetailsList!.add(new MarksDetailsList.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.markDetailsList != null) {
      data['menuDetailsList'] =
          this.markDetailsList!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class MarksDetailsList {
  Null? colCode;
  Null? collegeId;
  Null? grpCode;
  int? subCategorySl;
  String? category;
  String? subCategory;
  String? imagePath;

  MarksDetailsList(
      {this.colCode,
      this.collegeId,
      this.grpCode,
      this.subCategorySl,
      this.category,
      this.subCategory,
      this.imagePath});

  MarksDetailsList.fromJson(Map<String, dynamic> json) {
    colCode = json['colCode'];
    collegeId = json['collegeId'];
    grpCode = json['grpCode'];
    subCategorySl = json['subCategorySl'];
    category = json['category'];
    subCategory = json['subCategory'];
    imagePath = json['imagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['colCode'] = this.colCode;
    data['collegeId'] = this.collegeId;
    data['grpCode'] = this.grpCode;
    data['subCategorySl'] = this.subCategorySl;
    data['category'] = this.category;
    data['subCategory'] = this.subCategory;
    data['imagePath'] = this.imagePath;
    return data;
  }
}
