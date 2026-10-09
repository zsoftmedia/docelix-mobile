import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/catalog_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
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
  final RxInt pageSize = 20.obs;
  final RxInt totalItems = 0.obs;

  final Rxn<CatalogPaginationModel> pagination =
  Rxn<CatalogPaginationModel>();


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
    int pageSize = 20,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Access token is not available.';

        AppSnackbar.error(
          title: 'Error',
          message: errorMessage.value,
        );
        return;
      }

      if (companyId == null) {
        errorMessage.value = 'Company ID is not available.';

        AppSnackbar.error(
          title: 'Error',
          message: errorMessage.value,
        );
        return;
      }

      final response = await dioClient.getCatalog(
        companyId: int.parse(companyId.toString()),
        accessToken: accessToken,
        page: page,
        pageSize: pageSize,
        sort: 'article_name',
        dir: 'asc',
      );

      print('Catalog Status Code: ${response.statusCode}');
      print('Catalog Response: ${response.data}');

      if (response.statusCode == 200) {
        // The API response is a JSON object.
        final Map<String, dynamic> responseData =
        Map<String, dynamic>.from(response.data as Map);

        // Extract the catalog records.
        final List<dynamic> data =
            responseData['data'] as List<dynamic>? ?? [];

        final List<CatalogModel> fetchedCatalog =
        data.map((json) {
          return CatalogModel.fromJson(
            Map<String, dynamic>.from(json as Map),
          );
        }).toList();

        // Extract pagination.
        final paginationData = responseData['pagination'];

        if (paginationData is Map) {
          final parsedPagination =
          CatalogPaginationModel.fromJson(
            Map<String, dynamic>.from(paginationData),
          );

          pagination.value = parsedPagination;
          currentPage.value = parsedPagination.page;
          this.pageSize.value = parsedPagination.pageSize;
          totalItems.value = parsedPagination.total;
        } else {
          pagination.value = null;
          currentPage.value = page;
          this.pageSize.value = pageSize;
          totalItems.value = fetchedCatalog.length;
        }

        catalogList.assignAll(fetchedCatalog);

        print('Catalog loaded: ${catalogList.length}');
        print('Total items: ${totalItems.value}');
        print('Current page: ${currentPage.value}');
        print('Page size: ${this.pageSize.value}');
      } else {
        errorMessage.value = 'Unable to load items.';

        AppSnackbar.error(
          title: 'Error',
          message: errorMessage.value,
        );
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'Unable to load items.';

      debugPrint('Get Catalog Error: $e');
      debugPrintStack(stackTrace: stackTrace);

      AppSnackbar.error(
        title: 'Error',
        message: errorMessage.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshCatalog() async {
    await getCatalog(
      page: 1,
      pageSize: pageSize.value,
    );
  }
}