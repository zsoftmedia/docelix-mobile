class LedgerAccountModel {
  final int id;
  final int companyId;
  final String code;
  final String name;
  final String accountType;
  final String normalSide;
  final String currency;
  final bool isSystem;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? nameDe;
  final String? nameAr;
  final String? mainHead;
  final String? subhead;
  final int? groupOrder;

  const LedgerAccountModel({
    required this.id,
    required this.companyId,
    required this.code,
    required this.name,
    required this.accountType,
    required this.normalSide,
    required this.currency,
    required this.isSystem,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.nameDe,
    this.nameAr,
    this.mainHead,
    this.subhead,
    this.groupOrder,
  });

  factory LedgerAccountModel.fromJson(Map<String, dynamic> json) {
    return LedgerAccountModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      companyId: (json['company_id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      accountType: json['account_type']?.toString() ?? 'asset',
      normalSide: json['normal_side']?.toString() ?? 'debit',
      currency: json['currency']?.toString() ?? 'EUR',
      isSystem: json['is_system'] == true,
      isActive: json['is_active'] != false,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      nameDe: json['name_de']?.toString(),
      nameAr: json['name_ar']?.toString(),
      mainHead: json['main_head']?.toString(),
      subhead: json['subhead']?.toString(),
      groupOrder: (json['group_order'] as num?)?.toInt(),
    );
  }

  String get displayType {
    final type = accountType.trim().toLowerCase();
    if (type.isEmpty) return 'Asset';
    return type[0].toUpperCase() + type.substring(1);
  }

  String get displayNormalSide {
    final side = normalSide.trim().toLowerCase();
    if (side.isEmpty) return 'Debit';
    return side[0].toUpperCase() + side.substring(1);
  }
}