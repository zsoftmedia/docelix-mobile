class UnitModel {
  final String code;
  final String label;

  UnitModel({
    required this.code,
    required this.label,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}