class InventoryItem {
  final int id;
  final int companyId;
  final String articleName;
  final String? description;
  final String? articleNumber;
  final String? unitCode;
  final String? groupCode;
  final double stockQty;
  final double? calculatedStock;
  final bool trackStock;
  final String? itemType;
  final double? minStock;
  final bool isActive;

  const InventoryItem({
    required this.id,
    required this.companyId,
    required this.articleName,
    this.description,
    this.articleNumber,
    this.unitCode,
    this.groupCode,
    required this.stockQty,
    this.calculatedStock,
    this.trackStock = true,
    this.itemType,
    this.minStock,
    this.isActive = true,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']) ?? 0,
      articleName: json['article_name']?.toString() ?? '',
      description: json['description']?.toString(),
      articleNumber: json['article_number']?.toString(),
      unitCode: json['unit_code']?.toString(),
      groupCode: json['group_code']?.toString(),
      stockQty: _asDouble(json['stock_qty']) ?? 0,
      calculatedStock: _asDouble(json['calculated_stock']),
      trackStock: json['track_stock'] != false,
      itemType: json['item_type']?.toString(),
      minStock: _asDouble(json['min_stock']),
      isActive: json['is_active'] != false,
    );
  }

  double get currentStock => calculatedStock ?? stockQty;

  String get categoryLabel {
    final value = groupCode?.trim();
    if (value == null || value.isEmpty) return '—';
    return value;
  }

  String get skuLabel {
    final value = articleNumber?.trim();
    if (value == null || value.isEmpty) return '—';
    return value;
  }

  String get stockLabel {
    final qty = currentStock % 1 == 0
        ? currentStock.toInt().toString()
        : currentStock.toStringAsFixed(2);
    final unit = unitCode?.trim();
    if (unit == null || unit.isEmpty) return qty;
    return '$qty $unit';
  }

  bool get isNegativeStock => currentStock < 0;

  bool get isLowStock =>
      minStock != null && currentStock >= 0 && currentStock <= minStock!;
}

class InventoryMovement {
  final int? id;
  final int? itemId;
  final String movementType;
  final double quantity;
  final String? notes;
  final String? date;
  final String? createdAt;
  final String? referenceType;
  final String? referenceId;

  const InventoryMovement({
    this.id,
    this.itemId,
    required this.movementType,
    required this.quantity,
    this.notes,
    this.date,
    this.createdAt,
    this.referenceType,
    this.referenceId,
  });

  factory InventoryMovement.fromJson(Map<String, dynamic> json) {
    return InventoryMovement(
      id: _asInt(json['id']),
      itemId: _asInt(json['item_id']),
      movementType: json['movement_type']?.toString() ?? '',
      quantity: _asDouble(json['quantity']) ?? 0,
      notes: json['notes']?.toString(),
      date: json['date']?.toString(),
      createdAt: json['created_at']?.toString(),
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id']?.toString(),
    );
  }

  String get typeBadgeLabel => movementType.toUpperCase();

  String get typeLabel {
    switch (movementType.toUpperCase()) {
      case 'PURCHASE':
        return 'Purchase (Add Stock)';
      case 'ADJUSTMENT':
        return 'Manual Adjustment';
      case 'LOSS':
        return 'Loss';
      case 'DAMAGED':
        return 'Damaged';
      case 'SALE':
        return 'Sale';
      case 'RETURN':
        return 'Return';
      case 'TRANSFER':
        return 'Transfer';
      case 'INITIAL':
        return 'Initial';
      default:
        return movementType;
    }
  }

  bool get isOutbound {
    final type = movementType.toUpperCase();
    return quantity < 0 ||
        type == 'SALE' ||
        type == 'LOSS' ||
        type == 'DAMAGED';
  }

  String get displayDate {
    final raw = date ?? createdAt;
    if (raw == null || raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final local = parsed.isUtc ? parsed.toLocal() : parsed;
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  String? get referenceLabel {
    final type = referenceType?.trim();
    final id = referenceId?.trim();

    if (type == null || type.isEmpty) {
      return null;
    }

    if (type.toUpperCase() == 'INVOICE' && id != null && id.isNotEmpty) {
      return 'INVOICE #$id';
    }

    if (id == null || id.isEmpty) {
      return type.toUpperCase();
    }

    return '${type.toUpperCase()} #$id';
  }

  String get quantityLabel {
    final qty = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(2);
    if (quantity > 0) return '+$qty';
    return qty;
  }
}

class InventoryMovementTypeOption {
  final String value;
  final String label;

  const InventoryMovementTypeOption({
    required this.value,
    required this.label,
  });
}

const inventoryMovementTypeOptions = <InventoryMovementTypeOption>[
  InventoryMovementTypeOption(
    value: 'PURCHASE',
    label: 'Purchase (Add Stock)',
  ),
  InventoryMovementTypeOption(
    value: 'ADJUSTMENT',
    label: 'Manual Adjustment',
  ),
  InventoryMovementTypeOption(
    value: 'LOSS',
    label: 'Loss',
  ),
  InventoryMovementTypeOption(
    value: 'DAMAGED',
    label: 'Damaged',
  ),
];

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
