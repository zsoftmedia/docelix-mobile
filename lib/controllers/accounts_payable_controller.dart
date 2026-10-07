import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/accounts_payable_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:get/get.dart';

class AccountsPayableController extends GetxController {
  final dioClient = DioClient();
  final sessionManager = SessionManager();

  final RxBool isLoading = false.obs;

  // ============================================================
  // ALL PAYABLE BILLS
  // ============================================================

  final RxList<AccountsPayableModel> payableBills =
      <AccountsPayableModel>[].obs;

  // ============================================================
  // FILTERED / SEARCHED BILLS
  // ============================================================

  final RxList<AccountsPayableModel> filteredPayableBills =
      <AccountsPayableModel>[].obs;

  // ============================================================
  // SEARCH
  // ============================================================

  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  // ============================================================
  // TOTAL
  // ============================================================

  final RxInt totalPayableBills = 0.obs;

  // ============================================================
  // PAGINATION
  // ============================================================

  final RxInt currentPage = 1.obs;
  final RxInt limit = 20.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    getPayableBills();
  }

  // ============================================================
  // CURRENCY
  // ============================================================

  String getCurrencySymbol(String? code) {
    final String rawCode =
    (code != null && code.trim().isNotEmpty)
        ? code.trim().toUpperCase()
        : (SessionManager.accessCorrencycode
        ?.trim()
        .toUpperCase() ??
        'EUR');

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

  // ============================================================
  // FORMAT CURRENCY
  // ============================================================

  String formatCurrency(
      num? amount,
      String? currencyCode,
      ) {
    final double value = (amount ?? 0).toDouble();

    final String symbol =
    getCurrencySymbol(currencyCode);

    final parts =
    value.toStringAsFixed(2).split('.');

    final String integerPart = parts[0];
    final String decimalPart = parts[1];

    final String formattedInteger =
    integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );

    return '$symbol $formattedInteger.$decimalPart';
  }

  // ============================================================
  // GET PAYABLE BILLS
  // ============================================================

  Future<void> getPayableBills() async {
    try {
      isLoading.value = true;

      final accessToken =
          SessionManager.accessToken;

      final companyId =
          SessionManager.accessCompanyid;

      // ----------------------------------------------------------
      // TOKEN
      // ----------------------------------------------------------

      if (accessToken == null ||
          accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message:
          'Access token is not available.',
        );
        return;
      }

      // ----------------------------------------------------------
      // COMPANY ID
      // ----------------------------------------------------------

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message:
          'Company ID is not available.',
        );
        return;
      }

      final int parsedCompanyId =
      int.parse(companyId.toString());

      // ----------------------------------------------------------
      // API
      // ----------------------------------------------------------

      final response =
      await dioClient.getPayableBills(
        companyId: parsedCompanyId,
        accessToken: accessToken,
      );

      // ----------------------------------------------------------
      // RESPONSE
      // ----------------------------------------------------------

      if (response.statusCode == 200 &&
          response.data != null) {
        final data = response.data;

        if (data is List) {
          final List<AccountsPayableModel>
          loadedBills = data
              .where((item) => item is Map)
              .map(
                (item) =>
                AccountsPayableModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
          )
              .toList();

          payableBills.assignAll(loadedBills);

          totalPayableBills.value =
              loadedBills.length;

          filteredPayableBills.assignAll(
            loadedBills,
          );
        } else {
          payableBills.clear();
          filteredPayableBills.clear();
          totalPayableBills.value = 0;
        }
      } else {
        payableBills.clear();
        filteredPayableBills.clear();
        totalPayableBills.value = 0;
      }
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message:
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load payable bills.',
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // SEARCH PAYABLE BILLS
  // ============================================================

  void searchPayableBills(String value) {
    searchQuery.value = value;

    final String query =
    value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredPayableBills.assignAll(
        payableBills,
      );
      return;
    }

    final List<AccountsPayableModel> results =
    payableBills.where((bill) {
      final String billNumber =
          bill.invoiceNumber
              ?.toLowerCase() ??
              '';

      final String supplier =
          bill.supplierName
              ?.toLowerCase() ??
              '';

      final String issueDate =
          bill.invoiceDate
              ?.toLowerCase() ??
              '';

      final String dueDate =
          bill.dueDate
              ?.toLowerCase() ??
              '';

      final String status =
          bill.status
              ?.toLowerCase() ??
              '';

      final String total =
          bill.totalAmount
              ?.toString()
              .toLowerCase() ??
              '';

      final String balance =
          bill.remainingAmount
              ?.toString()
              .toLowerCase() ??
              '';

      return billNumber.contains(query) ||
          supplier.contains(query) ||
          issueDate.contains(query) ||
          dueDate.contains(query) ||
          status.contains(query) ||
          total.contains(query) ||
          balance.contains(query);
    }).toList();

    filteredPayableBills.assignAll(results);
  }

  // ============================================================
  // OPEN SEARCH
  // ============================================================

  void openSearch() {
    isSearching.value = true;
    searchQuery.value = '';

    filteredPayableBills.assignAll(
      payableBills,
    );
  }

  // ============================================================
  // CLOSE SEARCH
  // ============================================================

  void closeSearch() {
    isSearching.value = false;
    searchQuery.value = '';

    filteredPayableBills.assignAll(
      payableBills,
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshPayableBills() async {
    currentPage.value = 1;

    await getPayableBills();

    if (isSearching.value &&
        searchQuery.value.trim().isNotEmpty) {
      searchPayableBills(
        searchQuery.value,
      );
    }
  }
}