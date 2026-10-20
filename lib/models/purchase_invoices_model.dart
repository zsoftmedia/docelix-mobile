class PurchaseInvoicesModel {
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

  final String? purchaseNumber;
  final String? supplierInvoiceNumber;
  final String? invoiceNumber;
  final String? invoiceDate;
  final String? dueDate;
  final String? currency;
  final num? totalAmount;
  final num? vatRatePercent;
  final num? outstandingAmount;

  final String? ocrText;

  final String? uploadedAt;
  final String? updatedAt;

  final String status;
  final String? paymentStatus;
  final String? expenseCategory;

  final int? expenseAccountId;
  final String? expenseAccountCode;

  final int? bankTransactionId;

  final String? vatReviewStatus;
  final String? vatTreatment;
  final num? vatDeductibilityPercent;

  final String? previewUrl;

  PurchaseInvoicesModel({
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
    this.purchaseNumber,
    this.supplierInvoiceNumber,
    this.invoiceNumber,
    this.invoiceDate,
    this.dueDate,
    this.currency,
    this.totalAmount,
    this.vatRatePercent,
    this.outstandingAmount,
    this.ocrText,
    this.uploadedAt,
    this.updatedAt,
    required this.status,
    this.paymentStatus,
    this.expenseCategory,
    this.expenseAccountId,
    this.expenseAccountCode,
    this.bankTransactionId,
    this.vatReviewStatus,
    this.vatTreatment,
    this.vatDeductibilityPercent,
    this.previewUrl,
  });

  factory PurchaseInvoicesModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final String pNum = json['purchase_number']?.toString() ?? '';
    final String suppInvNum = json['supplier_invoice_number']?.toString() ?? '';
    final String invNum = json['invoice_number']?.toString() ?? '';

    final String computedInvNumber = pNum.isNotEmpty
        ? pNum
        : (suppInvNum.isNotEmpty ? suppInvNum : invNum);

    final String attachPath = json['attachment_path']?.toString() ?? '';
    final String prevUrl = json['preview_url']?.toString() ?? '';
    final String fileUrlRaw = json['file_url']?.toString() ?? '';

    final String resolvedPath = prevUrl.isNotEmpty
        ? prevUrl
        : (attachPath.isNotEmpty ? attachPath : fileUrlRaw);

    final String attachMime = json['attachment_mime']?.toString() ?? json['mime_type']?.toString() ?? '';
    final String docType = json['document_type']?.toString() ?? json['file_type']?.toString() ?? '';

    final String resolvedFileType = docType.isNotEmpty
        ? docType
        : (attachMime.contains('pdf') || resolvedPath.toLowerCase().endsWith('.pdf') ? 'pdf' : 'image');

    return PurchaseInvoicesModel(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      userId: json['created_by']?.toString() ?? json['user_id']?.toString() ?? '',
      fileName: json['attachment_name']?.toString() ?? json['file_name']?.toString() ?? '',
      fileUrl: resolvedPath,
      fileType: resolvedFileType,
      mimeType: attachMime,
      sizeBytes: json['size_bytes'] is num
          ? (json['size_bytes'] as num).toInt()
          : 0,

      supplierName: json['supplier_name']?.toString() ?? json['suggested_supplier_name']?.toString(),
      supplierEmail: json['supplier_email']?.toString(),
      supplierPhone: json['supplier_phone']?.toString(),
      supplierAddressLine1: json['supplier_address_line1']?.toString(),
      supplierAddressLine2: json['supplier_address_line2']?.toString(),
      supplierCity: json['supplier_city']?.toString(),
      supplierPostal: json['supplier_postal']?.toString(),
      supplierCountry: json['supplier_country']?.toString(),

      purchaseNumber: pNum.isNotEmpty ? pNum : null,
      supplierInvoiceNumber: suppInvNum.isNotEmpty ? suppInvNum : null,
      invoiceNumber: computedInvNumber,
      invoiceDate: json['purchase_date']?.toString() ??
          json['supplier_invoice_date']?.toString() ??
          json['invoice_date']?.toString(),
      dueDate: json['due_date']?.toString(),
      currency: json['currency']?.toString(),
      totalAmount: json['total'] is num
          ? (json['total'] as num)
          : (json['total_amount'] is num ? (json['total_amount'] as num) : 0),
      vatRatePercent: json['tax_total'] is num
          ? (json['tax_total'] as num)
          : (json['vat_rate_percent'] is num ? (json['vat_rate_percent'] as num) : 0),
      outstandingAmount: double.tryParse(json['outstanding']?.toString() ?? '') ?? 0.0,

      ocrText: json['ocr_text']?.toString(),

      uploadedAt: json['created_at']?.toString() ?? json['uploaded_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),

      status: json['status']?.toString() ?? 'draft',
      paymentStatus: json['payment_status']?.toString(),
      expenseCategory: json['expense_category']?.toString() ?? json['purchase_type']?.toString(),

      expenseAccountId: json['account'] is Map && (json['account'] as Map)['id'] is num
          ? ((json['account'] as Map)['id'] as num).toInt()
          : (json['expense_account_id'] is num ? (json['expense_account_id'] as num).toInt() : null),
      expenseAccountCode: json['account'] is Map
          ? (json['account'] as Map)['code']?.toString()
          : json['expense_account_code']?.toString(),

      bankTransactionId: json['bank_transaction_id'] is num
          ? (json['bank_transaction_id'] as num).toInt()
          : null,

      vatReviewStatus: json['vat_review_status']?.toString(),
      vatTreatment: json['vat_treatment']?.toString(),
      vatDeductibilityPercent: json['vat_deductibility_percent'] is num
          ? (json['vat_deductibility_percent'] as num)
          : null,

      previewUrl: resolvedPath,
    );
  }
}