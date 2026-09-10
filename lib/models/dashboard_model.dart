class DashboardModel {
  PeriodModel? period;
  PeriodModel? comparisonPeriod;
  KpisModel? kpis;
  List<MonthlyPerformanceModel>? monthlyPerformance;
  List<ExpenseCategoryModel>? expenseCategories;
  List<BankAccountModel>? bankAccounts;
  OutstandingModel? outstanding;
  List<RecentTransactionModel>? recentTransactions;

  DashboardModel({
    this.period,
    this.comparisonPeriod,
    this.kpis,
    this.monthlyPerformance,
    this.expenseCategories,
    this.bankAccounts,
    this.outstanding,
    this.recentTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      period: json['period'] != null
          ? PeriodModel.fromJson(json['period'])
          : null,

      comparisonPeriod: json['comparisonPeriod'] != null
          ? PeriodModel.fromJson(json['comparisonPeriod'])
          : null,

      kpis: json['kpis'] != null
          ? KpisModel.fromJson(json['kpis'])
          : null,

      monthlyPerformance: json['monthlyPerformance'] != null
          ? List<MonthlyPerformanceModel>.from(
        json['monthlyPerformance'].map(
              (x) => MonthlyPerformanceModel.fromJson(x),
        ),
      )
          : [],

      expenseCategories: json['expenseCategories'] != null
          ? List<ExpenseCategoryModel>.from(
        json['expenseCategories'].map(
              (x) => ExpenseCategoryModel.fromJson(x),
        ),
      )
          : [],

      bankAccounts: json['bankAccounts'] != null
          ? List<BankAccountModel>.from(
        json['bankAccounts'].map(
              (x) => BankAccountModel.fromJson(x),
        ),
      )
          : [],

      outstanding: json['outstanding'] != null
          ? OutstandingModel.fromJson(json['outstanding'])
          : null,

      recentTransactions: json['recentTransactions'] != null
          ? List<RecentTransactionModel>.from(
        json['recentTransactions'].map(
              (x) => RecentTransactionModel.fromJson(x),
        ),
      )
          : [],
    );
  }
}


// ============================================================
// PERIOD
// ============================================================

class PeriodModel {
  String? from;
  String? to;

  PeriodModel({
    this.from,
    this.to,
  });

  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    return PeriodModel(
      from: json['from'],
      to: json['to'],
    );
  }
}


// ============================================================
// KPIS
// ============================================================

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

  factory KpisModel.fromJson(Map<String, dynamic> json) {
    return KpisModel(
      revenue: json['revenue'] != null
          ? KpiItemModel.fromJson(json['revenue'])
          : null,

      expenses: json['expenses'] != null
          ? KpiItemModel.fromJson(json['expenses'])
          : null,

      netResult: json['netResult'] != null
          ? KpiItemModel.fromJson(json['netResult'])
          : null,

      cashBalance: json['cashBalance'] != null
          ? KpiItemModel.fromJson(json['cashBalance'])
          : null,
    );
  }
}


// ============================================================
// KPI ITEM
// ============================================================

class KpiItemModel {
  num? value;
  num? previousValue;
  num? changePercent;

  KpiItemModel({
    this.value,
    this.previousValue,
    this.changePercent,
  });

  factory KpiItemModel.fromJson(Map<String, dynamic> json) {
    return KpiItemModel(
      value: json['value'],
      previousValue: json['previousValue'],
      changePercent: json['changePercent'],
    );
  }
}


// ============================================================
// MONTHLY PERFORMANCE
// ============================================================

class MonthlyPerformanceModel {
  String? month;
  num? revenue;
  num? expenses;
  num? netResult;

  MonthlyPerformanceModel({
    this.month,
    this.revenue,
    this.expenses,
    this.netResult,
  });

  factory MonthlyPerformanceModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return MonthlyPerformanceModel(
      month: json['month'],
      revenue: json['revenue'],
      expenses: json['expenses'],
      netResult: json['netResult'],
    );
  }
}


// ============================================================
// EXPENSE CATEGORY
// ============================================================

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
      category: json['category'],
      amount: json['amount'],
      percentage: json['percentage'],
    );
  }
}


// ============================================================
// BANK ACCOUNT
// ============================================================

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
      id: json['id'],
      name: json['name'],
      balance: json['balance'],
    );
  }
}


// ============================================================
// OUTSTANDING
// ============================================================

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
      receivables: json['receivables'] != null
          ? OutstandingItemModel.fromJson(json['receivables'])
          : null,

      payables: json['payables'] != null
          ? OutstandingItemModel.fromJson(json['payables'])
          : null,

      overdueInvoices: json['overdueInvoices'] != null
          ? OutstandingItemModel.fromJson(json['overdueInvoices'])
          : null,
    );
  }
}


// ============================================================
// OUTSTANDING ITEM
// ============================================================

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
      amount: json['amount'],
      count: json['count'],
    );
  }
}


// ============================================================
// RECENT TRANSACTION
// ============================================================

class RecentTransactionModel {
  int? id;
  String? type;
  String? date;
  num? amount;
  String? description;

  RecentTransactionModel({
    this.id,
    this.type,
    this.date,
    this.amount,
    this.description,
  });

  factory RecentTransactionModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return RecentTransactionModel(
      id: json['id'],
      type: json['type'],
      date: json['date'],
      amount: json['amount'],
      description: json['description'],
    );
  }
}
