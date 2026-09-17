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

  final RxList<ClientScreenModel> clients = <ClientScreenModel>[].obs;

  // ============================================================
  // PAGINATION
  // ============================================================

  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 10.obs;

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
        Get.snackbar(
          'Error',
          'Access token is not available.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // ----------------------------------------------------------
      // COMPANY ID
      // ----------------------------------------------------------

      if (companyId == null) {
        Get.snackbar(
          'Error',
          'Company ID is not available.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final int companyIdInt = int.parse(companyId.toString());

      print('Loading clients...');
      print('Company ID: $companyIdInt');
      print('Page: $page');
      print('Page Size: $pageSize');

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response = await dioClient.getClientsScreen(
        companyId: companyIdInt,
        accessToken: accessToken,
        page: page,
        pageSize: pageSize,
      );

      print('Clients Response: ${response.data}');

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final List<ClientScreenModel> fetchedClients = data
            .map(
              (json) => ClientScreenModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .toList();

        clients.assignAll(fetchedClients);

        currentPage.value = page;
        this.pageSize.value = pageSize;

        print('Clients loaded: ${clients.length}');
      } else {
        clients.clear();

        Get.snackbar(
          'Error',
          'Unable to load clients.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      clients.clear();

      print('Get Clients Error: $e');

      Get.snackbar(
        'Error',
        'Unable to load clients.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}