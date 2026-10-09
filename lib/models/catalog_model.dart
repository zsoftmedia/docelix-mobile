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
      id: (json['id'] as num?)?.toInt(),
      companyId: (json['company_id'] as num?)?.toInt(),
      createdBy: json['created_by']?.toString(),
      articleName: json['article_name']?.toString(),
      description: json['description']?.toString(),

      defaultQty: (json['default_qty'] as num?)?.toDouble(),
      unitPriceNet: (json['unit_price_net'] as num?)?.toDouble(),
      vatRate: (json['vat_rate'] as num?)?.toDouble(),

      isActive: json['is_active'] as bool?,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      unitCode: json['unit_code']?.toString(),

      unitPriceGross:
      (json['unit_price_gross'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      groupCode: json['group_code']?.toString(),
      priceMsrp: (json['price_msrp'] as num?)?.toDouble(),

      articleNumber: json['article_number']?.toString(),
      articleNameLc: json['article_name_lc']?.toString(),

      purchasePriceNet:
      (json['purchase_price_net'] as num?)?.toDouble(),
      stockQty: (json['stock_qty'] as num?)?.toDouble(),

      trackStock: json['track_stock'] as bool?,
      itemType: json['item_type']?.toString(),
      minStock: (json['min_stock'] as num?)?.toDouble(),
    );
  }
}

class CatalogPaginationModel {
  final int page;
  final int pageSize;
  final int total;

  CatalogPaginationModel({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory CatalogPaginationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CatalogPaginationModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}