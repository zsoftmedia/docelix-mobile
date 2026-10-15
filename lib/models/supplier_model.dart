class SupplierModel {
  final int id;
  final int companyId;
  final String name;
  final String? contactName;
  final String? email;
  final String? phone;
  final String? website;
  final String? vatId;
  final String? taxId;
  final String? addressLine1;
  final String? addressLine2;
  final String? postalCode;
  final String? city;
  final String? country;
  final String? iban;
  final int? paymentTermsDays;
  final int? defaultAccountId;
  final String? notes;
  final bool isActive;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double purchasesTotal;
  final double paidTotal;
  final double outstanding;
  final int purchaseCount;
  final DateTime? lastPurchaseDate;

  const SupplierModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.contactName,
    this.email,
    this.phone,
    this.website,
    this.vatId,
    this.taxId,
    this.addressLine1,
    this.addressLine2,
    this.postalCode,
    this.city,
    this.country,
    this.iban,
    this.paymentTermsDays,
    this.defaultAccountId,
    this.notes,
    this.isActive = true,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.purchasesTotal = 0,
    this.paidTotal = 0,
    this.outstanding = 0,
    this.purchaseCount = 0,
    this.lastPurchaseDate,
  });

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    final result = value.toString().trim();
    return result.isEmpty ? null : result;
  }

  static int _intValue(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _nullableInt(dynamic value) {
    if (value == null) return null;
    return _intValue(value);
  }

  static double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static bool _boolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }

  static DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: _intValue(json['id']),
      companyId: _intValue(json['company_id']),
      name: _stringValue(json['name']) ?? 'Unnamed Supplier',
      contactName: _stringValue(json['contact_name']),
      email: _stringValue(json['email']),
      phone: _stringValue(json['phone']),
      website: _stringValue(json['website']),
      vatId: _stringValue(json['vat_id']),
      taxId: _stringValue(json['tax_id']),
      addressLine1: _stringValue(json['address_line1']),
      addressLine2: _stringValue(json['address_line2']),
      postalCode: _stringValue(json['postal_code']),
      city: _stringValue(json['city']),
      country: _stringValue(json['country']),
      iban: _stringValue(json['iban']),
      paymentTermsDays: _nullableInt(json['payment_terms_days']),
      defaultAccountId: _nullableInt(json['default_account_id']),
      notes: _stringValue(json['notes']),
      isActive: _boolValue(json['is_active']),
      createdBy: _stringValue(json['created_by']),
      createdAt: _dateValue(json['created_at']),
      updatedAt: _dateValue(json['updated_at']),
      purchasesTotal: _doubleValue(json['purchases_total']),
      paidTotal: _doubleValue(json['paid_total']),
      outstanding: _doubleValue(json['outstanding']),
      purchaseCount: _intValue(json['purchase_count']),
      lastPurchaseDate: _dateValue(json['last_purchase_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'contact_name': contactName,
      'email': email,
      'phone': phone,
      'website': website,
      'vat_id': vatId,
      'tax_id': taxId,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'postal_code': postalCode,
      'city': city,
      'country': country,
      'iban': iban,
      'payment_terms_days': paymentTermsDays,
      'default_account_id': defaultAccountId,
      'notes': notes,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'purchases_total': purchasesTotal,
      'paid_total': paidTotal,
      'outstanding': outstanding,
      'purchase_count': purchaseCount,
      'last_purchase_date': lastPurchaseDate?.toIso8601String(),
    };
  }
}

class SupplierPagination {
  final int page;
  final int pageSize;
  final int total;

  const SupplierPagination({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory SupplierPagination.fromJson(Map<String, dynamic>? json) {
    int parseInt(dynamic value, [int fallback = 0]) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    return SupplierPagination(
      page: parseInt(json?['page'], 1),
      pageSize: parseInt(json?['pageSize'], 20),
      total: parseInt(json?['total']),
    );
  }
}

class SupplierResponse {
  final List<SupplierModel> data;
  final SupplierPagination pagination;

  const SupplierResponse({
    required this.data,
    required this.pagination,
  });

  factory SupplierResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawPagination = json['pagination'];

    return SupplierResponse(
      data: rawData is List
          ? rawData
          .whereType<Map>()
          .map(
            (item) => SupplierModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : <SupplierModel>[],
      pagination: SupplierPagination.fromJson(
        rawPagination is Map
            ? Map<String, dynamic>.from(rawPagination)
            : null,
      ),
    );
  }
}