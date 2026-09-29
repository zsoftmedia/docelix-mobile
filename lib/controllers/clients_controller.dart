import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/client_model.dart';
import 'package:docelix_mobileapp/models/clients_screen_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
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

  final RxInt currentPage = 1.obs;

  final RxInt pageSize = 10.obs;

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
    int pageSize = 10,
  }) async {
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

      final int companyIdInt =
      int.parse(companyId.toString());

      print('Loading clients...');
      print('Company ID: $companyIdInt');
      print('Page: $page');
      print('Page Size: $pageSize');

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response =
      await dioClient.getClientsScreen(
        companyId: companyIdInt,
        accessToken: accessToken,
        page: page,
        pageSize: pageSize,
      );

      print(
        'Clients Response: ${response.data}',
      );

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data;

        final List<ClientScreenModel>
        fetchedClients = data
            .map(
              (json) =>
              ClientScreenModel.fromJson(
                json as Map<String, dynamic>,
              ),
        )
            .toList();

        // --------------------------------------------------------
        // STORE ORIGINAL LIST
        // --------------------------------------------------------

        clients.assignAll(
          fetchedClients,
        );

        // --------------------------------------------------------
        // DISPLAY ALL CLIENTS INITIALLY
        // --------------------------------------------------------

        filteredClients.assignAll(
          fetchedClients,
        );

        currentPage.value = page;
        this.pageSize.value = pageSize;

        print(
          'Clients loaded: ${clients.length}',
        );
      } else {
        clients.clear();
        filteredClients.clear();

        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to load clients.',
        );
      }
    } catch (e) {
      clients.clear();
      filteredClients.clear();

      print(
        'Get Clients Error: $e',
      );

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