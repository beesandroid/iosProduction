class downloadDetailsList {
  List<downloadlistdetails>? downDetailsList;
  String? message;

  downloadDetailsList({this.downDetailsList, this.message});

  downloadDetailsList.fromJson(Map<String, dynamic> json) {
    if (json['menuDetailsList'] != null) {
      downDetailsList = <downloadlistdetails>[];
      json['menuDetailsList'].forEach((v) {
        downDetailsList!.add(new downloadlistdetails.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.downDetailsList != null) {
      data['menuDetailsList'] =
          this.downDetailsList!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class downloadlistdetails {
  Null? colCode;
  Null? collegeId;
  Null? grpCode;
  int? subCategorySl;
  String? category;
  String? subCategory;
  String? imagePath;

  downloadlistdetails(
      {this.colCode,
        this.collegeId,
        this.grpCode,
        this.subCategorySl,
        this.category,
        this.subCategory,
        this.imagePath});

  downloadlistdetails.fromJson(Map<String, dynamic> json) {
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