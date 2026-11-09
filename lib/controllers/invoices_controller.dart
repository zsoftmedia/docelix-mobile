import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:get/get.dart';

class InvoicesController extends GetxController {
  final dioClient = DioClient();
  final sessionManager = SessionManager();

  final RxBool isLoading = false.obs;

  // ============================================================
  // ALL INVOICES
  // ============================================================

  final RxList<InvoicesModel> invoices = <InvoicesModel>[].obs;

  // ============================================================
  // FILTERED / SEARCHED INVOICES
  // ============================================================

  final RxList<InvoicesModel> filteredInvoices = <InvoicesModel>[].obs;

  // ============================================================
  // STATUS TABS & FILTERING
  // ============================================================

  final RxInt selectedStatusTabIndex = 0.obs;

  static const statusTabs = <String>[
    'All Invoices',
    'Paid',
    'Unpaid',
    'Pending',
    'Overdue',
  ];

  void selectStatusTab(int index) {
    selectedStatusTabIndex.value = index;
    applyFilters();
  }

  void applyFilters() {
    List<InvoicesModel> list = invoices;

    final tabName = statusTabs[selectedStatusTabIndex.value].toLowerCase();
    if (tabName != 'all invoices') {
      list = list.where((inv) {
        final st = inv.status.toLowerCase().trim();
        if (tabName == 'unpaid') {
          return st == 'unpaid' || st == 'pending' || st == 'draft';
        }
        return st == tabName;
      }).toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((invoice) {
        final String invoiceNumber = invoice.invoiceNumber.toLowerCase();
        final String status = invoice.status.toLowerCase();
        final String issueDate = invoice.issueDate.toLowerCase();
        final String amount = invoice.grossAmount.toString();
        final String clientId = 'client #${invoice.clientId}';

        return invoiceNumber.contains(query) ||
            status.contains(query) ||
            issueDate.contains(query) ||
            amount.contains(query) ||
            clientId.contains(query);
      }).toList();
    }

    filteredInvoices.assignAll(list);
  }

  // ============================================================
  // SEARCH
  // ============================================================

  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  // ============================================================
  // TOTAL
  // ============================================================

  final RxInt totalInvoices = 0.obs;

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
    getInvoices();
  }

  // ============================================================
  // CURRENCY & FORMATTING
  // ============================================================

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

  // ============================================================
  // GET INVOICES
  // ============================================================

  Future<void> getInvoices() async {
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

      final int parsedCompanyId = int.parse(companyId.toString());

      final response = await dioClient.getInvoices(
        companyId: parsedCompanyId,
        accessToken: accessToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data is List) {
          final List<InvoicesModel> loadedInvoices = data
              .map(
                (item) => InvoicesModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();

          invoices.assignAll(loadedInvoices);
          totalInvoices.value = loadedInvoices.length;
          applyFilters();
        } else {
          invoices.clear();
          filteredInvoices.clear();
          totalInvoices.value = 0;
        }
      }
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load invoices.',
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

  void searchInvoices(String value) {
    searchQuery.value = value;
    applyFilters();
  }

  // ============================================================
  // OPEN SEARCH
  // ============================================================

  void openSearch() {
    isSearching.value = true;
    searchQuery.value = '';
    applyFilters();
  }

  // ============================================================
  // CLOSE SEARCH
  // ============================================================

  void closeSearch() {
    isSearching.value = false;
    searchQuery.value = '';
    applyFilters();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshInvoices() async {
    currentPage.value = 1;
    await getInvoices();
  }
}