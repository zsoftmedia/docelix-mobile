class AccountBalanceModel {
  final int accountId;
  final String code;
  final String name;
  final double balance;

  const AccountBalanceModel({
    required this.accountId,
    required this.code,
    required this.name,
    required this.balance,
  });

  factory AccountBalanceModel.fromJson(Map<String, dynamic> json) {
    return AccountBalanceModel(
      accountId: (json['accountId'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CategoryAccountsModel {
  final double total;
  final List<AccountBalanceModel> accounts;

  const CategoryAccountsModel({
    required this.total,
    required this.accounts,
  });

  factory CategoryAccountsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CategoryAccountsModel(total: 0.0, accounts: []);
    }
    final rawAccounts = json['accounts'] as List<dynamic>? ?? [];
    final parsedAccounts = rawAccounts
        .whereType<Map>()
        .map((e) => AccountBalanceModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return CategoryAccountsModel(
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      accounts: parsedAccounts,
    );
  }
}

class ProfitLossModel {
  final String report;
  final int companyId;
  final String periodFrom;
  final String periodTo;
  final CategoryAccountsModel revenue;
  final CategoryAccountsModel expenses;
  final double netIncome;

  const ProfitLossModel({
    required this.report,
    required this.companyId,
    required this.periodFrom,
    required this.periodTo,
    required this.revenue,
    required this.expenses,
    required this.netIncome,
  });

  factory ProfitLossModel.fromJson(Map<String, dynamic> json) {
    final periodMap = json['period'] is Map ? Map<String, dynamic>.from(json['period'] as Map) : {};

    return ProfitLossModel(
      report: json['report']?.toString() ?? 'profit_loss',
      companyId: (json['companyId'] as num?)?.toInt() ?? 0,
      periodFrom: periodMap['from']?.toString() ?? '',
      periodTo: periodMap['to']?.toString() ?? '',
      revenue: CategoryAccountsModel.fromJson(json['revenue'] is Map ? Map<String, dynamic>.from(json['revenue'] as Map) : null),
      expenses: CategoryAccountsModel.fromJson(json['expenses'] is Map ? Map<String, dynamic>.from(json['expenses'] as Map) : null),
      netIncome: (json['netIncome'] as num?)?.toDouble() ?? 0.0,
    );
  }
}