class InvoiceItemModel {
  final int id;
  final int invoiceId;
  final String itemDesc;
  final double quantity;
  final double vatRate;
  final double unitPrice;
  final double grossAmount;
  final int? catalogItemId;

  InvoiceItemModel({
    required this.id,
    required this.invoiceId,
    required this.itemDesc,
    required this.quantity,
    required this.vatRate,
    required this.unitPrice,
    required this.grossAmount,
    this.catalogItemId,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] ?? 0,
      invoiceId: json['invoice_id'] ?? 0,
      itemDesc: json['item_desc'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      vatRate: (json['vat_rate'] ?? 0).toDouble(),
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      grossAmount: (json['gross_amount'] ?? 0).toDouble(),
      catalogItemId: json['catalog_item_id'],
    );
  }
}