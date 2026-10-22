import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/stock_adjustment_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class StockAdjustmentController extends GetxController {
  final DioClient dioClient = DioClient();

  final RxList<StockAdjustmentModel> adjustments = <StockAdjustmentModel>[].obs;
  final RxList<StockAdjustmentModel> filteredAdjustments = <StockAdjustmentModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getAdjustments();
  }

  Future<void> getAdjustments({int page = 1, int limit = 25}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        errorMessage.value = 'Access token is not available.';
        AppSnackbar.error(title: 'Error', message: errorMessage.value);
        return;
      }

      if (companyId == null) {
        errorMessage.value = 'Company ID is not available.';
        AppSnackbar.error(title: 'Error', message: errorMessage.value);
        return;
      }

      final int companyIdInt = int.parse(companyId.toString());

      debugPrint('Fetching inventory adjustments for company $companyIdInt, page: $page');

      final response = await dioClient.getInventoryAdjustments(
        companyId: companyIdInt,
        page: page,
        limit: limit,
        accessToken: accessToken,
      );

      debugPrint('Stock Adjustments Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> itemsList = [];

        if (response.data is Map) {
          final map = Map<String, dynamic>.from(response.data as Map);
          if (map['data'] is Map) {
            final dataMap = Map<String, dynamic>.from(map['data'] as Map);
            itemsList = dataMap['items'] as List<dynamic>? ?? [];
            totalItems.value = (dataMap['total'] as num?)?.toInt() ?? itemsList.length;
          } else if (map['items'] is List) {
            itemsList = map['items'] as List<dynamic>;
          }
        } else if (response.data is List) {
          itemsList = response.data as List<dynamic>;
        }

        final List<StockAdjustmentModel> loaded = itemsList
            .map((item) => StockAdjustmentModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();

        adjustments.assignAll(loaded);
        filterAdjustments(searchQuery.value);

        debugPrint('Stock Adjustments Loaded: ${adjustments.length}');
      } else {
        errorMessage.value = 'Unable to load stock adjustments.';
        AppSnackbar.error(title: 'Error', message: errorMessage.value);
      }
    } on DioException catch (e) {
      debugPrint('Stock Adjustments Dio Error: ${e.message}');
      errorMessage.value = 'Unable to load stock adjustments.';
      AppSnackbar.error(title: 'Error', message: errorMessage.value);
    } catch (e) {
      debugPrint('Stock Adjustments Exception: $e');
      errorMessage.value = 'Something went wrong while loading stock adjustments.';
      AppSnackbar.error(title: 'Error', message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void openSearch() {
    isSearching.value = true;
  }

  void closeSearch() {
    isSearching.value = false;
    searchQuery.value = '';
    filteredAdjustments.assignAll(adjustments);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    filterAdjustments(query);
  }

  void filterAdjustments(String query) {
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      filteredAdjustments.assignAll(adjustments);
      return;
    }

    filteredAdjustments.assignAll(
      adjustments.where((item) {
        final productName = item.articleName.toLowerCase();
        final articleNo = item.articleNumber.toLowerCase();
        final notes = (item.notes ?? '').toLowerCase();
        final reason = (item.reason ?? '').toLowerCase();
        final movementType = item.displayType.toLowerCase();

        return productName.contains(cleanQuery) ||
            articleNo.contains(cleanQuery) ||
            notes.contains(cleanQuery) ||
            reason.contains(cleanQuery) ||
            movementType.contains(cleanQuery);
      }).toList(),
    );
  }

  Future<void> refreshAdjustments() async {
    await getAdjustments(page: 1);
  }
}