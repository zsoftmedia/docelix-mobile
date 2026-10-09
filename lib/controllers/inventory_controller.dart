import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/inventory_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryController extends GetxController {
  final DioClient _dioClient = DioClient();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSubmittingMovement = false.obs;
  final RxBool isLoadingMovements = false.obs;

  final RxList<InventoryItem> items = <InventoryItem>[].obs;
  final RxList<InventoryItem> filteredItems = <InventoryItem>[].obs;
  final RxList<InventoryMovement> movements = <InventoryMovement>[].obs;

  final RxString searchQuery = ''.obs;

  int _itemsRequestId = 0;
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();

    _searchWorker = debounce<String>(
      searchQuery,
      (value) {
        loadItems(showLoader: false);
      },
      time: const Duration(milliseconds: 350),
    );

    searchController.addListener(_onSearchTextChanged);
    loadItems();
  }

  void _onSearchTextChanged() {
    final text = searchController.text;
    if (searchQuery.value == text) return;
    searchQuery.value = text;
  }

  Future<void> loadItems({bool showLoader = true}) async {
    final requestId = ++_itemsRequestId;
    final query = searchQuery.value.trim();

    try {
      if (showLoader) {
        isLoading.value = true;
      } else {
        isSearching.value = true;
      }

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

      debugPrint(
        '[Inventory] GET /inventory/items?q=${query.isEmpty ? '' : query}&page=1&limit=25',
      );

      final response = await _dioClient.getInventoryItems(
        companyId: companyId,
        accessToken: accessToken,
        search: query.isEmpty ? null : query,
      );

      debugPrint(
        '[Inventory] status=${response.statusCode} query="$query" '
        'rawType=${response.data.runtimeType}',
      );

      if (requestId != _itemsRequestId) return;

      if (response.statusCode == 200) {
        final rawList = _extractList(response.data);
        var loaded = rawList
            .whereType<Map>()
            .map(
              (item) => InventoryItem.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();

        // Staging currently returns the full list even when `q` is sent.
        // Keep the server call, then filter locally so search still works.
        if (query.isNotEmpty) {
          final lower = query.toLowerCase();
          loaded = loaded.where((item) {
            return item.articleName.toLowerCase().contains(lower) ||
                item.skuLabel.toLowerCase().contains(lower) ||
                item.categoryLabel.toLowerCase().contains(lower) ||
                (item.description?.toLowerCase().contains(lower) ?? false);
          }).toList();
        }

        debugPrint('[Inventory] parsed ${loaded.length} items (query="$query")');

        items
          ..clear()
          ..addAll(loaded);
        filteredItems
          ..clear()
          ..addAll(loaded);
        items.refresh();
        filteredItems.refresh();
      } else {
        items.clear();
        filteredItems.clear();
      }
    } on DioException catch (e) {
      if (requestId != _itemsRequestId) return;
      debugPrint('[Inventory] DioException: ${e.message} url=${e.requestOptions.uri}');
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ??
            'Unable to load inventory.',
      );
    } catch (e) {
      if (requestId != _itemsRequestId) return;
      debugPrint('[Inventory] Error: $e');
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      if (requestId == _itemsRequestId) {
        isLoading.value = false;
        isSearching.value = false;
      }
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['data'] is List) return map['data'] as List;
      if (map['items'] is List) return map['items'] as List;
    }
    return const [];
  }

  void search(String value) {
    // Keep Rx in sync even if listener already handled it.
    if (searchQuery.value != value) {
      searchQuery.value = value;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadItems(showLoader: false);
  }

  Future<List<InventoryMovement>> loadMovements(InventoryItem item) async {
    try {
      isLoadingMovements.value = true;
      movements.clear();

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null ||
          accessToken.isEmpty ||
          companyId == null ||
          companyId == 0) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Session is not available.',
        );
        return [];
      }

      final response = await _dioClient.getInventoryMovements(
        itemId: item.id,
        companyId: companyId,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final rawList = _extractList(response.data);
        final loaded = rawList
            .whereType<Map>()
            .map(
              (row) =>
                  InventoryMovement.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList();
        movements.assignAll(loaded);
        return loaded;
      }

      return [];
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ??
            'Unable to load movements.',
      );
      return [];
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return [];
    } finally {
      isLoadingMovements.value = false;
    }
  }

  Future<bool> logMovement({
    required InventoryItem item,
    required String movementType,
    required double quantity,
    String? notes,
    bool refreshList = true,
    bool showSuccessSnackbar = true,
  }) async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null ||
        accessToken.isEmpty ||
        companyId == null ||
        companyId == 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Session is not available.',
      );
      return false;
    }

    final body = <String, dynamic>{
      'company_id': companyId,
      'item_id': item.id,
      'movement_type': movementType,
      'quantity': quantity,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    try {
      isSubmittingMovement.value = true;
      final response = await _dioClient.createInventoryMovement(
        itemId: item.id,
        body: body,
        accessToken: accessToken,
        companyId: companyId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (showSuccessSnackbar) {
          AppSnackbar.success(
            title: 'Success',
            message: 'Stock movement logged.',
          );
        }
        if (refreshList) {
          await loadItems(showLoader: false);
        }
        return true;
      }

      AppSnackbar.error(
        title: 'Error',
        message: response.data?['message']?.toString() ??
            response.data?['error']?.toString() ??
            'Unable to log movement.',
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.response?.data?['error']?.toString() ??
            e.message ??
            'Unable to log movement.',
      );
      return false;
    } catch (e) {
      AppSnackbar.error(title: 'Error', message: e.toString());
      return false;
    } finally {
      isSubmittingMovement.value = false;
    }
  }

  Future<void> refreshItems() => loadItems();

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    super.onClose();
  }
}
