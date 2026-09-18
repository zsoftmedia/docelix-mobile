import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:get/get.dart';

class CatalogController extends GetxController {
  final DioClient dioClient = DioClient();

  final RxBool isLoading = false.obs;

  // ============================================================
  // CATALOG LIST
  // ============================================================

  final RxList<CatalogModel> catalogList = <CatalogModel>[].obs;

  // ============================================================
  // PAGINATION
  // ============================================================

  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 10.obs;

  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    getCatalog();
  }

  // ============================================================
  // GET CATALOG
  // ============================================================

  Future<void> getCatalog({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      // ----------------------------------------------------------
      // ACCESS TOKEN
      // ----------------------------------------------------------

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Access token is not available.';

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
        errorMessage.value = 'Company ID is not available.';

        Get.snackbar(
          'Error',
          'Company ID is not available.',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      final int companyIdInt = int.parse(companyId.toString());

      print('======================================');
      print('Loading Catalog...');
      print('Company ID: $companyIdInt');
      print('Page: $page');
      print('Page Size: $pageSize');
      print('======================================');

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response = await dioClient.getCatalog(
        companyId: companyIdInt,
        accessToken: accessToken,
        page: page,
        pageSize: pageSize,
      );

      print('Catalog Status Code: ${response.statusCode}');
      print('Catalog Response: ${response.data}');

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final List<CatalogModel> fetchedCatalog = data
            .map(
              (json) => CatalogModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .toList();

        catalogList.assignAll(fetchedCatalog);

        currentPage.value = page;
        this.pageSize.value = pageSize;

        print('Catalog loaded: ${catalogList.length}');
      } else {
        catalogList.clear();

        errorMessage.value = 'Unable to load items.';

        Get.snackbar(
          'Error',
          'Unable to load items.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      catalogList.clear();

      errorMessage.value = 'Unable to load items.';

      print('======================================');
      print('Get Catalog Error: $e');
      print('Stack Trace: $stackTrace');
      print('======================================');

      Get.snackbar(
        'Error',
        'Unable to load items.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshCatalog() async {
    currentPage.value = 1;

    await getCatalog(
      page: 1,
      pageSize: pageSize.value,
    );
  }
}