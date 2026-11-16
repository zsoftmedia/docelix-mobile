class GeneralLedgerReport {
  final String report;
  final GeneralLedgerAccountFilter account;
  final GeneralLedgerPeriod period;
  final double openingBalance;
  final List<GeneralLedgerTransaction> transactions;
  final GeneralLedgerTotals totals;
  final GeneralLedgerPagination pagination;

  const GeneralLedgerReport({
    required this.report,
    required this.account,
    required this.period,
    required this.openingBalance,
    required this.transactions,
    required this.totals,
    required this.pagination,
  });

  factory GeneralLedgerReport.fromJson(Map<String, dynamic> json) {
    final rawTransactions = json['transactions'];
    final transactions = <GeneralLedgerTransaction>[];
    if (rawTransactions is List) {
      for (final item in rawTransactions) {
        if (item is Map) {
          transactions.add(
            GeneralLedgerTransaction.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    final accountRaw = json['account'];
    final periodRaw = json['period'];
    final totalsRaw = json['totals'];
    final paginationRaw = json['pagination'];

    return GeneralLedgerReport(
      report: json['report']?.toString() ?? 'general_ledger',
      account: accountRaw is Map
          ? GeneralLedgerAccountFilter.fromJson(
              Map<String, dynamic>.from(accountRaw),
            )
          : const GeneralLedgerAccountFilter(
              id: 0,
              code: 'ALL',
              name: 'All Accounts',
              type: 'all',
              normalSide: 'debit',
            ),
      period: periodRaw is Map
          ? GeneralLedgerPeriod.fromJson(Map<String, dynamic>.from(periodRaw))
          : const GeneralLedgerPeriod(from: '', to: ''),
      openingBalance: _asDouble(json['openingBalance']) ?? 0,
      transactions: transactions,
      totals: totalsRaw is Map
          ? GeneralLedgerTotals.fromJson(Map<String, dynamic>.from(totalsRaw))
          : const GeneralLedgerTotals(),
      pagination: paginationRaw is Map
          ? GeneralLedgerPagination.fromJson(
              Map<String, dynamic>.from(paginationRaw),
            )
          : const GeneralLedgerPagination(),
    );
  }

  List<GeneralLedgerEntryGroup> get groupedEntries {
    final map = <int, List<GeneralLedgerTransaction>>{};
    for (final tx in transactions) {
      map.putIfAbsent(tx.journalEntryId, () => []).add(tx);
    }

    return map.entries.map((entry) {
      final lines = List<GeneralLedgerTransaction>.from(entry.value)
        ..sort((a, b) => a.journalLineId.compareTo(b.journalLineId));
      final first = lines.first;
      final totalDebit = lines.fold<double>(0, (sum, line) => sum + line.debit);
      final totalCredit =
          lines.fold<double>(0, (sum, line) => sum + line.credit);

      return GeneralLedgerEntryGroup(
        journalEntryId: entry.key,
        entryDate: first.entryDate,
        description: first.description,
        sourceType: first.sourceType,
        sourceId: first.sourceId,
        status: first.status,
        postedAt: first.postedAt,
        postedBy: first.postedBy,
        lines: List.unmodifiable(lines),
        totalAmount: totalDebit > 0 ? totalDebit : totalCredit,
        totalDebit: totalDebit,
        totalCredit: totalCredit,
      );
    }).toList()
      ..sort((a, b) {
        final dateCompare = (b.entryDate ?? '').compareTo(a.entryDate ?? '');
        if (dateCompare != 0) return dateCompare;
        return b.journalEntryId.compareTo(a.journalEntryId);
      });
  }
}

class GeneralLedgerAccountFilter {
  final int id;
  final String code;
  final String name;
  final String type;
  final String normalSide;

  const GeneralLedgerAccountFilter({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.normalSide,
  });

  factory GeneralLedgerAccountFilter.fromJson(Map<String, dynamic> json) {
    return GeneralLedgerAccountFilter(
      id: _asInt(json['id']) ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      normalSide: json['normalSide']?.toString() ??
          json['normal_side']?.toString() ??
          '',
    );
  }

  String get displayLabel {
    if (code == 'ALL' || id == 0) return 'All Accounts';
    if (code.isNotEmpty && name.isNotEmpty) return '$code · $name';
    return name.isNotEmpty ? name : 'Account #$id';
  }
}

class GeneralLedgerPeriod {
  final String from;
  final String to;

  const GeneralLedgerPeriod({required this.from, required this.to});

  factory GeneralLedgerPeriod.fromJson(Map<String, dynamic> json) {
    return GeneralLedgerPeriod(
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
    );
  }
}

class GeneralLedgerTotals {
  final double debit;
  final double credit;
  final double closingBalance;

  const GeneralLedgerTotals({
    this.debit = 0,
    this.credit = 0,
    this.closingBalance = 0,
  });

  factory GeneralLedgerTotals.fromJson(Map<String, dynamic> json) {
    return GeneralLedgerTotals(
      debit: _asDouble(json['debit']) ?? 0,
      credit: _asDouble(json['credit']) ?? 0,
      closingBalance: _asDouble(json['closingBalance']) ?? 0,
    );
  }
}

class GeneralLedgerPagination {
  final int page;
  final int pageSize;
  final int total;

  const GeneralLedgerPagination({
    this.page = 1,
    this.pageSize = 50,
    this.total = 0,
  });

  factory GeneralLedgerPagination.fromJson(Map<String, dynamic> json) {
    return GeneralLedgerPagination(
      page: _asInt(json['page']) ?? 1,
      pageSize: _asInt(json['pageSize']) ?? 50,
      total: _asInt(json['total']) ?? 0,
    );
  }
}

class GeneralLedgerLineAccount {
  final String code;
  final String name;
  final String? normalSide;
  final String? accountType;

  const GeneralLedgerLineAccount({
    required this.code,
    required this.name,
    this.normalSide,
    this.accountType,
  });

  factory GeneralLedgerLineAccount.fromJson(Map<String, dynamic> json) {
    return GeneralLedgerLineAccount(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      normalSide: json['normal_side']?.toString() ??
          json['normalSide']?.toString(),
      accountType: json['account_type']?.toString() ??
          json['accountType']?.toString(),
    );
  }

  String get displayLabel {
    if (code.isNotEmpty && name.isNotEmpty) return '$code · $name';
    if (name.isNotEmpty) return name;
    return code;
  }
}

class GeneralLedgerTransaction {
  final int journalEntryId;
  final int journalLineId;
  final String? entryDate;
  final String description;
  final String? lineDescription;
  final String sourceType;
  final int? sourceId;
  final double debit;
  final double credit;
  final double runningBalance;
  final int? accountId;
  final GeneralLedgerLineAccount? account;
  final String status;
  final String? postedAt;
  final String? postedBy;

  const GeneralLedgerTransaction({
    required this.journalEntryId,
    required this.journalLineId,
    this.entryDate,
    required this.description,
    this.lineDescription,
    required this.sourceType,
    this.sourceId,
    required this.debit,
    required this.credit,
    required this.runningBalance,
    this.accountId,
    this.account,
    required this.status,
    this.postedAt,
    this.postedBy,
  });

  factory GeneralLedgerTransaction.fromJson(Map<String, dynamic> json) {
    GeneralLedgerLineAccount? account;
    final rawAccount = json['account'];
    if (rawAccount is Map) {
      account = GeneralLedgerLineAccount.fromJson(
        Map<String, dynamic>.from(rawAccount),
      );
    }

    return GeneralLedgerTransaction(
      journalEntryId: _asInt(json['journalEntryId']) ?? 0,
      journalLineId: _asInt(json['journalLineId']) ?? 0,
      entryDate: json['entryDate']?.toString(),
      description: json['description']?.toString() ?? '',
      lineDescription: json['lineDescription']?.toString(),
      sourceType: json['sourceType']?.toString() ?? '',
      sourceId: _asInt(json['sourceId']),
      debit: _asDouble(json['debit']) ?? 0,
      credit: _asDouble(json['credit']) ?? 0,
      runningBalance: _asDouble(json['runningBalance']) ?? 0,
      accountId: _asInt(json['accountId']),
      account: account,
      status: json['status']?.toString() ?? '',
      postedAt: json['postedAt']?.toString(),
      postedBy: json['postedBy']?.toString(),
    );
  }
}

class GeneralLedgerEntryGroup {
  final int journalEntryId;
  final String? entryDate;
  final String description;
  final String sourceType;
  final int? sourceId;
  final String status;
  final String? postedAt;
  final String? postedBy;
  final List<GeneralLedgerTransaction> lines;
  final double totalAmount;
  final double totalDebit;
  final double totalCredit;

  const GeneralLedgerEntryGroup({
    required this.journalEntryId,
    this.entryDate,
    required this.description,
    required this.sourceType,
    this.sourceId,
    required this.status,
    this.postedAt,
    this.postedBy,
    required this.lines,
    required this.totalAmount,
    required this.totalDebit,
    required this.totalCredit,
  });

  String get sourceTypeLabel => sourceType.replaceAll('_', ' ');
}

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
// NEW JOURNAL ENTRIES API MODELS (GET /api/ledger/journal-entries)
// ====================================================================

class JournalAccountModel {
  final int id;
  final String code;
  final String name;
  final String? normalSide;
  final String? accountType;

  JournalAccountModel({
    required this.id,
    required this.code,
    required this.name,
    this.normalSide,
    this.accountType,
  });

  factory JournalAccountModel.fromJson(Map<String, dynamic> json) {
    return JournalAccountModel(
      id: _asInt(json['id']) ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      normalSide: json['normal_side']?.toString(),
      accountType: json['account_type']?.toString(),
    );
  }

  String get displayLabel {
    if (code.isNotEmpty && name.isNotEmpty) return '$code · $name';
    return name.isNotEmpty ? name : code;
  }
}

class JournalLineItem {
  final int id;
  final int journalEntryId;
  final int accountId;
  final int lineNo;
  final String description;
  final double debit;
  final double credit;
  final String? createdAt;
  final JournalAccountModel? account;

  JournalLineItem({
    required this.id,
    required this.journalEntryId,
    required this.accountId,
    required this.lineNo,
    required this.description,
    required this.debit,
    required this.credit,
    this.createdAt,
    this.account,
  });

  factory JournalLineItem.fromJson(Map<String, dynamic> json) {
    JournalAccountModel? account;
    if (json['account'] is Map) {
      account = JournalAccountModel.fromJson(Map<String, dynamic>.from(json['account'] as Map));
    }

    return JournalLineItem(
      id: _asInt(json['id']) ?? 0,
      journalEntryId: _asInt(json['journal_entry_id']) ?? 0,
      accountId: _asInt(json['account_id']) ?? 0,
      lineNo: _asInt(json['line_no']) ?? 1,
      description: json['description']?.toString() ?? '',
      debit: _asDouble(json['debit']) ?? 0.0,
      credit: _asDouble(json['credit']) ?? 0.0,
      createdAt: json['created_at']?.toString(),
      account: account,
    );
  }
}

class ReconciliationModel {
  final String documentType;
  final int documentId;
  final String documentNumber;
  final String currency;
  final double total;
  final double bankDue;
  final double reconciledAmount;
  final double outstanding;
  final String status;
  final String? completedBy;
  final String? completedAt;

  ReconciliationModel({
    required this.documentType,
    required this.documentId,
    required this.documentNumber,
    required this.currency,
    required this.total,
    required this.bankDue,
    required this.reconciledAmount,
    required this.outstanding,
    required this.status,
    this.completedBy,
    this.completedAt,
  });

  factory ReconciliationModel.fromJson(Map<String, dynamic> json) {
    return ReconciliationModel(
      documentType: json['document_type']?.toString() ?? '',
      documentId: _asInt(json['document_id']) ?? 0,
      documentNumber: json['document_number']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'EUR',
      total: _asDouble(json['total']) ?? 0.0,
      bankDue: _asDouble(json['bank_due']) ?? 0.0,
      reconciledAmount: _asDouble(json['reconciled_amount']) ?? 0.0,
      outstanding: _asDouble(json['outstanding']) ?? 0.0,
      status: json['status']?.toString() ?? '',
      completedBy: json['completed_by']?.toString(),
      completedAt: json['completed_at']?.toString(),
    );
  }

  String get displayStatus {
    if (status == 'not_reconciled') return '• Not reconciled';
    if (status.isEmpty) return '—';
    return status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
  }
}

class JournalEntryItem {
  final int id;
  final int companyId;
  final String entryDate;
  final String sourceType;
  final int? sourceId;
  final String description;
  final String status;
  final String? postedBy;
  final String? postedAt;
  final String? createdAt;
  final String? invoicePaymentStatus;
  final List<JournalLineItem> lines;
  final ReconciliationModel? reconciliation;

  JournalEntryItem({
    required this.id,
    required this.companyId,
    required this.entryDate,
    required this.sourceType,
    this.sourceId,
    required this.description,
    required this.status,
    this.postedBy,
    this.postedAt,
    this.createdAt,
    this.invoicePaymentStatus,
    required this.lines,
    this.reconciliation,
  });

  factory JournalEntryItem.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? [];
    final lines = rawLines
        .whereType<Map>()
        .map((l) => JournalLineItem.fromJson(Map<String, dynamic>.from(l)))
        .toList();

    ReconciliationModel? reconciliation;
    if (json['reconciliation'] is Map) {
      reconciliation = ReconciliationModel.fromJson(Map<String, dynamic>.from(json['reconciliation'] as Map));
    }

    return JournalEntryItem(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']) ?? 0,
      entryDate: json['entry_date']?.toString() ?? '',
      sourceType: json['source_type']?.toString() ?? '',
      sourceId: _asInt(json['source_id']),
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'posted',
      postedBy: json['posted_by']?.toString(),
      postedAt: json['posted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      invoicePaymentStatus: json['invoice_payment_status']?.toString(),
      lines: lines,
      reconciliation: reconciliation,
    );
  }

  double get totalDebit => lines.fold<double>(0, (sum, l) => sum + l.debit);
  double get totalCredit => lines.fold<double>(0, (sum, l) => sum + l.credit);

  String get paymentStatusLabel {
    final raw = (invoicePaymentStatus ?? '').toLowerCase().trim();
    if (raw == 'unpaid') return 'Unpaid';
    if (raw == 'paid') return 'Paid';
    if (raw == 'settlement' || raw.contains('settle')) return 'Settlement';
    if (raw.isNotEmpty) return raw[0].toUpperCase() + raw.substring(1);
    return '—';
  }
}

class JournalEntriesResponse {
  final List<JournalEntryItem> items;
  final int total;
  final int page;
  final int limit;

  JournalEntriesResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory JournalEntriesResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .whereType<Map>()
        .map((i) => JournalEntryItem.fromJson(Map<String, dynamic>.from(i)))
        .toList();

    return JournalEntriesResponse(
      items: items,
      total: _asInt(json['total']) ?? 0,
      page: _asInt(json['page']) ?? 1,
      limit: _asInt(json['limit']) ?? 20,
    );
  }
}
