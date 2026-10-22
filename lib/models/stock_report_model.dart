class StockReportRowModel {
  final int itemId;
  final String articleName;
  final String articleNumber;
  final String? category;
  final String unitCode;
  final double minStock;
  final double opening;
  final double qtyIn;
  final double qtyOut;
  final double closing;
  final double movements;
  final String status;

  StockReportRowModel({
    required this.itemId,
    required this.articleName,
    required this.articleNumber,
    this.category,
    required this.unitCode,
    required this.minStock,
    required this.opening,
    required this.qtyIn,
    required this.qtyOut,
    required this.closing,
    required this.movements,
    required this.status,
  });

  factory StockReportRowModel.fromJson(Map<String, dynamic> json) {
    return StockReportRowModel(
      itemId: (json['item_id'] as num?)?.toInt() ?? 0,
      articleName: json['article_name']?.toString() ?? 'Stock Item',
      articleNumber: json['article_number']?.toString() ?? '—',
      category: json['category']?.toString(),
      unitCode: json['unit_code']?.toString() ?? 'pcs',
      minStock: (json['min_stock'] as num?)?.toDouble() ?? 0.0,
      opening: (json['opening'] as num?)?.toDouble() ?? 0.0,
      qtyIn: (json['qty_in'] as num?)?.toDouble() ?? 0.0,
      qtyOut: (json['qty_out'] as num?)?.toDouble() ?? 0.0,
      closing: (json['closing'] as num?)?.toDouble() ?? 0.0,
      movements: (json['movements'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'ok',
    );
  }

  bool get isOutOfStock => status.toLowerCase() == 'out' || closing <= 0;
  bool get isLowStock => status.toLowerCase() == 'low' || (closing > 0 && closing <= minStock);
}