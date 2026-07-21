class SelectionModel {
  String? code;
  String? name;
  String? regionCode;

  /// `dynamic`, not `String?`, because `city.json` encodes "no province"
  /// (NCR-style cities that belong directly to a region) as boolean `false`
  /// rather than `null`/absent. `_applyProvince`'s NCR-flattening comparison
  /// relies on this — do not tighten the type without updating that logic.
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
