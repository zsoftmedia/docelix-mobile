
class AccountsReceivableModel {
  final int? id;
  final String? invoiceNumber;
  final String? clientName;
  final String? issueDate;
  final String? dueDate;
  final double? totalAmount;
  final double? paidAmount;
  final double? remainingAmount;
  final String? status;
  final int? daysOverdue;

// Not currently returned by the API,
// but your controller uses this field.
  final String? currencyCode;

  AccountsReceivableModel({
    this.id,
    this.invoiceNumber,
    this.clientName,
    this.issueDate,
    this.dueDate,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.status,
    this.daysOverdue,
    this.currencyCode,
  });

  factory AccountsReceivableModel.fromJson(Map<String, dynamic> json) {
    return AccountsReceivableModel(
      id: _parseInt(json['id']),
      invoiceNumber: json['invoice_number']?.toString(),
      clientName: json['client_name']?.toString(),
      issueDate: json['issue_date']?.toString(),
      dueDate: json['due_date']?.toString(),
      totalAmount: _parseDouble(json['total_amount']),
      paidAmount: _parseDouble(json['paid_amount']),
      remainingAmount: _parseDouble(json['remaining_amount']),
      status: json['status']?.toString(),
      daysOverdue: _parseInt(json['days_overdue']),

// API currently doesn't return currency_code.
      currencyCode: json['currency_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'client_name': clientName,
      'issue_date': issueDate,
      'due_date': dueDate,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'status': status,
      'days_overdue': daysOverdue,
      'currency_code': currencyCode,
    };
  }

// ============================================================
// NULL-SAFE PARSERS
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
