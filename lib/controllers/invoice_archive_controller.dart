import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class InvoiceArchiveController extends GetxController {
  final DioClient dioClient = DioClient();

  final RxBool isLoading = false.obs;
  final RxList<PurchaseInvoicesModel> invoices = <PurchaseInvoicesModel>[].obs;
  final RxList<PurchaseInvoicesModel> filteredInvoices = <PurchaseInvoicesModel>[].obs;

  final RxInt totalInvoices = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt limit = 20.obs;

  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'All'.obs;

  final List<String> statusOptions = const [
    'All',
    'Paid',
    'Unpaid',
    'Pending',
    'Draft',
  ];

  @override
  void onInit() {
    super.onInit();
    getIncomingInvoices();
  }

  Future<void> getIncomingInvoices({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
    }

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

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );
        return;
      }

      final int companyIdInt = int.parse(companyId.toString());

      debugPrint(
          'Fetching incoming invoices archive for company: $companyIdInt, page: ${currentPage.value}');

      final response = await dioClient.getIncomingInvoices(
        companyId: companyIdInt,
        page: currentPage.value,
        limit: limit.value,
        accessToken: accessToken,
      );

      debugPrint('Incoming Invoices Archive Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> items = [];

        if (response.data is Map) {
          final Map<String, dynamic> responseData =
              Map<String, dynamic>.from(response.data as Map);

          items = responseData['items'] as List<dynamic>? ??
              responseData['data'] as List<dynamic>? ??
              [];

          totalInvoices.value = responseData['total'] is num
              ? (responseData['total'] as num).toInt()
              : items.length;
        } else if (response.data is List) {
          items = response.data as List<dynamic>;
          totalInvoices.value = items.length;
        }

        final List<PurchaseInvoicesModel> loaded = items
            .map(
              (item) => PurchaseInvoicesModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        invoices.assignAll(loaded);
        _applyFilters();

        debugPrint('Incoming Invoices Archive Loaded: ${invoices.length}');
      } else {
        invoices.clear();
        filteredInvoices.clear();
        totalInvoices.value = 0;
      }
    } on DioException catch (e) {
      debugPrint('Get Incoming Invoices Dio Error: ${e.message}');
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load invoice archive.',
      );
    } catch (e) {
      debugPrint('Get Incoming Invoices Exception: $e');
      AppSnackbar.error(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatus.value.toLowerCase().trim();

    List<PurchaseInvoicesModel> result = List.from(invoices);

    if (status != 'all') {
      result = result.where((item) {
        final itemStatus = item.status.toLowerCase().trim();
        if (status == 'unpaid') {
          return itemStatus == 'unpaid' || itemStatus == 'not paid';
        }
        return itemStatus == status;
      }).toList();
    }

    if (query.isNotEmpty) {
      result = result.where((item) {
        final supp = (item.supplierName ?? '').toLowerCase();
        final invNum = (item.invoiceNumber ?? '').toLowerCase();
        final email = (item.supplierEmail ?? '').toLowerCase();
        final date = (item.invoiceDate ?? '').toLowerCase();
        final category = (item.expenseCategory ?? '').toLowerCase();

        return supp.contains(query) ||
            invNum.contains(query) ||
            email.contains(query) ||
            date.contains(query) ||
            category.contains(query);
      }).toList();
    }

    filteredInvoices.assignAll(result);
  }

  void openSearch() {
    isSearching.value = true;
    searchQuery.value = '';
    _applyFilters();
  }

  void closeSearch() {
    isSearching.value = false;
    searchQuery.value = '';
    _applyFilters();
  }

  Future<void> refreshArchive() async {
    await getIncomingInvoices(refresh: true);
  }

  String getCurrencySymbol(String? code) {
    final String rawCode = (code != null && code.trim().isNotEmpty)
        ? code.trim().toUpperCase()
        : (SessionManager.accessCorrencycode?.trim().toUpperCase() ?? 'EUR');

    switch (rawCode) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'JPY':
        return '¥';
      case 'PKR':
        return 'Rs.';
      default:
        return rawCode;
    }
  }

  String formatCurrency(num? amount, String? currencyCode) {
    final double value = (amount ?? 0).toDouble();
    final String symbol = getCurrencySymbol(currencyCode);

    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '$symbol $formattedInteger.$decimalPart';
  }
}