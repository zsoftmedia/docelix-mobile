class AccountsPayableModel {
  final int? id;
  final int? companyId;
  final String? userId;

  final String? fileName;
  final String? fileUrl;
  final String? fileType;
  final String? mimeType;
  final int? sizeBytes;

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

  final double? totalAmount;
  final double? vatRatePercent;

  final String? ocrText;
  final String? uploadedAt;
  final String? updatedAt;

  final String? status;
  final String? expenseCategory;

  final int? expenseAccountId;
  final String? expenseAccountCode;
  final int? bankTransactionId;

  final String? vatReviewStatus;
  final String? vatTreatment;
  final double? vatDeductibilityPercent;

  final double? netAmount;
  final double? vatAmount;

  final String? paidDate;
  final double? ocrConfidence;

  final String? contentHash;
  final bool? isSuspicious;
  final String? suspicionReason;

  final int? vatReviewedBy;
  final String? vatReviewedAt;
  final String? vatReviewNote;

  final String? documentNumber;
  final String? date;
  final String? dueDate;

  final double? remainingAmount;
  final int? daysOverdue;

  AccountsPayableModel({
    this.id,
    this.companyId,
    this.userId,
    this.fileName,
    this.fileUrl,
    this.fileType,
    this.mimeType,
    this.sizeBytes,
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
    this.status,
    this.expenseCategory,
    this.expenseAccountId,
    this.expenseAccountCode,
    this.bankTransactionId,
    this.vatReviewStatus,
    this.vatTreatment,
    this.vatDeductibilityPercent,
    this.netAmount,
    this.vatAmount,
    this.paidDate,
    this.ocrConfidence,
    this.contentHash,
    this.isSuspicious,
    this.suspicionReason,
    this.vatReviewedBy,
    this.vatReviewedAt,
    this.vatReviewNote,
    this.documentNumber,
    this.date,
    this.dueDate,
    this.remainingAmount,
    this.daysOverdue,
  });

  factory AccountsPayableModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AccountsPayableModel(
      id: _parseInt(json['id']),
      companyId: _parseInt(json['company_id']),
      userId: json['user_id']?.toString(),

      fileName: json['file_name']?.toString(),
      fileUrl: json['file_url']?.toString(),
      fileType: json['file_type']?.toString(),
      mimeType: json['mime_type']?.toString(),
      sizeBytes: _parseInt(json['size_bytes']),

      supplierName: json['supplier_name']?.toString(),
      supplierEmail: json['supplier_email']?.toString(),
      supplierPhone: json['supplier_phone']?.toString(),
      supplierAddressLine1:
      json['supplier_address_line1']?.toString(),
      supplierAddressLine2:
      json['supplier_address_line2']?.toString(),
      supplierCity: json['supplier_city']?.toString(),
      supplierPostal: json['supplier_postal']?.toString(),
      supplierCountry: json['supplier_country']?.toString(),

      invoiceNumber: json['invoice_number']?.toString(),
      invoiceDate: json['invoice_date']?.toString(),
      currency: json['currency']?.toString(),

      totalAmount: _parseDouble(json['total_amount']),
      vatRatePercent:
      _parseDouble(json['vat_rate_percent']),

      ocrText: json['ocr_text']?.toString(),
      uploadedAt: json['uploaded_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),

      status: json['status']?.toString(),
      expenseCategory:
      json['expense_category']?.toString(),

      expenseAccountId:
      _parseInt(json['expense_account_id']),
      expenseAccountCode:
      json['expense_account_code']?.toString(),
      bankTransactionId:
      _parseInt(json['bank_transaction_id']),

      vatReviewStatus:
      json['vat_review_status']?.toString(),
      vatTreatment:
      json['vat_treatment']?.toString(),
      vatDeductibilityPercent:
      _parseDouble(json['vat_deductibility_percent']),

      netAmount: _parseDouble(json['net_amount']),
      vatAmount: _parseDouble(json['vat_amount']),

      paidDate: json['paid_date']?.toString(),
      ocrConfidence:
      _parseDouble(json['ocr_confidence']),

      contentHash: json['content_hash']?.toString(),
      isSuspicious: json['is_suspicious'] == null
          ? null
          : json['is_suspicious'] == true,
      suspicionReason:
      json['suspicion_reason']?.toString(),

      vatReviewedBy:
      _parseInt(json['vat_reviewed_by']),
      vatReviewedAt:
      json['vat_reviewed_at']?.toString(),
      vatReviewNote:
      json['vat_review_note']?.toString(),

      documentNumber:
      json['document_number']?.toString(),
      date: json['date']?.toString(),
      dueDate: json['due_date']?.toString(),

      remainingAmount:
      _parseDouble(json['remaining_amount']),
      daysOverdue:
      _parseInt(json['days_overdue']),
    );
  }

  // ============================================================
  // SAFE PARSERS
  // ============================================================

  static int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}