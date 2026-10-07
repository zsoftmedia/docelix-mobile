import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/accounts_receivable_model.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:get/get.dart';

class AccountsReceivableController extends GetxController {
  final dioClient = DioClient();
  final sessionManager = SessionManager();

  final RxBool isLoading = false.obs;

  // ============================================================
  // ALL RECEIVABLE INVOICES
  // ============================================================

  final RxList<AccountsReceivableModel> receivableInvoices =
      <AccountsReceivableModel>[].obs;

  // ============================================================
  // FILTERED / SEARCHED RECEIVABLE INVOICES
  // ============================================================

  final RxList<AccountsReceivableModel> filteredReceivableInvoices =
      <AccountsReceivableModel>[].obs;

  // ============================================================
  // SEARCH
  // ============================================================

  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  // ============================================================
  // TOTAL
  // ============================================================

  final RxInt totalReceivableInvoices = 0.obs;

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
    getReceivableInvoices();
  }

  // ============================================================
  // CURRENCY & FORMATTING
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

  String formatCurrency(
      num? amount,
      String? currencyCode,
      ) {
    final double value = (amount ?? 0).toDouble();

    final String symbol = getCurrencySymbol(currencyCode);

    final parts = value.toStringAsFixed(2).split('.');

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
  // GET RECEIVABLE INVOICES
  // ============================================================

  Future<void> getReceivableInvoices() async {
    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      // ----------------------------------------------------------
      // ACCESS TOKEN VALIDATION
      // ----------------------------------------------------------

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );
        return;
      }

      // ----------------------------------------------------------
      // COMPANY ID VALIDATION
      // ----------------------------------------------------------

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );
        return;
      }

      // ----------------------------------------------------------
      // PARSE COMPANY ID
      // ----------------------------------------------------------

      final int parsedCompanyId =
      int.parse(companyId.toString());

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response =
      await dioClient.getReceivableInvoices(
        companyId: parsedCompanyId,
        accessToken: accessToken,
      );

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200 &&
          response.data != null) {
        final data = response.data;

        if (data is List) {
          final List<AccountsReceivableModel>
          loadedReceivableInvoices = data
              .where((item) => item is Map)
              .map(
                (item) =>
                AccountsReceivableModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
          )
              .toList();

          receivableInvoices.assignAll(
            loadedReceivableInvoices,
          );

          totalReceivableInvoices.value =
              loadedReceivableInvoices.length;

          filteredReceivableInvoices.assignAll(
            loadedReceivableInvoices,
          );
        } else {
          receivableInvoices.clear();
          filteredReceivableInvoices.clear();
          totalReceivableInvoices.value = 0;
        }
      } else {
        receivableInvoices.clear();
        filteredReceivableInvoices.clear();
        totalReceivableInvoices.value = 0;
      }
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message:
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load accounts receivable.',
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
  // REAL-TIME SEARCH
  // ============================================================

  void searchReceivableInvoices(String value) {
    searchQuery.value = value;

    final String query =
    value.trim().toLowerCase();

    // ----------------------------------------------------------
    // EMPTY SEARCH
    // ----------------------------------------------------------

    if (query.isEmpty) {
      filteredReceivableInvoices.assignAll(
        receivableInvoices,
      );
      return;
    }

    // ----------------------------------------------------------
    // FILTER
    // ----------------------------------------------------------

    final List<AccountsReceivableModel> results =
    receivableInvoices.where((invoice) {
      final String invoiceNumber =
          invoice.invoiceNumber
              ?.toString()
              .toLowerCase() ??
              '';

      final String customer =
          invoice.clientName
              ?.toString()
              .toLowerCase() ??
              '';

      final String issueDate =
          invoice.issueDate
              ?.toString()
              .toLowerCase() ??
              '';

      final String dueDate =
          invoice.dueDate
              ?.toString()
              .toLowerCase() ??
              '';

      final String status =
          invoice.status
              ?.toString()
              .toLowerCase() ??
              '';

      final String totalAmount =
          invoice.totalAmount
              ?.toString()
              .toLowerCase() ??
              '';

      final String balance =
          invoice.remainingAmount
              ?.toString()
              .toLowerCase() ??
              '';

      return invoiceNumber.contains(query) ||
          customer.contains(query) ||
          issueDate.contains(query) ||
          dueDate.contains(query) ||
          status.contains(query) ||
          totalAmount.contains(query) ||
          balance.contains(query);
    }).toList();

    filteredReceivableInvoices.assignAll(results);
  }

  // ============================================================
  // OPEN SEARCH
  // ============================================================

  void openSearch() {
    isSearching.value = true;
    searchQuery.value = '';

    filteredReceivableInvoices.assignAll(
      receivableInvoices,
    );
  }

  // ============================================================
  // CLOSE SEARCH
  // ============================================================

  void closeSearch() {
    isSearching.value = false;
    searchQuery.value = '';

    filteredReceivableInvoices.assignAll(
      receivableInvoices,
    );
  }

  // ============================================================
  // REFRESH RECEIVABLE INVOICES
  // ============================================================

  Future<void> refreshReceivableInvoices() async {
    currentPage.value = 1;

    await getReceivableInvoices();

    // Re-apply search after refresh
    if (isSearching.value &&
        searchQuery.value.trim().isNotEmpty) {
      searchReceivableInvoices(
        searchQuery.value,
      );
    }
  }
}