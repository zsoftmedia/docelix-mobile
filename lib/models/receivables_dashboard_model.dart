class ReceivablesDashboardModel {
  final PeriodModel? period;
  final ReceivablesKpis? kpis;
  final AgingModel? aging;
  final List<AttentionInvoice> attentionInvoices;
  final CollectionPerformance? collectionPerformance;
  final CollectionRisk? collectionRisk;
  final Reconciliation? reconciliation;

  ReceivablesDashboardModel({
    this.period,
    this.kpis,
    this.aging,
    this.attentionInvoices = const [],
    this.collectionPerformance,
    this.collectionRisk,
    this.reconciliation,
  });

  factory ReceivablesDashboardModel.fromJson(Map<String, dynamic> json) {
    return ReceivablesDashboardModel(
      period: json['period'] != null
          ? PeriodModel.fromJson(json['period'])
          : null,
      kpis: json['kpis'] != null
          ? ReceivablesKpis.fromJson(json['kpis'])
          : null,
      aging: json['aging'] != null
          ? AgingModel.fromJson(json['aging'])
          : null,
      attentionInvoices: json['attentionInvoices'] != null
          ? List<AttentionInvoice>.from(
        json['attentionInvoices'].map(
              (x) => AttentionInvoice.fromJson(x),
        ),
      )
          : [],
      collectionPerformance: json['collectionPerformance'] != null
          ? CollectionPerformance.fromJson(
        json['collectionPerformance'],
      )
          : null,
      collectionRisk: json['collectionRisk'] != null
          ? CollectionRisk.fromJson(json['collectionRisk'])
          : null,
      reconciliation: json['reconciliation'] != null
          ? Reconciliation.fromJson(json['reconciliation'])
          : null,
    );
  }
}


// ============================================================
// PERIOD
// ============================================================

class PeriodModel {
  final String from;
  final String to;

  PeriodModel({
    required this.from,
    required this.to,
  });

  factory PeriodModel.fromJson(Map<String, dynamic> json) {
    return PeriodModel(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}


// ============================================================
// KPIs
// ============================================================

class ReceivablesKpis {
  final ReceivableKpi totalReceivables;
  final ReceivableKpi overdueReceivables;
  final ReceivableKpi notDueReceivables;
  final ReceivableKpi customersPastDue;

  ReceivablesKpis({
    required this.totalReceivables,
    required this.overdueReceivables,
    required this.notDueReceivables,
    required this.customersPastDue,
  });

  factory ReceivablesKpis.fromJson(Map<String, dynamic> json) {
    return ReceivablesKpis(
      totalReceivables: ReceivableKpi.fromJson(
        json['totalReceivables'] ?? {},
      ),
      overdueReceivables: ReceivableKpi.fromJson(
        json['overdueReceivables'] ?? {},
      ),
      notDueReceivables: ReceivableKpi.fromJson(
        json['notDueReceivables'] ?? {},
      ),
      customersPastDue: ReceivableKpi.fromJson(
        json['customersPastDue'] ?? {},
      ),
    );
  }
}


class ReceivableKpi {
  final double amount;
  final int count;

  ReceivableKpi({
    required this.amount,
    required this.count,
  });

  factory ReceivableKpi.fromJson(Map<String, dynamic> json) {
    return ReceivableKpi(
      amount: (json['amount'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}


// ============================================================
// AGING
// ============================================================

class AgingModel {
  final AgingItem notDue;
  final AgingItem days1to30;
  final AgingItem days31to60;
  final AgingItem days61to90;
  final AgingItem days90Plus;

  AgingModel({
    required this.notDue,
    required this.days1to30,
    required this.days31to60,
    required this.days61to90,
    required this.days90Plus,
  });

  factory AgingModel.fromJson(Map<String, dynamic> json) {
    return AgingModel(
      notDue: AgingItem.fromJson(json['notDue'] ?? {}),
      days1to30: AgingItem.fromJson(json['days1to30'] ?? {}),
      days31to60: AgingItem.fromJson(json['days31to60'] ?? {}),
      days61to90: AgingItem.fromJson(json['days61to90'] ?? {}),
      days90Plus: AgingItem.fromJson(json['days90Plus'] ?? {}),
    );
  }
}


class AgingItem {
  final double amount;
  final String percentage;

  AgingItem({
    required this.amount,
    required this.percentage,
  });

  factory AgingItem.fromJson(Map<String, dynamic> json) {
    return AgingItem(
      amount: (json['amount'] ?? 0).toDouble(),
      percentage: json['pct']?.toString() ?? '0.0',
    );
  }
}


// ============================================================
// ATTENTION INVOICES
// ============================================================

class AttentionInvoice {
  final String customer;
  final String invoiceNo;
  final String? dueDate;
  final int daysOverdue;
  final double balance;
  final String status;

  AttentionInvoice({
    required this.customer,
    required this.invoiceNo,
    this.dueDate,
    required this.daysOverdue,
    required this.balance,
    required this.status,
  });

  factory AttentionInvoice.fromJson(Map<String, dynamic> json) {
    return AttentionInvoice(
      customer: json['customer'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      dueDate: json['dueDate'],
      daysOverdue: json['daysOverdue'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}


// ============================================================
// COLLECTION PERFORMANCE
// ============================================================

class CollectionPerformance {
  final double dso;
  final double? avgDaysOverdue;
  final double overdueShare;
  final double periodSales;

  CollectionPerformance({
    required this.dso,
    this.avgDaysOverdue,
    required this.overdueShare,
    required this.periodSales,
  });

  factory CollectionPerformance.fromJson(
      Map<String, dynamic> json,
      ) {
    return CollectionPerformance(
      dso: (json['dso'] ?? 0).toDouble(),
      avgDaysOverdue: json['avgDaysOverdue'] != null
          ? (json['avgDaysOverdue']).toDouble()
          : null,
      overdueShare: (json['overdueShare'] ?? 0).toDouble(),
      periodSales: (json['periodSales'] ?? 0).toDouble(),
    );
  }
}


// ============================================================
// COLLECTION RISK
// ============================================================

class CollectionRisk {
  final String level;
  final double overdueShare;
  final double severeShare;
  final List<RiskReason> reasons;

  CollectionRisk({
    required this.level,
    required this.overdueShare,
    required this.severeShare,
    required this.reasons,
  });

  factory CollectionRisk.fromJson(Map<String, dynamic> json) {
    return CollectionRisk(
      level: json['level'] ?? '',
      overdueShare: (json['overdueShare'] ?? 0).toDouble(),
      severeShare: (json['severeShare'] ?? 0).toDouble(),
      reasons: json['reasons'] != null
          ? List<RiskReason>.from(
        json['reasons'].map(
              (x) => RiskReason.fromJson(x),
        ),
      )
          : [],
    );
  }
}


class RiskReason {
  final String text;
  final String tone;

  RiskReason({
    required this.text,
    required this.tone,
  });

  factory RiskReason.fromJson(Map<String, dynamic> json) {
    return RiskReason(
      text: json['text'] ?? '',
      tone: json['tone'] ?? '',
    );
  }
}


// ============================================================
// RECONCILIATION
// ============================================================

class Reconciliation {
  final double subledger;
  final double gl1100;
  final double difference;
  final String asOf;

  Reconciliation({
    required this.subledger,
    required this.gl1100,
    required this.difference,
    required this.asOf,
  });

  factory Reconciliation.fromJson(Map<String, dynamic> json) {
    return Reconciliation(
      subledger: (json['subledger'] ?? 0).toDouble(),
      gl1100: (json['gl1100'] ?? 0).toDouble(),
      difference: (json['difference'] ?? 0).toDouble(),
      asOf: json['asOf'] ?? '',
    );
  }
}