class CatalogModel {
  final int? id;
  final int? companyId;
  final String? createdBy;
  final String? articleName;
  final String? description;
  final double? defaultQty;
  final double? unitPriceNet;
  final double? vatRate;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? unitCode;
  final double? unitPriceGross;
  final double? discount;
  final String? groupCode;
  final double? priceMsrp;
  final String? articleNumber;
  final String? articleNameLc;
  final double? purchasePriceNet;
  final double? stockQty;
  final bool? trackStock;
  final String? itemType;
  final double? minStock;

  CatalogModel({
    this.id,
    this.companyId,
    this.createdBy,
    this.articleName,
    this.description,
    this.defaultQty,
    this.unitPriceNet,
    this.vatRate,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.unitCode,
    this.unitPriceGross,
    this.discount,
    this.groupCode,
    this.priceMsrp,
    this.articleNumber,
    this.articleNameLc,
    this.purchasePriceNet,
    this.stockQty,
    this.trackStock,
    this.itemType,
    this.minStock,
  });

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(
      id: json['id'],
      companyId: json['company_id'],
      createdBy: json['created_by'],
      articleName: json['article_name'],
      description: json['description'],
      defaultQty: (json['default_qty'] as num?)?.toDouble(),
      unitPriceNet: (json['unit_price_net'] as num?)?.toDouble(),
      vatRate: (json['vat_rate'] as num?)?.toDouble(),
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      unitCode: json['unit_code'],
      unitPriceGross: (json['unit_price_gross'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      groupCode: json['group_code'],
      priceMsrp: (json['price_msrp'] as num?)?.toDouble(),
      articleNumber: json['article_number'],
      articleNameLc: json['article_name_lc'],
      purchasePriceNet:
      (json['purchase_price_net'] as num?)?.toDouble(),
      stockQty: (json['stock_qty'] as num?)?.toDouble(),
      trackStock: json['track_stock'],
      itemType: json['item_type'],
      minStock: (json['min_stock'] as num?)?.toDouble(),
    );
  }
}