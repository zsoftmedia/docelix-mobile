class StockAdjustmentModel {
  final int id;
  final int itemId;
  final String movementType;
  final double quantity;
  final String? referenceType;
  final String? referenceId;
  final String? date;
  final String? reason;
  final String? notes;
  final String? createdAt;
  final String articleName;
  final String articleNumber;
  final String unitCode;

  StockAdjustmentModel({
    required this.id,
    required this.itemId,
    required this.movementType,
    required this.quantity,
    this.referenceType,
    this.referenceId,
    this.date,
    this.reason,
    this.notes,
    this.createdAt,
    required this.articleName,
    required this.articleNumber,
    required this.unitCode,
  });

  factory StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    final itemMap = json['item'] is Map ? json['item'] as Map : {};

    return StockAdjustmentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      itemId: (json['item_id'] as num?)?.toInt() ?? 0,
      movementType: json['movement_type']?.toString() ?? 'ADJUSTMENT',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id']?.toString(),
      date: json['date']?.toString(),
      reason: json['reason']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
      articleName: itemMap['article_name']?.toString() ??
          json['article_name']?.toString() ??
          'Product Item',
      articleNumber: itemMap['article_number']?.toString() ??
          json['article_number']?.toString() ??
          '—',
      unitCode: itemMap['unit_code']?.toString() ??
          json['unit_code']?.toString() ??
          'pcs',
    );
  }

  String get displayType {
    final type = movementType.toUpperCase().trim();
    switch (type) {
      case 'INITIAL':
        return 'Opening stock';
      case 'IN':
      case 'ADD':
        return 'Stock Addition';
      case 'OUT':
      case 'REMOVE':
        return 'Stock Reduction';
      default:
        return 'Stock Adjustment';
    }
  }
}