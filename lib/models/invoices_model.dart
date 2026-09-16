class InvoicesModel {
  final int id;
  final int companyId;
  final int clientId;
  final String userId;
  final String invoiceNumber;
  final String issueDate;
  final String? dueDate;
  final String? notes;
  final String createdAt;
  final int? sourceOfferId;
  final String notesPre;
  final String notesPost;
  final String status;
  final List<String> layoutOrder;
  final int? bankTransactionId;
  final String currencyCode;
  final double paidAmount;
  final double? remainingAmount;
  final String? paidAt;
  final String? lastReminderAt;
  final int reminderCount;
  final String vatReviewStatus;
  final List<dynamic> recurringInvoices;

  InvoicesModel({
    required this.id,
    required this.companyId,
    required this.clientId,
    required this.userId,
    required this.invoiceNumber,
    required this.issueDate,
    this.dueDate,
    this.notes,
    required this.createdAt,
    this.sourceOfferId,
    required this.notesPre,
    required this.notesPost,
    required this.status,
    required this.layoutOrder,
    this.bankTransactionId,
    required this.currencyCode,
    required this.paidAmount,
    this.remainingAmount,
    this.paidAt,
    this.lastReminderAt,
    required this.reminderCount,
    required this.vatReviewStatus,
    required this.recurringInvoices,
  });

  factory InvoicesModel.fromJson(Map<String, dynamic> json) {
    return InvoicesModel(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      userId: json['user_id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      issueDate: json['issue_date'] ?? '',
      dueDate: json['due_date'],
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      sourceOfferId: json['source_offer_id'],
      notesPre: json['notes_pre'] ?? '',
      notesPost: json['notes_post'] ?? '',
      status: json['status'] ?? '',
      layoutOrder: List<String>.from(
        json['layout_order'] ?? [],
      ),
      bankTransactionId: json['bank_transaction_id'],
      currencyCode: json['currency_code'] ?? '',
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: json['remaining_amount'] != null
          ? (json['remaining_amount']).toDouble()
          : null,
      paidAt: json['paid_at'],
      lastReminderAt: json['last_reminder_at'],
      reminderCount: json['reminder_count'] ?? 0,
      vatReviewStatus: json['vat_review_status'] ?? '',
      recurringInvoices: json['recurring_invoices'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'client_id': clientId,
      'user_id': userId,
      'invoice_number': invoiceNumber,
      'issue_date': issueDate,
      'due_date': dueDate,
      'notes': notes,
      'created_at': createdAt,
      'source_offer_id': sourceOfferId,
      'notes_pre': notesPre,
      'notes_post': notesPost,
      'status': status,
      'layout_order': layoutOrder,
      'bank_transaction_id': bankTransactionId,
      'currency_code': currencyCode,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'paid_at': paidAt,
      'last_reminder_at': lastReminderAt,
      'reminder_count': reminderCount,
      'vat_review_status': vatReviewStatus,
      'recurring_invoices': recurringInvoices,
    };
  }
}