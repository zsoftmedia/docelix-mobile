class QuotationItemModel {
  final int id;
  final int offerId;
  final String description;
  final double quantity;
  final double unitPrice;
  final double vatRate;
  final double discountPercent;
  final double grossAmount;

  QuotationItemModel({
    this.id = 0,
    this.offerId = 0,
    this.description = '',
    this.quantity = 1.0,
    this.unitPrice = 0.0,
    this.vatRate = 0.0,
    this.discountPercent = 0.0,
    this.grossAmount = 0.0,
  });

  double get total => grossAmount > 0 ? grossAmount : (quantity * unitPrice);

  factory QuotationItemModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    return QuotationItemModel(
      id: _toInt(data['id']),
      offerId: _toInt(data['offer_id']),
      description: data['item_desc']?.toString() ??
          data['description']?.toString() ??
          '',
      quantity: _toDouble(data['quantity'], 1.0),
      unitPrice: _toDouble(data['unit_price']),
      vatRate: _toDouble(data['vat_rate']),
      discountPercent: _toDouble(data['discount_percent']),
      grossAmount: _toDouble(data['gross_amount']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value, [double fallback = 0.0]) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class QuotationModel {
  final int id;
  final String offerNumber;
  final String createdAt;
  final String status;
  final int companyId;
  final int clientId;
  final String issueDate;
  final String? validUntil;
  final String? acceptedAt;
  final String? vortext;
  final String? schlusstext;
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final String? clientAddress;
  final List<QuotationItemModel> items;

  QuotationModel({
    this.id = 0,
    this.offerNumber = '',
    this.createdAt = '',
    this.status = 'draft',
    this.companyId = 0,
    this.clientId = 0,
    this.issueDate = '',
    this.validUntil,
    this.acceptedAt,
    this.vortext,
    this.schlusstext,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.clientAddress,
    this.items = const [],
  });

  double get totalAmount {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  factory QuotationModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    final clientMap = data['client'] is Map ? data['client'] as Map : {};
    final rawItems = data['items'];

    final addressParts = [
      clientMap['address_line1'],
      clientMap['address_line2'],
      clientMap['postal_code'],
      clientMap['city'],
      clientMap['country'],
    ].where((part) => part != null && part.toString().trim().isNotEmpty).join(', ');

    return QuotationModel(
      id: _toInt(data['id']),
      offerNumber: data['offer_number']?.toString() ?? '',
      createdAt: data['created_at']?.toString() ?? '',
      status: data['status']?.toString() ?? 'draft',
      companyId: _toInt(data['company_id']),
      clientId: _toInt(data['client_id']),
      issueDate: data['issue_date']?.toString() ?? '',
      validUntil: data['accept_expires_at']?.toString(),
      acceptedAt: data['accepted_at']?.toString(),
      vortext: data['vortext']?.toString(),
      schlusstext: data['schlusstext']?.toString(),
      clientName: clientMap['name']?.toString() ?? data['client_name']?.toString() ?? '—',
      clientEmail: clientMap['email']?.toString(),
      clientPhone: clientMap['phone']?.toString(),
      clientAddress: addressParts.isNotEmpty ? addressParts : null,
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => QuotationItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}