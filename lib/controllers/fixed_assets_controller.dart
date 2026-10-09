import 'dart:async';

import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FixedAssetsController extends GetxController {
  final DioClient _dioClient = DioClient();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMeta = false.obs;
  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final RxList<AssetModel> filteredAssets = <AssetModel>[].obs;
  final RxList<AssetCategory> categories = <AssetCategory>[].obs;
  final RxList<LedgerAccount> accounts = <LedgerAccount>[].obs;

  final RxString searchQuery = ''.obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnString selectedStatus = RxnString();
  final RxnInt selectedAccountId = RxnInt();

  Timer? _searchDebounce;
  int _assetsRequestId = 0;

  static const List<String> statusOptions = [
    'Active',
    'Under Repair',
    'Sold',
    'Scrapped',
    'Archived',
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

  int get totalAssetsCount =>
      assets.where((a) => a.status.toLowerCase() == 'active').length;

  double get totalBookValue => assets.fold<double>(
        0,
        (sum, asset) => sum + asset.currentBookValue,
      );

  double get annualDepreciation => assets.fold<double>(
        0,
        (sum, asset) => sum + asset.estimatedAnnualDepreciation,
      );

  int get nearEndOfLifeCount =>
      assets.where((asset) => asset.isNearEndOfLife).length;

  List<String> get availableStatuses => statusOptions;

  String? _statusQueryValue(String? status) {
    if (status == null || status.trim().isEmpty) return null;
    return status.trim().replaceAll(' ', '_');
  }

  bool get hasActiveFilters =>
      searchQuery.value.trim().isNotEmpty ||
      selectedCategoryId.value != null ||
      selectedStatus.value != null ||
      selectedAccountId.value != null;

  @override
  void onInit() {
    super.onInit();
    loadAssets(includeMeta: true);
  }

  Future<void> loadAssets({bool includeMeta = false}) async {
    final requestId = ++_assetsRequestId;

    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );
        return;
      }

      if (companyId == null || companyId == 0) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );
        return;
      }

      if (includeMeta) {
        isLoadingMeta.value = true;
        await Future.wait([
          _loadCategories(companyId, accessToken),
          _loadAccounts(companyId, accessToken),
        ]);
        if (requestId != _assetsRequestId) return;
        isLoadingMeta.value = false;
      }

      final assetsResponse = await _dioClient.getAssets(
        companyId: companyId,
        accessToken: accessToken,
        name: searchQuery.value.trim().isEmpty
            ? null
            : searchQuery.value.trim(),
        status: _statusQueryValue(selectedStatus.value),
        assetCategoryId: selectedCategoryId.value,
        assetAccountId: selectedAccountId.value,
      );

      if (requestId != _assetsRequestId) return;

      if (assetsResponse.statusCode == 200 && assetsResponse.data is List) {
        final loaded = (assetsResponse.data as List)
            .whereType<Map>()
            .map((item) => AssetModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        assets.assignAll(loaded);
        filteredAssets.assignAll(loaded);
      } else {
        assets.clear();
        filteredAssets.clear();
      }
    } on DioException catch (e) {
      if (requestId != _assetsRequestId) return;
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ??
            'Unable to load assets.',
      );
    } catch (e) {
      if (requestId != _assetsRequestId) return;
      AppSnackbar.error(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      if (requestId == _assetsRequestId) {
        isLoading.value = false;
        isLoadingMeta.value = false;
      }
    }
  }

  Future<void> _loadCategories(int companyId, String accessToken) async {
    final categoriesResponse = await _dioClient.getAssetCategories(
      companyId: companyId,
      accessToken: accessToken,
    );

    if (categoriesResponse.statusCode == 200 &&
        categoriesResponse.data is List) {
      final loadedCategories = (categoriesResponse.data as List)
          .whereType<Map>()
          .map(
            (item) => AssetCategory.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      categories.assignAll(loadedCategories);
    } else {
      categories.clear();
    }
  }

  Future<void> _loadAccounts(int companyId, String accessToken) async {
    final accountsResponse = await _dioClient.getLedgerAccounts(
      companyId: companyId,
      accessToken: accessToken,
    );
    accounts.assignAll(_parseLedgerAccounts(accountsResponse.data));
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

    final loaded = rawItems
        .whereType<Map>()
        .map((item) => LedgerAccount.fromJson(Map<String, dynamic>.from(item)))
        .where((account) => account.id > 0)
        .toList()
      ..sort((a, b) {
        final codeCompare = a.code.compareTo(b.code);
        if (codeCompare != 0) return codeCompare;
        return a.name.compareTo(b.name);
      });

    return loaded;
  }

  void search(String value) {
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      loadAssets();
    });
  }

  void setCategoryFilter(int? categoryId) {
    selectedCategoryId.value = categoryId;
    loadAssets();
  }

  void setStatusFilter(String? status) {
    selectedStatus.value = status;
    loadAssets();
  }

  void setAccountFilter(int? accountId) {
    selectedAccountId.value = accountId;
    loadAssets();
  }

  void clearFilters() {
    _searchDebounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    selectedCategoryId.value = null;
    selectedStatus.value = null;
    selectedAccountId.value = null;
    loadAssets();
  }

  String formatMoney(num value) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(value)}';
  }

  Future<void> refreshAssets() => loadAssets(includeMeta: true);

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
