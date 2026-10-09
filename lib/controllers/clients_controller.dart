import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/client_model.dart';
import 'package:docelix_mobileapp/models/clients_screen_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientsController extends GetxController {
  final DioClient dioClient = DioClient();

  final RxBool isLoading = false.obs;

  // ============================================================
  // CLIENT LIST
  // ============================================================

  /// Complete client list loaded from API
  final RxList<ClientScreenModel> clients =
      <ClientScreenModel>[].obs;

  /// Filtered client list displayed in UI
  final RxList<ClientScreenModel> filteredClients =
      <ClientScreenModel>[].obs;

  final Rxn<ClientScreenModel> selectedClient =
  Rxn<ClientScreenModel>();

  // ============================================================
  // SEARCH
  // ============================================================

  final RxBool isSearching = false.obs;

  final RxString searchQuery = ''.obs;

  // ============================================================
  // PAGINATION
  // ============================================================

  final RxInt totalClients = 0.obs;

  final Rxn<ClientsPagination> pagination = Rxn<ClientsPagination>();

  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 20.obs;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    getClients();
  }

  // ============================================================
  // GET CLIENTS
  // ============================================================


  Future<void> getClients({
    int page = 1,
    int pageSize = 20,
  }) async
  {

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

      final response = await dioClient.getClientsScreen(
        companyId: int.parse(companyId.toString()),
        accessToken: accessToken,
        page: page,
        pageSize: pageSize,
        sort: 'name',
        dir: 'asc',
      );

      if (response.statusCode == 200) {
        // API response is an object, not a list.
        final Map<String, dynamic> responseData =
        Map<String, dynamic>.from(response.data);

        // Extract client records.
        final List<dynamic> data =
            responseData['data'] as List<dynamic>? ?? [];

        final fetchedClients = data.map((json) {
          return ClientScreenModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          );
        }).toList();

        // Extract pagination metadata.
        final paginationJson = responseData['pagination'];

        if (paginationJson is Map) {
          pagination.value = ClientsPagination.fromJson(
            Map<String, dynamic>.from(paginationJson),
          );

          totalClients.value = pagination.value!.total;
          currentPage.value = pagination.value!.page;
          this.pageSize.value = pagination.value!.pageSize;
        } else {
          pagination.value = null;
          totalClients.value = fetchedClients.length;
          currentPage.value = page;
          this.pageSize.value = pageSize;
        }

        // Update original and displayed lists.
        clients.assignAll(fetchedClients);

        // Preserve the active search after reloading.
        if (isSearching.value &&
            searchQuery.value.trim().isNotEmpty) {
          searchClients(searchQuery.value);
        } else {
          filteredClients.assignAll(fetchedClients);
        }

        print('Clients loaded: ${clients.length}');
        print('Total clients: ${totalClients.value}');
        print('Current page: ${currentPage.value}');
        print('Page size: ${this.pageSize.value}');
      } else {
        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to load clients.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Get Clients Error: $e');
      debugPrintStack(stackTrace: stackTrace);

      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to load clients.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REAL-TIME SEARCH
  // ============================================================

  void searchClients(String value) {
    searchQuery.value = value;

    final String query =
    value.trim().toLowerCase();

    // ----------------------------------------------------------
    // EMPTY SEARCH
    // ----------------------------------------------------------

    if (query.isEmpty) {
      filteredClients.assignAll(
        clients,
      );
      return;
    }

    // ----------------------------------------------------------
    // FILTER CLIENTS
    // ----------------------------------------------------------

    final List<ClientScreenModel> results =
    clients.where((client) {
      // --------------------------------------------------------
      // NAME
      // --------------------------------------------------------

      final String name =
      client.name
          .toString()
          .toLowerCase();

      // --------------------------------------------------------
      // EMAIL
      // --------------------------------------------------------

      final String email =
          client.email
              ?.toString()
              .toLowerCase() ??
              '';

      // --------------------------------------------------------
      // PHONE
      // --------------------------------------------------------

      final String phone =
          client.phone
              ?.toString()
              .toLowerCase() ??
              '';

      // --------------------------------------------------------
      // CITY
      // --------------------------------------------------------

      final String city =
          client.city
              ?.toString()
              .toLowerCase() ??
              '';

      // --------------------------------------------------------
      // COUNTRY
      // --------------------------------------------------------

      final String country =
          client.country
              ?.toString()
              .toLowerCase() ??
              '';

      // --------------------------------------------------------
      // VAT ID
      // --------------------------------------------------------

      final String vatId =
          client.vatId
              ?.toString()
              .toLowerCase() ??
              '';

      // --------------------------------------------------------
      // TAX ID
      // --------------------------------------------------------

      final String taxId =
          client.taxId
              ?.toString()
              .toLowerCase() ??
              '';

      // --------------------------------------------------------
      // MATCH
      // --------------------------------------------------------

      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query) ||
          city.contains(query) ||
          country.contains(query) ||
          vatId.contains(query) ||
          taxId.contains(query);
    }).toList();

    // ----------------------------------------------------------
    // UPDATE DISPLAYED LIST
    // ----------------------------------------------------------

    filteredClients.assignAll(
      results,
    );
  }

  // ============================================================
  // OPEN SEARCH
  // ============================================================

  void openSearch() {
    isSearching.value = true;

    searchQuery.value = '';

    // Show all clients when search opens
    filteredClients.assignAll(
      clients,
    );
  }

  // ============================================================
  // CLOSE SEARCH
  // ============================================================

  void closeSearch() {
    isSearching.value = false;

    searchQuery.value = '';

    // Restore complete client list
    filteredClients.assignAll(
      clients,
    );
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshClients() async {
    currentPage.value = 1;

    await getClients(
      page: currentPage.value,
      pageSize: pageSize.value,
    );

    // Re-apply search after refresh
    if (isSearching.value &&
        searchQuery.value.trim().isNotEmpty) {
      searchClients(
        searchQuery.value,
      );
    }
  }
}