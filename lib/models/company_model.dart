class CompanyModel {
  final int id;
  final String name;
  final String? city;
  final String? country;

  CompanyModel({
    required this.id,
    required this.name,
    this.city,
    this.country,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      city: json['city'],
      country: json['country'],
    );
  }
}