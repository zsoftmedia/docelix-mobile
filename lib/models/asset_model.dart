class AssetCategory {
  final int id;
  final int? companyId;
  final String name;
  final int? defaultUsefulLifeYears;
  final String? defaultDepreciationMethod;

  const AssetCategory({
    required this.id,
    this.companyId,
    required this.name,
    this.defaultUsefulLifeYears,
    this.defaultDepreciationMethod,
  });

  factory AssetCategory.fromJson(Map<String, dynamic> json) {
    return AssetCategory(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']),
      name: json['name']?.toString() ?? '',
      defaultUsefulLifeYears: _asInt(json['default_useful_life_years']),
      defaultDepreciationMethod:
          json['default_depreciation_method']?.toString(),
    );
  }
}

class LedgerAccount {
  final int id;
  final String code;
  final String name;

  const LedgerAccount({
    required this.id,
    required this.code,
    required this.name,
  });

  factory LedgerAccount.fromJson(Map<String, dynamic> json) {
    final code = json['code']?.toString() ??
        json['account_code']?.toString() ??
        '';
    final name = json['name']?.toString() ??
        json['account_name']?.toString() ??
        '';
    return LedgerAccount(
      id: _asInt(json['id']) ?? 0,
      code: code,
      name: name,
    );
  }

  String get displayLabel {
    if (code.isNotEmpty && name.isNotEmpty) return '$code · $name';
    if (name.isNotEmpty) return name;
    if (code.isNotEmpty) return code;
    return 'Account #$id';
  }
}

class DepreciationSuggestion {
  final int id;
  final String assetName;
  final int? usefulLifeYears;
  final double? depreciationRateVh;
  final String? sourceName;
  final bool isIndustryMatch;

  const DepreciationSuggestion({
    required this.id,
    required this.assetName,
    this.usefulLifeYears,
    this.depreciationRateVh,
    this.sourceName,
    this.isIndustryMatch = false,
  });

  factory DepreciationSuggestion.fromJson(Map<String, dynamic> json) {
    return DepreciationSuggestion(
      id: _asInt(json['id']) ?? 0,
      assetName: json['asset_name']?.toString() ?? '',
      usefulLifeYears: _asInt(json['useful_life_years']),
      depreciationRateVh: _asDouble(json['depreciation_rate_vh']),
      sourceName: json['source_name']?.toString(),
      isIndustryMatch: json['is_industry_match'] == true,
    );
  }
}

class AssetModel {
  final int id;
  final int companyId;
  final int? assetCategoryId;
  final String name;
  final String? description;
  final String? supplierName;
  final String status;
  final String? purchaseDate;
  final double purchasePrice;
  final double currentBookValue;
  final int? usefulLifeYears;
  final String? depreciationMethod;
  final String? depreciationStartDate;
  final int? assetAccountId;
  final int? depreciationExpenseAccountId;
  final String? assetNumber;
  final String? serialNumber;
  final String? location;
  final String? ownershipType;
  final String? notes;
  final String? invoiceReference;
  final String? warrantyUntil;
  final String? costCenter;
  final double? annualDepreciationRate;
  final AssetCategory? category;
  final LedgerAccount? assetAccount;
  final LedgerAccount? depreciationExpenseAccount;

  const AssetModel({
    required this.id,
    required this.companyId,
    this.assetCategoryId,
    required this.name,
    this.description,
    this.supplierName,
    required this.status,
    this.purchaseDate,
    required this.purchasePrice,
    required this.currentBookValue,
    this.usefulLifeYears,
    this.depreciationMethod,
    this.depreciationStartDate,
    this.assetAccountId,
    this.depreciationExpenseAccountId,
    this.assetNumber,
    this.serialNumber,
    this.location,
    this.ownershipType,
    this.notes,
    this.invoiceReference,
    this.warrantyUntil,
    this.costCenter,
    this.annualDepreciationRate,
    this.category,
    this.assetAccount,
    this.depreciationExpenseAccount,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    AssetCategory? category;
    final rawCategory = json['category'];
    if (rawCategory is Map) {
      category = AssetCategory.fromJson(
        Map<String, dynamic>.from(rawCategory),
      );
    }

    LedgerAccount? assetAccount;
    final rawAssetAccount = json['asset_account'] ?? json['ledger_account'];
    if (rawAssetAccount is Map) {
      assetAccount = LedgerAccount.fromJson(
        Map<String, dynamic>.from(rawAssetAccount),
      );
    }

    LedgerAccount? depreciationExpenseAccount;
    final rawDepAccount = json['depreciation_expense_account'];
    if (rawDepAccount is Map) {
      depreciationExpenseAccount = LedgerAccount.fromJson(
        Map<String, dynamic>.from(rawDepAccount),
      );
    }

    return AssetModel(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']) ?? 0,
      assetCategoryId: _asInt(json['asset_category_id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      supplierName: json['supplier_name']?.toString(),
      status: json['status']?.toString() ?? '',
      purchaseDate: json['purchase_date']?.toString(),
      purchasePrice: _asDouble(json['purchase_price']) ?? 0,
      currentBookValue: _asDouble(json['current_book_value']) ?? 0,
      usefulLifeYears: _asInt(json['useful_life_years']),
      depreciationMethod: json['depreciation_method']?.toString(),
      depreciationStartDate: json['depreciation_start_date']?.toString(),
      assetAccountId: _asInt(json['asset_account_id']),
      depreciationExpenseAccountId:
          _asInt(json['depreciation_expense_account_id']),
      assetNumber: json['asset_number']?.toString(),
      serialNumber: json['serial_number']?.toString(),
      location: json['location']?.toString(),
      ownershipType: json['ownership_type']?.toString(),
      notes: json['notes']?.toString(),
      invoiceReference: json['invoice_reference']?.toString(),
      warrantyUntil: json['warranty_until']?.toString() ??
          json['warranty_end_date']?.toString(),
      costCenter: json['cost_center']?.toString(),
      annualDepreciationRate: _asDouble(json['annual_depreciation_rate']),
      category: category,
      assetAccount: assetAccount,
      depreciationExpenseAccount: depreciationExpenseAccount,
    );
  }

  String get categoryName => category?.name ?? 'Uncategorized';

  double get accumulatedDepreciation {
    final value = purchasePrice - currentBookValue;
    return value < 0 ? 0 : value;
  }

  double get estimatedAnnualDepreciation {
    if (annualDepreciationRate != null) {
      return purchasePrice * (annualDepreciationRate! / 100);
    }
    if (usefulLifeYears != null && usefulLifeYears! > 0) {
      return purchasePrice / usefulLifeYears!;
    }
    return 0;
  }

  bool get isNearEndOfLife {
    if (purchaseDate == null || usefulLifeYears == null) return false;
    final purchased = DateTime.tryParse(purchaseDate!);
    if (purchased == null) return false;

    final endDate = DateTime(
      purchased.year + usefulLifeYears!,
      purchased.month,
      purchased.day,
    );
    final now = DateTime.now();
    final inTwelveMonths = now.add(const Duration(days: 365));
    return !endDate.isBefore(now) && !endDate.isAfter(inTwelveMonths);
  }

  List<DepreciationScheduleRow> get depreciationSchedule {
    final life = usefulLifeYears ?? 0;
    if (life <= 0 || purchasePrice <= 0) return [];

    final startRaw = depreciationStartDate ?? purchaseDate;
    final start = startRaw == null ? DateTime.now() : DateTime.tryParse(startRaw);
    if (start == null) return [];

    final annual = estimatedAnnualDepreciation;
    if (annual <= 0) return [];

    final rows = <DepreciationScheduleRow>[];
    var remaining = purchasePrice;
    final currentYear = DateTime.now().year;

    for (var i = 0; i < life; i++) {
      final year = start.year + i;
      final amount = i == life - 1 ? remaining : annual;
      remaining = (remaining - amount).clamp(0, purchasePrice);
      rows.add(
        DepreciationScheduleRow(
          year: year,
          depreciation: amount,
          endingBookValue: remaining,
          isCurrent: year == currentYear,
        ),
      );
    }

    return rows;
  }
}

class DepreciationScheduleRow {
  final int year;
  final double depreciation;
  final double endingBookValue;
  final bool isCurrent;

  const DepreciationScheduleRow({
    required this.year,
    required this.depreciation,
    required this.endingBookValue,
    this.isCurrent = false,
  });
}

class AssetDocument {
  final int id;
  final int assetId;
  final String documentUrl;
  final String documentType;
  final String? createdAt;
  final String? previewUrl;

  const AssetDocument({
    required this.id,
    required this.assetId,
    required this.documentUrl,
    required this.documentType,
    this.createdAt,
    this.previewUrl,
  });

  factory AssetDocument.fromJson(Map<String, dynamic> json) {
    return AssetDocument(
      id: _asInt(json['id']) ?? 0,
      assetId: _asInt(json['asset_id']) ?? 0,
      documentUrl: json['document_url']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? 'Other',
      createdAt: json['created_at']?.toString(),
      previewUrl: json['preview_url']?.toString(),
    );
  }

  bool get isImage {
    final path = (previewUrl ?? documentUrl).toLowerCase();
    return path.contains('.png') ||
        path.contains('.jpg') ||
        path.contains('.jpeg') ||
        path.contains('.webp') ||
        path.contains('.gif') ||
        path.contains('.heic');
  }

  bool get isPdf {
    final path = (previewUrl ?? documentUrl).toLowerCase();
    return path.contains('.pdf');
  }
}

class AssetHistoryEntry {
  final int id;
  final int assetId;
  final int? companyId;
  final String fieldChanged;
  final String? previousValue;
  final String? newValue;
  final String? changedByUserId;
  final String? changedAt;

  const AssetHistoryEntry({
    required this.id,
    required this.assetId,
    this.companyId,
    required this.fieldChanged,
    this.previousValue,
    this.newValue,
    this.changedByUserId,
    this.changedAt,
  });

  factory AssetHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AssetHistoryEntry(
      id: _asInt(json['id']) ?? 0,
      assetId: _asInt(json['asset_id']) ?? 0,
      companyId: _asInt(json['company_id']),
      fieldChanged: json['field_changed']?.toString() ?? '',
      previousValue: json['previous_value']?.toString(),
      newValue: json['new_value']?.toString(),
      changedByUserId: json['changed_by_user_id']?.toString(),
      changedAt: json['changed_at']?.toString(),
    );
  }

  String get title {
    final value = newValue?.trim();
    if (value != null && value.isNotEmpty) return value;
    if (fieldChanged.isEmpty) return 'Updated';
    return fieldChanged.replaceAll('_', ' ');
  }
}

class JournalEntryLine {
  final int id;
  final int? accountId;
  final int lineNo;
  final String? description;
  final double debit;
  final double credit;
  final LedgerAccount? account;

  const JournalEntryLine({
    required this.id,
    this.accountId,
    required this.lineNo,
    this.description,
    required this.debit,
    required this.credit,
    this.account,
  });

  factory JournalEntryLine.fromJson(Map<String, dynamic> json) {
    LedgerAccount? account;
    final rawAccount = json['account'];
    if (rawAccount is Map) {
      account = LedgerAccount.fromJson(Map<String, dynamic>.from(rawAccount));
    }

    return JournalEntryLine(
      id: _asInt(json['id']) ?? 0,
      accountId: _asInt(json['account_id']),
      lineNo: _asInt(json['line_no']) ?? 0,
      description: json['description']?.toString(),
      debit: _asDouble(json['debit']) ?? 0,
      credit: _asDouble(json['credit']) ?? 0,
      account: account,
    );
  }

  String get accountLabel {
    if (account != null) return account!.displayLabel;
    return 'Account #${accountId ?? id}';
  }
}

class AssetJournalEntry {
  final int id;
  final int companyId;
  final String? entryDate;
  final String sourceType;
  final int? sourceId;
  final String description;
  final String status;
  final String? postedAt;
  final String? createdAt;
  final List<JournalEntryLine> lines;

  const AssetJournalEntry({
    required this.id,
    required this.companyId,
    this.entryDate,
    required this.sourceType,
    this.sourceId,
    required this.description,
    required this.status,
    this.postedAt,
    this.createdAt,
    this.lines = const [],
  });

  factory AssetJournalEntry.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    final lines = <JournalEntryLine>[];
    if (rawLines is List) {
      for (final item in rawLines) {
        if (item is Map) {
          lines.add(
            JournalEntryLine.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return AssetJournalEntry(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']) ?? 0,
      entryDate: json['entry_date']?.toString(),
      sourceType: json['source_type']?.toString() ?? '',
      sourceId: _asInt(json['source_id']),
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      postedAt: json['posted_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      lines: lines,
    );
  }

  double get totalAmount {
    final debits = lines.fold<double>(0, (sum, line) => sum + line.debit);
    if (debits > 0) return debits;
    return lines.fold<double>(0, (sum, line) => sum + line.credit);
  }

  String get sourceTypeLabel {
    return sourceType.replaceAll('_', ' ').toUpperCase();
  }
}

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
