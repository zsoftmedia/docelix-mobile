import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/quotation_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class QuotationController extends GetxController {
  final DioClient dioClient = DioClient();

  final RxBool isLoading = false.obs;
  final RxList<QuotationModel> quotations = <QuotationModel>[].obs;
  final RxList<QuotationModel> filteredQuotations = <QuotationModel>[].obs;

  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'All'.obs;

  final List<String> statusOptions = const [
    'All',
    'Draft',
    'Sent',
    'Accepted',
    'Rejected',
  ];

  @override
  void onInit() {
    super.onInit();
    getOffers();
  }

  Future<void> getOffers() async {
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

      debugPrint('Fetching offers/quotations for company: $companyIdInt');

      final response = await dioClient.getOffers(
        companyId: companyIdInt,
        accessToken: accessToken,
      );

      debugPrint('Get Offers Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> items = [];

        if (response.data is List) {
          items = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final map = Map<String, dynamic>.from(response.data as Map);
          items = map['data'] as List<dynamic>? ?? map['items'] as List<dynamic>? ?? [];
        }

        final List<QuotationModel> loaded = items
            .map(
              (item) => QuotationModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        quotations.assignAll(loaded);
        _applyFilters();

        debugPrint('Quotations/Offers Loaded: ${quotations.length}');
      } else {
        quotations.clear();
        filteredQuotations.clear();
      }
    } on DioException catch (e) {
      debugPrint('Get Offers Dio Error: ${e.message}');
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load quotations.',
      );
    } catch (e) {
      debugPrint('Get Offers Exception: $e');
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

    List<QuotationModel> result = List.from(quotations);

    if (status != 'all') {
      result = result
          .where((item) => item.status.toLowerCase().trim() == status)
          .toList();
    }

    if (query.isNotEmpty) {
      result = result.where((item) {
        final numStr = item.offerNumber.toLowerCase();
        final client = (item.clientName ?? '').toLowerCase();
        final date = item.issueDate.toLowerCase();

        return numStr.contains(query) ||
            client.contains(query) ||
            date.contains(query);
      }).toList();
    }

    filteredQuotations.assignAll(result);
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

  Future<void> refreshQuotations() async {
    await getOffers();
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

  String formatCurrency(num? amount, [String? currencyCode]) {
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