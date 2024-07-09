class FeepaymentResponse {
  List<MenuDetailsList>? menuDetailsList;
  String? message;

  FeepaymentResponse({this.menuDetailsList, this.message});

  FeepaymentResponse.fromJson(Map<String, dynamic> json) {
    if (json['menuDetailsList'] != null) {
      menuDetailsList = <MenuDetailsList>[];
      json['menuDetailsList'].forEach((v) {
        menuDetailsList!.add(new MenuDetailsList.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.menuDetailsList != null) {
      data['menuDetailsList'] =
          this.menuDetailsList!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class MenuDetailsList {
  Null? colCode;
  Null? collegeId;
  Null? grpCode;
  int? subCategorySl;
  String? category;
  String? subCategory;
  String? imagePath;

  MenuDetailsList(
      {this.colCode,
        this.collegeId,
        this.grpCode,
        this.subCategorySl,
        this.category,
        this.subCategory,
        this.imagePath});

  MenuDetailsList.fromJson(Map<String, dynamic> json) {
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
