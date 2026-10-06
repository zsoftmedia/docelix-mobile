
class TransactionModel {
  final String report;
  final LedgerAccountModel account;
  final LedgerPeriodModel period;
  final double openingBalance;
  final List<TransactionItemModel> transactions;
  final TransactionTotalsModel totals;
  final TransactionPaginationModel pagination;

  TransactionModel({
    this.report = '',
    LedgerAccountModel? account,
    LedgerPeriodModel? period,
    this.openingBalance = 0.0,
    List<TransactionItemModel>? transactions,
    TransactionTotalsModel? totals,
    TransactionPaginationModel? pagination,
  })  : account = account ?? LedgerAccountModel(),
        period = period ?? LedgerPeriodModel(),
        transactions = transactions ?? [],
        totals = totals ?? TransactionTotalsModel(),
        pagination = pagination ?? TransactionPaginationModel();

  factory TransactionModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    return TransactionModel(
      report: data['report']?.toString() ?? '',
      account: LedgerAccountModel.fromJson(
        data['account'] as Map<String, dynamic>?,
      ),
      period: LedgerPeriodModel.fromJson(
        data['period'] as Map<String, dynamic>?,
      ),
      openingBalance: _toDouble(data['openingBalance']),
      transactions: _toList(data['transactions'])
          .map((e) => TransactionItemModel.fromJson(e))
          .toList(),
      totals: TransactionTotalsModel.fromJson(
        data['totals'] as Map<String, dynamic>?,
      ),
      pagination: TransactionPaginationModel.fromJson(
        data['pagination'] as Map<String, dynamic>?,
      ),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static List<dynamic> _toList(dynamic value) {
    return value is List ? value : [];
  }
}

// ============================================================
// LEDGER ACCOUNT
// ============================================================

class LedgerAccountModel {
  final int id;
  final String code;
  final String name;
  final String type;
  final String normalSide;

  LedgerAccountModel({
    this.id = 0,
    this.code = '',
    this.name = '',
    this.type = '',
    this.normalSide = '',
  });

  factory LedgerAccountModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    return LedgerAccountModel(
      id: _toInt(data['id']),
      code: data['code']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      normalSide: data['normalSide']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// ============================================================
// PERIOD
// ============================================================

class LedgerPeriodModel {
  final String from;
  final String to;

  LedgerPeriodModel({
    this.from = '',
    this.to = '',
  });

  factory LedgerPeriodModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    return LedgerPeriodModel(
      from: data['from']?.toString() ?? '',
      to: data['to']?.toString() ?? '',
    );
  }
}

// ============================================================
// TRANSACTION ITEM
// ============================================================

class TransactionItemModel {
  final int journalEntryId;
  final int journalLineId;
  final String entryDate;
  final String description;
  final String lineDescription;
  final String sourceType;
  final int sourceId;
  final double debit;
  final double credit;
  final double runningBalance;
  final int accountId;
  final TransactionAccountModel account;
  final String status;
  final String postedAt;
  final String? postedBy;

  TransactionItemModel({
    this.journalEntryId = 0,
    this.journalLineId = 0,
    this.entryDate = '',
    this.description = '',
    this.lineDescription = '',
    this.sourceType = '',
    this.sourceId = 0,
    this.debit = 0.0,
    this.credit = 0.0,
    this.runningBalance = 0.0,
    this.accountId = 0,
    TransactionAccountModel? account,
    this.status = '',
    this.postedAt = '',
    this.postedBy,
  }) : account = account ?? TransactionAccountModel();

  factory TransactionItemModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    return TransactionItemModel(
      journalEntryId: _toInt(data['journalEntryId']),
      journalLineId: _toInt(data['journalLineId']),
      entryDate: data['entryDate']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      lineDescription: data['lineDescription']?.toString() ?? '',
      sourceType: data['sourceType']?.toString() ?? '',
      sourceId: _toInt(data['sourceId']),
      debit: _toDouble(data['debit']),
      credit: _toDouble(data['credit']),
      runningBalance: _toDouble(data['runningBalance']),
      accountId: _toInt(data['accountId']),
      account: TransactionAccountModel.fromJson(
        data['account'] as Map<String, dynamic>?,
      ),
      status: data['status']?.toString() ?? '',
      postedAt: data['postedAt']?.toString() ?? '',
      postedBy: data['postedBy']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}

// ============================================================
// TRANSACTION ACCOUNT
// ============================================================

class TransactionAccountModel {
  final String code;
  final String name;
  final String normalSide;
  final String accountType;

  TransactionAccountModel({
    this.code = '',
    this.name = '',
    this.normalSide = '',
    this.accountType = '',
  });

  factory TransactionAccountModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    return TransactionAccountModel(
      code: data['code']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      normalSide: (data['normal_side'] ?? data['normalSide'])?.toString() ?? '',
      accountType: (data['account_type'] ?? data['accountType'])?.toString() ?? '',
    );
  }
}

// ============================================================
// TOTALS
// ============================================================

class TransactionTotalsModel {
  final double debit;
  final double credit;
  final double closingBalance;

  TransactionTotalsModel({
    this.debit = 0.0,
    this.credit = 0.0,
    this.closingBalance = 0.0,
  });

  factory TransactionTotalsModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    return TransactionTotalsModel(
      debit: _toDouble(data['debit']),
      credit: _toDouble(data['credit']),
      closingBalance: _toDouble(data['closingBalance']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}

// ============================================================
// PAGINATION
// ============================================================

class TransactionPaginationModel {
  final int page;
  final int pageSize;
  final int total;

  TransactionPaginationModel({
    this.page = 1,
    this.pageSize = 0,
    this.total = 0,
  });

  factory TransactionPaginationModel.fromJson(
      Map<String, dynamic>? json,
      ) {
    final data = json ?? {};

    return TransactionPaginationModel(
      page: _toInt(data['page'], fallback: 1),
      pageSize: _toInt(data['pageSize']),
      total: _toInt(data['total']),
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
