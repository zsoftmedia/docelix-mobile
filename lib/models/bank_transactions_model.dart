int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

// ====================================================================
// 1. BANK STATEMENT MODEL (GET /api/ledger/statements)
// ====================================================================

class BankStatementItem {
  final int id;
  final int companyId;
  final String? uploadedBy;
  final String fileName;
  final String? fileType;
  final String? fileMime;
  final String? accountIban;
  final String? statementNumber;
  final String? periodFrom;
  final String? periodTo;
  final double? openingBalance;
  final double? closingBalance;
  final String? parserVersion;
  final String status;
  final String? parseError;
  final String? createdAt;
  final String? updatedAt;
  final int? bankConnectionId;
  final int? bankAccountId;

  BankStatementItem({
    required this.id,
    required this.companyId,
    this.uploadedBy,
    required this.fileName,
    this.fileType,
    this.fileMime,
    this.accountIban,
    this.statementNumber,
    this.periodFrom,
    this.periodTo,
    this.openingBalance,
    this.closingBalance,
    this.parserVersion,
    required this.status,
    this.parseError,
    this.createdAt,
    this.updatedAt,
    this.bankConnectionId,
    this.bankAccountId,
  });

  factory BankStatementItem.fromJson(Map<String, dynamic> json) {
    return BankStatementItem(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']) ?? 0,
      uploadedBy: json['uploaded_by']?.toString(),
      fileName: json['file_name']?.toString() ?? 'Statement File',
      fileType: json['file_type']?.toString(),
      fileMime: json['file_mime']?.toString(),
      accountIban: json['account_iban']?.toString(),
      statementNumber: json['statement_number']?.toString(),
      periodFrom: json['period_from']?.toString(),
      periodTo: json['period_to']?.toString(),
      openingBalance: _asDouble(json['opening_balance']),
      closingBalance: _asDouble(json['closing_balance']),
      parserVersion: json['parser_version']?.toString(),
      status: json['status']?.toString() ?? 'parsed',
      parseError: json['parse_error']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      bankConnectionId: _asInt(json['bank_connection_id']),
      bankAccountId: _asInt(json['bank_account_id']),
    );
  }

  String get displayStatus {
    final raw = status.toLowerCase();
    if (raw == 'parsed' || raw == 'imported') return 'Imported';
    return status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : 'Imported';
  }

  String get periodText {
    if ((periodFrom ?? '').isNotEmpty && (periodTo ?? '').isNotEmpty) {
      return '$periodFrom – $periodTo';
    } else if ((periodFrom ?? '').isNotEmpty) {
      return 'From $periodFrom';
    }
    return '—';
  }
}

class BankStatementsResponse {
  final List<BankStatementItem> items;
  final int total;
  final int page;
  final int limit;

  BankStatementsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory BankStatementsResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .whereType<Map>()
        .map((i) => BankStatementItem.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    return BankStatementsResponse(
      items: items,
      total: _asInt(json['total']) ?? 0,
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 20,
    );
  }
}

// ====================================================================
// 2. BANK TRANSACTION MODEL (GET /api/ledger/bank-transactions)
// ====================================================================

class BankAccountModel {
  final int id;
  final String iban;
  final String bankName;

  BankAccountModel({
    required this.id,
    required this.iban,
    required this.bankName,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: _asInt(json['id']) ?? 0,
      iban: json['iban']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
    );
  }

  String get displayLabel {
    if (bankName.isNotEmpty && iban.isNotEmpty) return '$bankName · $iban';
    return bankName.isNotEmpty ? bankName : iban;
  }
}

class StatementSummaryModel {
  final int id;
  final String fileName;
  final String? fileType;
  final String? createdAt;

  StatementSummaryModel({
    required this.id,
    required this.fileName,
    this.fileType,
    this.createdAt,
  });

  factory StatementSummaryModel.fromJson(Map<String, dynamic> json) {
    return StatementSummaryModel(
      id: _asInt(json['id']) ?? 0,
      fileName: json['file_name']?.toString() ?? '',
      fileType: json['file_type']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class BankTransactionItem {
  final int id;
  final int companyId;
  final int? statementId;
  final int lineNo;
  final String bookingDate;
  final String? valueDate;
  final double amount;
  final String currency;
  final String bookingText;
  final String? reference;
  final String? counterpartyName;
  final String? counterpartyIban;
  final double? balanceAfter;
  final String status;
  final int? journalEntryId;
  final int? invoiceId;
  final String? createdAt;
  final String? updatedAt;
  final double? unlinkedAmount;
  final StatementSummaryModel? statement;
  final BankAccountModel? bankAccount;

  BankTransactionItem({
    required this.id,
    required this.companyId,
    this.statementId,
    required this.lineNo,
    required this.bookingDate,
    this.valueDate,
    required this.amount,
    required this.currency,
    required this.bookingText,
    this.reference,
    this.counterpartyName,
    this.counterpartyIban,
    this.balanceAfter,
    required this.status,
    this.journalEntryId,
    this.invoiceId,
    this.createdAt,
    this.updatedAt,
    this.unlinkedAmount,
    this.statement,
    this.bankAccount,
  });

  factory BankTransactionItem.fromJson(Map<String, dynamic> json) {
    StatementSummaryModel? statement;
    if (json['statement'] is Map) {
      statement = StatementSummaryModel.fromJson(Map<String, dynamic>.from(json['statement'] as Map));
    }

    BankAccountModel? bankAccount;
    if (json['bank_account'] is Map) {
      bankAccount = BankAccountModel.fromJson(Map<String, dynamic>.from(json['bank_account'] as Map));
    }

    return BankTransactionItem(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']) ?? 0,
      statementId: _asInt(json['statement_id']),
      lineNo: _asInt(json['line_no']) ?? 1,
      bookingDate: json['booking_date']?.toString() ?? '',
      valueDate: json['value_date']?.toString(),
      amount: _asDouble(json['amount']) ?? 0.0,
      currency: json['currency']?.toString() ?? 'EUR',
      bookingText: json['booking_text']?.toString() ?? '',
      reference: json['reference']?.toString(),
      counterpartyName: json['counterparty_name']?.toString(),
      counterpartyIban: json['counterparty_iban']?.toString(),
      balanceAfter: _asDouble(json['balance_after']),
      status: json['status']?.toString() ?? 'new',
      journalEntryId: _asInt(json['journal_entry_id']),
      invoiceId: _asInt(json['invoice_id']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      unlinkedAmount: _asDouble(json['unlinked_amount']),
      statement: statement,
      bankAccount: bankAccount,
    );
  }

  String get displayStatus {
    final raw = status.toLowerCase();
    if (raw == 'new') return 'New';
    if (raw == 'categorized') return 'Categorized';
    return status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : 'New';
  }

  bool get isPositive => amount >= 0;
}

class BankTransactionsResponse {
  final List<BankTransactionItem> items;
  final int total;
  final int page;
  final int limit;

  BankTransactionsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory BankTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .whereType<Map>()
        .map((i) => BankTransactionItem.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    return BankTransactionsResponse(
      items: items,
      total: _asInt(json['total']) ?? 0,
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 20,
    );
  }
}