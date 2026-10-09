import 'dart:async';

import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateAssetController extends GetxController {
  final DioClient _dioClient = DioClient();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final assetNumberController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final bookValueController = TextEditingController();
  final usefulLifeController = TextEditingController();
  final annualRateController = TextEditingController();
  final supplierController = TextEditingController();
  final serialController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();

  final RxBool isLoadingMeta = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isSearchingAi = false.obs;
  final RxList<AssetCategory> categories = <AssetCategory>[].obs;
  final RxList<LedgerAccount> accounts = <LedgerAccount>[].obs;
  final RxList<DepreciationSuggestion> suggestions =
      <DepreciationSuggestion>[].obs;

  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedAccountId = RxnInt();
  final RxString status = 'Active'.obs;
  final RxString ownershipType = 'Owned'.obs;
  final RxString depreciationMethod = 'Linear'.obs;
  final Rx<DateTime> purchaseDate = DateTime.now().obs;

  final RxDouble purchasePrice = 0.0.obs;
  final RxDouble bookValue = 0.0.obs;
  final RxInt usefulLifeYears = 0.obs;
  final RxDouble annualRate = 0.0.obs;

  Timer? _searchDebounce;
  int _searchRequestId = 0;

  static const statusOptions = [
    'Active',
    'Under Repair',
    'Sold',
    'Scrapped',
    'Archived',
  ];

  static const ownershipOptions = [
    'Owned',
    'Leased',
    'Financed',
  ];

  static const depreciationMethodOptions = [
    'Linear',
  ];

  String get currencyCode {
    return SessionManager.accessCorrencycode?.trim().toUpperCase() ?? 'EUR';
  }

  String get currencySymbol {
    switch (currencyCode) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'PKR':
        return 'Rs ';
      default:
        return '$currencyCode ';
    }
  }

  double get fullYearWriteOff {
    if (annualRate.value > 0) {
      return purchasePrice.value * (annualRate.value / 100);
    }
    if (usefulLifeYears.value > 0) {
      return purchasePrice.value / usefulLifeYears.value;
    }
    return 0;
  }

  int get monthsActiveThisYear {
    final date = purchaseDate.value;
    final nowYear = DateTime.now().year;
    if (date.year > nowYear) return 0;
    if (date.year < nowYear) return 12;
    return 12 - date.month + 1;
  }

  double get taxReturnProRata => fullYearWriteOff * monthsActiveThisYear / 12;

  int? get remainingUsefulLife =>
      usefulLifeYears.value > 0 ? usefulLifeYears.value : null;

  int? get depreciationEndYear => remainingUsefulLife == null
      ? null
      : purchaseDate.value.year + remainingUsefulLife!;

  String formatMoney(num value) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(value)}';
  }

  @override
  void onInit() {
    super.onInit();
    purchasePriceController.addListener(_syncPurchasePrice);
    bookValueController.addListener(_syncBookValue);
    usefulLifeController.addListener(_syncUsefulLife);
    annualRateController.addListener(_syncAnnualRate);
    loadMeta();
  }

  void _syncPurchasePrice() {
    purchasePrice.value =
        double.tryParse(purchasePriceController.text.trim()) ?? 0;
  }

  void _syncBookValue() {
    bookValue.value = double.tryParse(bookValueController.text.trim()) ?? 0;
  }

  void _syncUsefulLife() {
    usefulLifeYears.value =
        int.tryParse(usefulLifeController.text.trim()) ?? 0;
  }

  void _syncAnnualRate() {
    annualRate.value =
        double.tryParse(annualRateController.text.trim()) ?? 0;
  }

  Future<void> loadMeta() async {
    try {
      isLoadingMeta.value = true;
      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty || companyId == null) {
        return;
      }

      final results = await Future.wait([
        _dioClient.getAssetCategories(
          companyId: companyId,
          accessToken: accessToken,
        ),
        _dioClient.getLedgerAccounts(
          companyId: companyId,
          accessToken: accessToken,
        ),
      ]);

      final categoriesResponse = results[0];
      final accountsResponse = results[1];

      if (categoriesResponse.statusCode == 200 &&
          categoriesResponse.data is List) {
        final loaded = (categoriesResponse.data as List)
            .whereType<Map>()
            .map(
              (item) =>
                  AssetCategory.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        categories.assignAll(loaded);
      }

      accounts.assignAll(_parseLedgerAccounts(accountsResponse.data));
    } catch (_) {
      // Form remains usable even if meta fails.
    } finally {
      isLoadingMeta.value = false;
    }
  }

  List<LedgerAccount> _parseLedgerAccounts(dynamic data) {
    List<dynamic>? rawItems;

    if (data is List) {
      rawItems = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['items'] is List) {
        rawItems = map['items'] as List;
      } else if (map['data'] is List) {
        rawItems = map['data'] as List;
      } else if (map['accounts'] is List) {
        rawItems = map['accounts'] as List;
      }
    }

    if (rawItems == null) return [];

    return rawItems
        .whereType<Map>()
        .map((item) => LedgerAccount.fromJson(Map<String, dynamic>.from(item)))
        .where((account) => account.id > 0)
        .toList()
      ..sort((a, b) {
        final codeCompare = a.code.compareTo(b.code);
        if (codeCompare != 0) return codeCompare;
        return a.name.compareTo(b.name);
      });
  }

  void onNameChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();

    if (query.length < 2) {
      suggestions.clear();
      isSearchingAi.value = false;
      return;
    }

    isSearchingAi.value = true;
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _runAiSearch(query);
    });
  }

  Future<void> _runAiSearch(String query) async {
    final requestId = ++_searchRequestId;
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty) {
      isSearchingAi.value = false;
      return;
    }

    try {
      final response = await _dioClient.searchDepreciationEngine(
        query: query,
        accessToken: accessToken,
        companyId: companyId,
      );

      if (requestId != _searchRequestId) return;

      if (response.statusCode == 200 && response.data is List) {
        final loaded = (response.data as List)
            .whereType<Map>()
            .map(
              (item) => DepreciationSuggestion.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where((item) => item.assetName.trim().isNotEmpty)
            .toList();
        suggestions.assignAll(loaded);
      } else {
        suggestions.clear();
      }
    } catch (_) {
      if (requestId == _searchRequestId) {
        suggestions.clear();
      }
    } finally {
      if (requestId == _searchRequestId) {
        isSearchingAi.value = false;
      }
    }
  }

  void selectSuggestion(DepreciationSuggestion suggestion) {
    nameController.text = suggestion.assetName;
    suggestions.clear();
    isSearchingAi.value = false;

    if (suggestion.usefulLifeYears != null) {
      usefulLifeController.text = '${suggestion.usefulLifeYears}';
    }

    if (suggestion.depreciationRateVh != null) {
      annualRateController.text =
          suggestion.depreciationRateVh!.toStringAsFixed(
        suggestion.depreciationRateVh! % 1 == 0 ? 0 : 2,
      );
    }

    depreciationMethod.value = 'Linear';
  }

  void clearSuggestions() {
    suggestions.clear();
    isSearchingAi.value = false;
  }

  Future<void> pickPurchaseDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: purchaseDate.value,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      purchaseDate.value = picked;
    }
  }

  Future<bool> submit() async {
    clearSuggestions();

    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (selectedAccountId.value == null) {
      AppSnackbar.error(
        title: 'Missing field',
        message: 'Please select a ledger account.',
      );
      return false;
    }

    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty || companyId == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Session is not available.',
      );
      return false;
    }

    final price = double.tryParse(purchasePriceController.text.trim());
    if (price == null) {
      AppSnackbar.error(
        title: 'Missing field',
        message: 'Please enter a valid purchase price.',
      );
      return false;
    }

    final parsedBookValue = bookValueController.text.trim().isEmpty
        ? null
        : double.tryParse(bookValueController.text.trim());

    final parsedLife = usefulLifeController.text.trim().isEmpty
        ? null
        : int.tryParse(usefulLifeController.text.trim());

    final parsedRate = annualRateController.text.trim().isEmpty
        ? null
        : double.tryParse(annualRateController.text.trim());

    final body = <String, dynamic>{
      'company_id': companyId,
      'name': nameController.text.trim(),
      'status': status.value,
      'purchase_date': DateFormat('yyyy-MM-dd').format(purchaseDate.value),
      'purchase_price': price,
      'asset_account_id': selectedAccountId.value,
      'ownership_type': ownershipType.value,
      'depreciation_method': depreciationMethod.value,
      if (assetNumberController.text.trim().isNotEmpty)
        'asset_number': assetNumberController.text.trim(),
      if (selectedCategoryId.value != null)
        'asset_category_id': selectedCategoryId.value,
      'current_book_value': parsedBookValue ?? price,
      if (parsedLife != null) 'useful_life_years': parsedLife,
      if (parsedRate != null) 'annual_depreciation_rate': parsedRate,
      if (supplierController.text.trim().isNotEmpty)
        'supplier_name': supplierController.text.trim(),
      if (serialController.text.trim().isNotEmpty)
        'serial_number': serialController.text.trim(),
      if (locationController.text.trim().isNotEmpty)
        'location': locationController.text.trim(),
      if (notesController.text.trim().isNotEmpty)
        'notes': notesController.text.trim(),
    };

    try {
      isSubmitting.value = true;
      final response = await _dioClient.createAsset(
        body: body,
        accessToken: accessToken,
        companyId: companyId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.success(
          title: 'Success',
          message: 'Asset created successfully.',
        );
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: response.data?['message']?.toString() ??
            response.data?['error']?.toString() ??
            'Unable to create asset.',
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ??
            'Unable to create asset.',
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    nameController.dispose();
    assetNumberController.dispose();
    purchasePriceController.dispose();
    bookValueController.dispose();
    usefulLifeController.dispose();
    annualRateController.dispose();
    supplierController.dispose();
    serialController.dispose();
    locationController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
