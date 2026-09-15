class IncomingInvoicesModel {
  final int id;
  final int companyId;
  final String userId;

  final String fileName;
  final String fileUrl;
  final String fileType;
  final String mimeType;
  final int sizeBytes;

  final String? supplierName;
  final String? supplierEmail;
  final String? supplierPhone;
  final String? supplierAddressLine1;
  final String? supplierAddressLine2;
  final String? supplierCity;
  final String? supplierPostal;
  final String? supplierCountry;

  final String? invoiceNumber;
  final String? invoiceDate;
  final String? currency;
  final num? totalAmount;
  final num? vatRatePercent;

  final String? ocrText;

  final String? uploadedAt;
  final String? updatedAt;

  final String status;
  final String? expenseCategory;

  final int? expenseAccountId;
  final String? expenseAccountCode;

  final int? bankTransactionId;

  final String? vatReviewStatus;
  final String? vatTreatment;
  final num? vatDeductibilityPercent;

  final String? previewUrl;

  IncomingInvoicesModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.mimeType,
    required this.sizeBytes,
    this.supplierName,
    this.supplierEmail,
    this.supplierPhone,
    this.supplierAddressLine1,
    this.supplierAddressLine2,
    this.supplierCity,
    this.supplierPostal,
    this.supplierCountry,
    this.invoiceNumber,
    this.invoiceDate,
    this.currency,
    this.totalAmount,
    this.vatRatePercent,
    this.ocrText,
    this.uploadedAt,
    this.updatedAt,
    required this.status,
    this.expenseCategory,
    this.expenseAccountId,
    this.expenseAccountCode,
    this.bankTransactionId,
    this.vatReviewStatus,
    this.vatTreatment,
    this.vatDeductibilityPercent,
    this.previewUrl,
  });

  factory IncomingInvoicesModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return IncomingInvoicesModel(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      userId: json['user_id'] ?? '',
      fileName: json['file_name'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileType: json['file_type'] ?? '',
      mimeType: json['mime_type'] ?? '',
      sizeBytes: json['size_bytes'] ?? 0,

      supplierName: json['supplier_name'],
      supplierEmail: json['supplier_email'],
      supplierPhone: json['supplier_phone'],
      supplierAddressLine1:
      json['supplier_address_line1'],
      supplierAddressLine2:
      json['supplier_address_line2'],
      supplierCity: json['supplier_city'],
      supplierPostal: json['supplier_postal'],
      supplierCountry: json['supplier_country'],

      invoiceNumber: json['invoice_number'],
      invoiceDate: json['invoice_date'],
      currency: json['currency'],
      totalAmount: json['total_amount'],
      vatRatePercent: json['vat_rate_percent'],

      ocrText: json['ocr_text'],

      uploadedAt: json['uploaded_at'],
      updatedAt: json['updated_at'],

      status: json['status'] ?? '',
      expenseCategory: json['expense_category'],

      expenseAccountId: json['expense_account_id'],
      expenseAccountCode:
      json['expense_account_code'],

      bankTransactionId:
      json['bank_transaction_id'],

      vatReviewStatus:
      json['vat_review_status'],
      vatTreatment:
      json['vat_treatment'],
      vatDeductibilityPercent:
      json['vat_deductibility_percent'],

      previewUrl: json['preview_url'],
    );
  }
}