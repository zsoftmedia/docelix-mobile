class DashboardModel {
  CompanyDashboardModel? company;
  //List<AssignedConsultantModel> assignedConsultants;
  QuickStatsModel? quickStats;

  PeriodModel? period;
  PeriodModel? comparisonPeriod;

  KpisModel? kpis;

  List<MonthlyPerformanceModel> monthlyPerformance;
  List<ExpenseCategoryModel> expenseCategories;
  List<BankAccountModel> bankAccounts;

  OutstandingModel? outstanding;

  List<RecentTransactionModel> recentTransactions;

  DashboardModel({
    this.company,
    //this.assignedConsultants = const [],
    this.quickStats,
    this.period,
    this.comparisonPeriod,
    this.kpis,
    this.monthlyPerformance = const [],
    this.expenseCategories = const [],
    this.bankAccounts = const [],
    this.outstanding,
    this.recentTransactions = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      company: json['company'] is Map<String, dynamic>
          ? CompanyDashboardModel.fromJson(
        json['company'] as Map<String, dynamic>,
      )
          : null,

     /* assignedConsultants: _parseList(
        json['assignedConsultants'],
        AssignedConsultantModel.fromJson,
      ),*/

      quickStats: json['quickStats'] is Map<String, dynamic>
          ? QuickStatsModel.fromJson(
        json['quickStats'] as Map<String, dynamic>,
      )
          : null,

      period: json['period'] is Map<String, dynamic>
          ? PeriodModel.fromJson(
        json['period'] as Map<String, dynamic>,
      )
          : null,

      comparisonPeriod: json['comparisonPeriod'] is Map<String, dynamic>
          ? PeriodModel.fromJson(
        json['comparisonPeriod'] as Map<String, dynamic>,
      )
          : null,

      kpis: json['kpis'] is Map<String, dynamic>
          ? KpisModel.fromJson(
        json['kpis'] as Map<String, dynamic>,
      )
          : null,

      monthlyPerformance: _parseList(
        json['monthlyPerformance'],
        MonthlyPerformanceModel.fromJson,
      ),

      expenseCategories: _parseList(
        json['expenseCategories'],
        ExpenseCategoryModel.fromJson,
      ),

      bankAccounts: _parseList(
        json['bankAccounts'],
        BankAccountModel.fromJson,
      ),

      outstanding: json['outstanding'] is Map<String, dynamic>
          ? OutstandingModel.fromJson(
        json['outstanding'] as Map<String, dynamic>,
      )
          : null,

      recentTransactions: _parseList(
        json['recentTransactions'],
        RecentTransactionModel.fromJson,
      ),
    );
  }

  static List<T> _parseList<T>(
      dynamic value,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }
}

class CompanyDashboardModel {
  int? id;
  String? name;
  String? legalForm;
  String? taxId;
  String? vatNumber;
  String? addressLine1;
  String? addressLine2;
  String? postalCode;
  String? city;
  String? country;
  String? currencyCode;
  String? customIndustryName;

  CompanyDashboardModel({
    this.id,
    this.name,
    this.legalForm,
    this.taxId,
    this.vatNumber,
    this.addressLine1,
    this.addressLine2,
    this.postalCode,
    this.city,
    this.country,
    this.currencyCode,
    this.customIndustryName,
  });

  factory CompanyDashboardModel.fromJson(Map<String, dynamic> json) {
    return CompanyDashboardModel(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : null,

      name: json['name']?.toString(),

      legalForm: json['legal_form']?.toString(),

      taxId: json['tax_id']?.toString(),

      vatNumber: json['vat_number']?.toString(),

      addressLine1: json['address_line1']?.toString(),

      addressLine2: json['address_line2']?.toString(),

      postalCode: json['postal_code']?.toString(),

      city: json['city']?.toString(),

      country: json['country']?.toString(),

      currencyCode: json['currency_code']?.toString() ??
          json['currencyCode']?.toString(),

      customIndustryName:
      json['custom_industry_name']?.toString(),
    );
  }
}

class QuickStatsModel {
  int totalClients;
  int totalItems;
  int totalEmployees;
  int totalOffers;

  QuickStatsModel({
    this.totalClients = 0,
    this.totalItems = 0,
    this.totalEmployees = 0,
    this.totalOffers = 0,
  });

  factory QuickStatsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return QuickStatsModel(
      totalClients: _toInt(json['totalClients']),
      totalItems: _toInt(json['totalItems']),
      totalEmployees: _toInt(json['totalEmployees']),
      totalOffers: _toInt(json['totalOffers']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class PeriodModel {
  String? from;
  String? to;

  PeriodModel({
    this.from,
    this.to,
  });

  factory PeriodModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PeriodModel(
      from: json['from']?.toString(),
      to: json['to']?.toString(),
    );
  }
}

class KpisModel {
  KpiItemModel? revenue;
  KpiItemModel? expenses;
  KpiItemModel? netResult;
  KpiItemModel? cashBalance;

  KpisModel({
    this.revenue,
    this.expenses,
    this.netResult,
    this.cashBalance,
  });

  factory KpisModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return KpisModel(
      revenue: json['revenue'] is Map<String, dynamic>
          ? KpiItemModel.fromJson(
        json['revenue'] as Map<String, dynamic>,
      )
          : null,

      expenses: json['expenses'] is Map<String, dynamic>
          ? KpiItemModel.fromJson(
        json['expenses'] as Map<String, dynamic>,
      )
          : null,

      netResult: json['netResult'] is Map<String, dynamic>
          ? KpiItemModel.fromJson(
        json['netResult'] as Map<String, dynamic>,
      )
          : null,

      cashBalance: json['cashBalance'] is Map<String, dynamic>
          ? KpiItemModel.fromJson(
        json['cashBalance'] as Map<String, dynamic>,
      )
          : null,
    );
  }
}

class KpiItemModel {
  num? value;
  num? previousValue;
  num? changePercent;

  KpiItemModel({
    this.value,
    this.previousValue,
    this.changePercent,
  });

  factory KpiItemModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return KpiItemModel(
      value: json['value'] is num
          ? json['value'] as num
          : null,

      previousValue: json['previousValue'] is num
          ? json['previousValue'] as num
          : null,

      changePercent: json['changePercent'] is num
          ? json['changePercent'] as num
          : null,
    );
  }
}

class MonthlyPerformanceModel {
  String? date;
  num? revenue;
  num? expenses;

  MonthlyPerformanceModel({
    this.date,
    this.revenue,
    this.expenses,
  });

  factory MonthlyPerformanceModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return MonthlyPerformanceModel(
      date: json['date']?.toString(),

      revenue: json['revenue'] is num
          ? json['revenue'] as num
          : null,

      expenses: json['expenses'] is num
          ? json['expenses'] as num
          : null,
    );
  }
}

class ExpenseCategoryModel {
  String? category;
  num? amount;
  num? percentage;

  ExpenseCategoryModel({
    this.category,
    this.amount,
    this.percentage,
  });

  factory ExpenseCategoryModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ExpenseCategoryModel(
      category: json['category']?.toString(),

      amount: json['amount'] is num
          ? json['amount'] as num
          : null,

      percentage: json['percentage'] is num
          ? json['percentage'] as num
          : null,
    );
  }
}

class BankAccountModel {
  int? id;
  String? name;
  num? balance;

  BankAccountModel({
    this.id,
    this.name,
    this.balance,
  });

  factory BankAccountModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return BankAccountModel(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : null,

      name: json['name']?.toString(),

      balance: json['balance'] is num
          ? json['balance'] as num
          : null,
    );
  }
}

class OutstandingModel {
  OutstandingItemModel? receivables;
  OutstandingItemModel? payables;
  OutstandingItemModel? overdueInvoices;

  OutstandingModel({
    this.receivables,
    this.payables,
    this.overdueInvoices,
  });

  factory OutstandingModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OutstandingModel(
      receivables: json['receivables'] is Map<String, dynamic>
          ? OutstandingItemModel.fromJson(
        json['receivables'] as Map<String, dynamic>,
      )
          : null,

      payables: json['payables'] is Map<String, dynamic>
          ? OutstandingItemModel.fromJson(
        json['payables'] as Map<String, dynamic>,
      )
          : null,

      overdueInvoices:
      json['overdueInvoices'] is Map<String, dynamic>
          ? OutstandingItemModel.fromJson(
        json['overdueInvoices']
        as Map<String, dynamic>,
      )
          : null,
    );
  }
}

class OutstandingItemModel {
  num? amount;
  int? count;

  OutstandingItemModel({
    this.amount,
    this.count,
  });

  factory OutstandingItemModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OutstandingItemModel(
      amount: json['amount'] is num
          ? json['amount'] as num
          : null,

      count: json['count'] is num
          ? (json['count'] as num).toInt()
          : null,
    );
  }
}

class RecentTransactionModel {
  int? id;
  String? date;
  String? description;
  String? type;
  String? account;
  num? amount;
  String? status;
  String? sourceType;
  int? sourceId;

  RecentTransactionModel({
    this.id,
    this.date,
    this.description,
    this.type,
    this.account,
    this.amount,
    this.status,
    this.sourceType,
    this.sourceId,
  });

  factory RecentTransactionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return RecentTransactionModel(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : null,

      date: json['date']?.toString(),

      description: json['description']?.toString(),

      type: json['type']?.toString(),

      account: json['account']?.toString(),

      amount: json['amount'] is num
          ? json['amount'] as num
          : null,

      status: json['status']?.toString(),

      sourceType: json['source_type']?.toString(),

      sourceId: json['source_id'] is num
          ? (json['source_id'] as num).toInt()
          : null,
    );
  }
}
