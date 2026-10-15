import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

class SupplierController extends GetxController {
  final DioClient _dioClient = DioClient();

  final RxList<SupplierModel> suppliers = <SupplierModel>[].obs;
  final RxList<SupplierModel> filteredSuppliers = <SupplierModel>[].obs;

  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  final int pageSize = 20;

  int currentPage = 1;
  int totalSuppliers = 0;

  bool get hasMore => suppliers.length < totalSuppliers;

  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();

    _searchWorker = debounce<String>(
      searchQuery,
      (_) => _applySearch(),
      time: const Duration(milliseconds: 300),
    );

    fetchSuppliers(refresh: true);
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void _applySearch() {
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredSuppliers.assignAll(suppliers);
      return;
    }

    filteredSuppliers.assignAll(
      suppliers.where((supplier) {
        return supplier.name.toLowerCase().contains(query) ||
            (supplier.contactName ?? '').toLowerCase().contains(query) ||
            (supplier.email ?? '').toLowerCase().contains(query) ||
            (supplier.phone ?? '').toLowerCase().contains(query);
      }),
    );
  }

  Future<void> fetchSuppliers({bool refresh = false}) async {
    if (refresh) {
      currentPage = 1;
      totalSuppliers = 0;
      suppliers.clear();
      filteredSuppliers.clear();
      errorMessage.value = '';
    }

    if (isLoading.value || isLoadingMore.value) return;

    if (!refresh && !hasMore && suppliers.isNotEmpty) return;

    if (refresh || suppliers.isEmpty) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    errorMessage.value = '';

    try {
      final token = SessionManager.accessToken;
      final companyIdValue = SessionManager.accessCompanyid;
      final companyId = companyIdValue != null
          ? int.tryParse(companyIdValue.toString())
          : null;

      if (token == null || token.isEmpty) {
        errorMessage.value =
            'Session token is missing. Please log in again.';
        return;
      }

      if (companyId == null || companyId <= 0) {
        errorMessage.value =
            'Company ID is missing. Please select a company.';
        return;
      }

      debugPrint(
          'Fetching suppliers for company: $companyId, page: $currentPage');

      final Response response = await _dioClient.getSuppliers(
        companyId: companyId,
        page: currentPage,
        pageSize: pageSize,
        accessToken: token,
      );

      final responseData = response.data;

      List<SupplierModel> fetchedSuppliers = [];
      int totalCount = 0;
      int pageNumber = currentPage;

      if (responseData is Map) {
        final mapData = Map<String, dynamic>.from(responseData);
        final rawList =
            mapData['data'] is List ? mapData['data'] as List : [];

        fetchedSuppliers = rawList
            .whereType<Map>()
            .map((e) => SupplierModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();

        if (mapData['pagination'] is Map) {
          final pagination =
              Map<String, dynamic>.from(mapData['pagination'] as Map);
          totalCount = int.tryParse(
                  pagination['total']?.toString() ?? '') ??
              fetchedSuppliers.length;
          pageNumber = int.tryParse(
                  pagination['page']?.toString() ?? '') ??
              currentPage;
        } else {
          totalCount = fetchedSuppliers.length;
        }
      } else if (responseData is List) {
        fetchedSuppliers = responseData
            .whereType<Map>()
            .map((e) => SupplierModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
        totalCount = fetchedSuppliers.length;
      }

      if (refresh) {
        suppliers.assignAll(fetchedSuppliers);
      } else {
        final existingIds = suppliers.map((e) => e.id).toSet();
        suppliers.addAll(
          fetchedSuppliers
              .where((supplier) => !existingIds.contains(supplier.id)),
        );
      }

      totalSuppliers = totalCount;
      currentPage = pageNumber + 1;

      _applySearch();

      debugPrint('Suppliers loaded successfully: ${suppliers.length}');
    } on DioException catch (e) {
      debugPrint('Suppliers Dio Error: ${e.message}, Response: ${e.response?.data}');

      errorMessage.value = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ??
              e.response?.data['error']?.toString() ??
              'Unable to load suppliers.')
          : 'Unable to connect. Please try again.';
    } catch (e, stack) {
      debugPrint('Suppliers Exception: $e');
      debugPrintStack(stackTrace: stack);
      errorMessage.value = 'Unable to load suppliers. Please try again.';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshSuppliers() async {
    await fetchSuppliers(refresh: true);
  }

  Future<void> loadMore() async {
    if (!isLoading.value && !isLoadingMore.value && hasMore) {
      await fetchSuppliers();
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    _applySearch();
  }
}