class SelectionModel {
  String? code;
  String? name;
  String? regionCode;
  dynamic provinceCode;

  SelectionModel({this.code, this.name, this.regionCode, this.provinceCode});

  factory SelectionModel.fromJson(Map<String, dynamic> json) => SelectionModel(
        code: json.containsKey('code') ? json['code'] : '',
        name: json.containsKey('name')
            ? json['name'].toString().toUpperCase()
            : '',
        regionCode: json.containsKey('regionCode') ? json['regionCode'] : '',
        provinceCode:
            json.containsKey('provinceCode') ? json['provinceCode'] : '',
      );
}
