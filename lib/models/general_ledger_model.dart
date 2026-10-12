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
