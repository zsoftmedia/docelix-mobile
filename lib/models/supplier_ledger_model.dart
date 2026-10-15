class SupplierLedgerModel {
  final List<SupplierLedgerEntryModel> entries;
  final double balance;

  const SupplierLedgerModel({
    required this.entries,
    required this.balance,
  });

  factory SupplierLedgerModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};
    final rawEntries = data['entries'];

    final List<SupplierLedgerEntryModel> parsedEntries = rawEntries is List
        ? rawEntries
            .whereType<Map>()
            .map(
              (item) => SupplierLedgerEntryModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList()
        : <SupplierLedgerEntryModel>[];

    return SupplierLedgerModel(
      entries: parsedEntries,
      balance: _toDouble(data['balance']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class SupplierLedgerEntryModel {
  final String date;
  final String type;
  final String reference;
  final int purchaseId;
  final String description;
  final double debit;
  final double credit;
  final double balance;

  const SupplierLedgerEntryModel({
    this.date = '',
    this.type = '',
    this.reference = '',
    this.purchaseId = 0,
    this.description = '',
    this.debit = 0.0,
    this.credit = 0.0,
    this.balance = 0.0,
  });

  factory SupplierLedgerEntryModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? {};

    return SupplierLedgerEntryModel(
      date: data['date']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      reference: data['reference']?.toString() ?? '',
      purchaseId: _toInt(data['purchase_id']),
      description: data['description']?.toString() ?? '',
      debit: _toDouble(data['debit']),
      credit: _toDouble(data['credit']),
      balance: _toDouble(data['balance']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}