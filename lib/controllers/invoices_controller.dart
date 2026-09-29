import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/invoice_item_model.dart';
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

  final RxList<InvoicesModel> invoices =
      <InvoicesModel>[].obs;

  // ============================================================
  // FILTERED / SEARCHED INVOICES
  // ============================================================

  final RxList<InvoicesModel> filteredInvoices =
      <InvoicesModel>[].obs;

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
  // GET INVOICES
  // ============================================================

  Future<void> getInvoices() async {
    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      // ----------------------------------------------------------
      // ACCESS TOKEN
      // ----------------------------------------------------------

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );
        return;
      }

      // ----------------------------------------------------------
      // COMPANY ID
      // ----------------------------------------------------------

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );
        return;
      }

      final int parsedCompanyId =
      int.parse(companyId.toString());

      // ----------------------------------------------------------
      // API
      // ----------------------------------------------------------

      final response = await dioClient.getInvoices(
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
          final List<InvoicesModel> loadedInvoices =
          data
              .map(
                (item) => InvoicesModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();

          // Store complete API list
          invoices.assignAll(loadedInvoices);

          // Total
          totalInvoices.value = loadedInvoices.length;

          // Initially display all
          filteredInvoices.assignAll(loadedInvoices);
        } else {
          invoices.clear();
          filteredInvoices.clear();
          totalInvoices.value = 0;
        }
      }
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message:
        e.response?.data?['message']?.toString() ??
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

    final String query =
    value.trim().toLowerCase();

    // ----------------------------------------------------------
    // EMPTY SEARCH
    // ----------------------------------------------------------

    if (query.isEmpty) {
      filteredInvoices.assignAll(invoices);
      return;
    }

    // ----------------------------------------------------------
    // SEARCH
    // ----------------------------------------------------------

    final List<InvoicesModel> results =
    invoices.where((invoice) {

      final String invoiceNumber =
          invoice.invoiceNumber
              ?.toString()
              .toLowerCase() ??
              '';

      final String status =
      invoice.status
          .toString()
          .toLowerCase();

      final String issueDate =
          invoice.issueDate
              ?.toString()
              .toLowerCase() ??
              '';

      final String currency =
          invoice.currencyCode
              ?.toString()
              .toLowerCase() ??
              '';

      final String amount =
          invoice.paidAmount
              ?.toString()
              .toLowerCase() ??
              '';

      return invoiceNumber.contains(query) ||
          status.contains(query) ||
          issueDate.contains(query) ||
          currency.contains(query) ||
          amount.contains(query);
    }).toList();

    // ----------------------------------------------------------
    // UPDATE UI
    // ----------------------------------------------------------

    filteredInvoices.assignAll(results);
  }

  // ============================================================
  // OPEN SEARCH
  // ============================================================

  void openSearch() {
    isSearching.value = true;
    searchQuery.value = '';

    // Start with all invoices
    filteredInvoices.assignAll(invoices);
  }

  // ============================================================
  // CLOSE SEARCH
  // ============================================================

  void closeSearch() {
    isSearching.value = false;
    searchQuery.value = '';

    // Restore complete list
    filteredInvoices.assignAll(invoices);
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshInvoices() async {
    currentPage.value = 1;

    await getInvoices();

    // Re-apply search if search is active
    if (isSearching.value &&
        searchQuery.value.trim().isNotEmpty) {
      searchInvoices(searchQuery.value);
    }
  }
}

/*
class InvoicesController extends GetxController {
  final dioClient = DioClient();
  final sessionManager = SessionManager();

  final RxBool isLoading = false.obs;

  /// Invoices displayed after search
  final RxList<InvoicesModel> filteredInvoices = <InvoicesModel>[].obs;
  /// Search state
  final RxBool isSearching = false.obs;
  /// Search text
  final RxString searchQuery = ''.obs;

  /// Invoice list
  final RxList<InvoicesModel> invoices =
      <InvoicesModel>[].obs;


  /// Total invoices
  final RxInt totalInvoices = 0.obs;

  /// Pagination
  final RxInt currentPage = 1.obs;
  final RxInt limit = 20.obs;

  @override
  void onInit() {
    super.onInit();

    getInvoices();
  }

  // ============================================================
  // GET INVOICES
  // ============================================================

  Future<void> getInvoices() async {
    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      // ----------------------------------------------------------
      // CHECK ACCESS TOKEN
      // ----------------------------------------------------------

      if (accessToken == null || accessToken.isEmpty) {

        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );

        return;
      }

      // ----------------------------------------------------------
      // CHECK COMPANY ID
      // ----------------------------------------------------------

      if (companyId == null) {

        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );

        return;
      }

      final int parsedCompanyId =
      int.parse(companyId.toString());

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response = await dioClient.getInvoices(
        companyId: parsedCompanyId,
        accessToken: accessToken,
      );

      // ----------------------------------------------------------
      // HANDLE RESPONSE
      // ----------------------------------------------------------

      if (response.statusCode == 200 &&
          response.data != null) {
        final data = response.data;

        if (data is List) {
          invoices.value = data
              .map(
                (item) => InvoicesModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();

          totalInvoices.value = invoices.length;

          // Initially show all invoices
          filteredInvoices.value = List<InvoicesModel>.from(
            invoices,
          );

        } else {
          invoices.clear();
          totalInvoices.value = 0;

          */
/*print('================================');
          print('INVALID INVOICES RESPONSE');
          print('Response: $data');
          print('================================');*//*

        }
      }
    } on DioException catch (e) {
      */
/*print('================================');
      print('GET INVOICES ERROR');
      print('Status Code: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      print('Message: ${e.message}');
      print('================================');*//*


      AppSnackbar.error(
        title: 'Error',
        message:  e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load invoices.',
      );

    } catch (e) {
     */
/* print('================================');
      print('GET INVOICES EXCEPTION');
      print(e);
      print('================================');*//*


      AppSnackbar.error(
        title: 'Error',
        message:  e.toString(),
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

    final query = value.trim().toLowerCase();

    // If search is empty, show all invoices
    if (query.isEmpty) {
      filteredInvoices.value =
      List<InvoicesModel>.from(invoices);
      return;
    }

    filteredInvoices.value = invoices.where((invoice) {
      final invoiceNumber =
          invoice.invoiceNumber?.toLowerCase() ?? '';

      final status =
      invoice.status.toLowerCase();

      final issueDate =
          invoice.issueDate?.toLowerCase() ?? '';

      final currency =
          invoice.currencyCode?.toLowerCase() ?? '';

      final amount =
          invoice.paidAmount?.toString().toLowerCase() ?? '';

      return invoiceNumber.contains(query) ||
          status.contains(query) ||
          issueDate.contains(query) ||
          currency.contains(query) ||
          amount.contains(query);
    }).toList();
  }

  // ============================================================
  // OPEN SEARCH
  // ============================================================

  void openSearch() {
    isSearching.value = true;
  }

  // ============================================================
  // CLOSE SEARCH
  // ============================================================

  void closeSearch() {
    isSearching.value = false;
    searchQuery.value = '';

    filteredInvoices.value =
    List<InvoicesModel>.from(invoices);
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshInvoices() async {
    currentPage.value = 1;
    await getInvoices();
  }
}*/
