class PurchaseDetailsModel {
  final int id;
  final int companyId;
  final String purchaseNumber;
  final int? supplierId;
  final String? supplierInvoiceNumber;
  final String? supplierInvoiceDate;
  final String? purchaseDate;
  final String? dueDate;
  final String? purchaseType;
  final String? currency;
  final String? paymentMethod;
  final String? reference;
  final String? notes;
  final String status;
  final double subtotal;
  final double discountTotal;
  final double taxTotal;
  final double total;
  final double amountPaid;
  final String? attachmentPath;
  final String? attachmentName;
  final String? attachmentMime;
  final String? createdAt;
  final String? updatedAt;
  final String? approvedAt;
  final String? postedAt;
  final String? paymentStatus;
  final String? documentType;
  final String? supplierName;
  final double outstanding;
  final List<PurchaseLineItemModel> lines;
  final List<PurchasePaymentModel> payments;
  final PurchaseSupplierInfoModel? supplier;
  final List<PurchaseJournalEntryModel> journal;

  PurchaseDetailsModel({
    this.id = 0,
    this.companyId = 0,
    this.purchaseNumber = '',
    this.supplierId,
    this.supplierInvoiceNumber,
    this.supplierInvoiceDate,
    this.purchaseDate,
    this.dueDate,
    this.purchaseType,
    this.currency,
    this.paymentMethod,
    this.reference,
    this.notes,
    this.status = 'draft',
    this.subtotal = 0.0,
    this.discountTotal = 0.0,
    this.taxTotal = 0.0,
    this.total = 0.0,
    this.amountPaid = 0.0,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentMime,
    this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.postedAt,
    this.paymentStatus,
    this.documentType,
    this.supplierName,
    this.outstanding = 0.0,
    this.lines = const [],
    this.payments = const [],
    this.supplier,
    this.journal = const [],
  });

  factory PurchaseDetailsModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    final rawLines = data['lines'];
    final rawPayments = data['payments'];
    final rawJournal = data['journal'];

    return PurchaseDetailsModel(
      id: _toInt(data['id']),
      companyId: _toInt(data['company_id']),
      purchaseNumber: data['purchase_number']?.toString() ?? '',
      supplierId: _toNullableInt(data['supplier_id']),
      supplierInvoiceNumber: data['supplier_invoice_number']?.toString(),
      supplierInvoiceDate: data['supplier_invoice_date']?.toString(),
      purchaseDate: data['purchase_date']?.toString(),
      dueDate: data['due_date']?.toString(),
      purchaseType: data['purchase_type']?.toString(),
      currency: data['currency']?.toString(),
      paymentMethod: data['payment_method']?.toString(),
      reference: data['reference']?.toString(),
      notes: data['notes']?.toString(),
      status: data['status']?.toString() ?? 'draft',
      subtotal: _toDouble(data['subtotal']),
      discountTotal: _toDouble(data['discount_total']),
      taxTotal: _toDouble(data['tax_total']),
      total: _toDouble(data['total']),
      amountPaid: _toDouble(data['amount_paid']),
      attachmentPath: data['attachment_path']?.toString(),
      attachmentName: data['attachment_name']?.toString(),
      attachmentMime: data['attachment_mime']?.toString(),
      createdAt: data['created_at']?.toString(),
      updatedAt: data['updated_at']?.toString(),
      approvedAt: data['approved_at']?.toString(),
      postedAt: data['posted_at']?.toString(),
      paymentStatus: data['payment_status']?.toString(),
      documentType: data['document_type']?.toString(),
      supplierName: data['supplier_name']?.toString(),
      outstanding: _toDouble(data['outstanding']),
      lines: rawLines is List
          ? rawLines
              .whereType<Map>()
              .map((e) => PurchaseLineItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      payments: rawPayments is List
          ? rawPayments
              .whereType<Map>()
              .map((e) => PurchasePaymentModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
      supplier: data['supplier'] is Map<String, dynamic>
          ? PurchaseSupplierInfoModel.fromJson(data['supplier'] as Map<String, dynamic>)
          : null,
      journal: rawJournal is List
          ? rawJournal
              .whereType<Map>()
              .map((e) => PurchaseJournalEntryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    return _toInt(value);
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

// ============================================================
// PURCHASE LINE ITEM
// ============================================================

class PurchaseLineItemModel {
  final int id;
  final int lineNo;
  final double quantity;
  final double taxRate;
  final double netAmount;
  final double taxAmount;
  final double unitPrice;
  final String description;
  final double grossAmount;
  final double totalAmount;
  final double discountAmount;
  final double discountPercent;
  final String accountCode;
  final String accountName;

  PurchaseLineItemModel({
    this.id = 0,
    this.lineNo = 0,
    this.quantity = 0.0,
    this.taxRate = 0.0,
    this.netAmount = 0.0,
    this.taxAmount = 0.0,
    this.unitPrice = 0.0,
    this.description = '',
    this.grossAmount = 0.0,
    this.totalAmount = 0.0,
    this.discountAmount = 0.0,
    this.discountPercent = 0.0,
    this.accountCode = '',
    this.accountName = '',
  });

  factory PurchaseLineItemModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    final accountMap = data['account'] is Map ? data['account'] as Map : {};

    return PurchaseLineItemModel(
      id: _toInt(data['id']),
      lineNo: _toInt(data['line_no']),
      quantity: _toDouble(data['quantity']),
      taxRate: _toDouble(data['tax_rate']),
      netAmount: _toDouble(data['net_amount']),
      taxAmount: _toDouble(data['tax_amount']),
      unitPrice: _toDouble(data['unit_price']),
      description: data['description']?.toString() ?? '',
      grossAmount: _toDouble(data['gross_amount']),
      totalAmount: _toDouble(data['total_amount']),
      discountAmount: _toDouble(data['discount_amount']),
      discountPercent: _toDouble(data['discount_percent']),
      accountCode: accountMap['code']?.toString() ?? '',
      accountName: accountMap['name']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

// ============================================================
// PURCHASE PAYMENT
// ============================================================

class PurchasePaymentModel {
  final int id;
  final double amount;
  final String method;
  final String? reference;
  final String paymentDate;
  final String createdAt;

  PurchasePaymentModel({
    this.id = 0,
    this.amount = 0.0,
    this.method = '',
    this.reference,
    this.paymentDate = '',
    this.createdAt = '',
  });

  factory PurchasePaymentModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    return PurchasePaymentModel(
      id: _toInt(data['id']),
      amount: _toDouble(data['amount']),
      method: data['method']?.toString() ?? '',
      reference: data['reference']?.toString(),
      paymentDate: data['payment_date']?.toString() ?? '',
      createdAt: data['created_at']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

// ============================================================
// PURCHASE SUPPLIER INFO
// ============================================================

class PurchaseSupplierInfoModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? addressLine1;
  final String? city;
  final String? country;
  final String? vatId;
  final String? taxId;

  PurchaseSupplierInfoModel({
    this.id = 0,
    this.name = '',
    this.email,
    this.phone,
    this.addressLine1,
    this.city,
    this.country,
    this.vatId,
    this.taxId,
  });

  factory PurchaseSupplierInfoModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    return PurchaseSupplierInfoModel(
      id: _toInt(data['id']),
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString(),
      phone: data['phone']?.toString(),
      addressLine1: data['address_line1']?.toString(),
      city: data['city']?.toString(),
      country: data['country']?.toString(),
      vatId: data['vat_id']?.toString(),
      taxId: data['tax_id']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// ============================================================
// PURCHASE JOURNAL ENTRY & LINE
// ============================================================

class PurchaseJournalEntryModel {
  final int id;
  final String entryDate;
  final String sourceType;
  final int sourceId;
  final String description;
  final List<PurchaseJournalLineModel> lines;

  PurchaseJournalEntryModel({
    this.id = 0,
    this.entryDate = '',
    this.sourceType = '',
    this.sourceId = 0,
    this.description = '',
    this.lines = const [],
  });

  factory PurchaseJournalEntryModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    final rawLines = data['lines'];

    return PurchaseJournalEntryModel(
      id: _toInt(data['id']),
      entryDate: data['entry_date']?.toString() ?? '',
      sourceType: data['source_type']?.toString() ?? '',
      sourceId: _toInt(data['source_id']),
      description: data['description']?.toString() ?? '',
      lines: rawLines is List
          ? rawLines
              .whereType<Map>()
              .map((e) => PurchaseJournalLineModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : [],
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PurchaseJournalLineModel {
  final int id;
  final int lineNo;
  final double debit;
  final double credit;
  final String description;
  final String accountCode;
  final String accountName;

  PurchaseJournalLineModel({
    this.id = 0,
    this.lineNo = 0,
    this.debit = 0.0,
    this.credit = 0.0,
    this.description = '',
    this.accountCode = '',
    this.accountName = '',
  });

  factory PurchaseJournalLineModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    final accountMap = data['account'] is Map ? data['account'] as Map : {};

    return PurchaseJournalLineModel(
      id: _toInt(data['id']),
      lineNo: _toInt(data['line_no']),
      debit: _toDouble(data['debit']),
      credit: _toDouble(data['credit']),
      description: data['description']?.toString() ?? '',
      accountCode: accountMap['code']?.toString() ?? '',
      accountName: accountMap['name']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
