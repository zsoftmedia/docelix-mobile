

import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/models/incoming_invoices_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:get/get.dart';

class InvoicesController extends GetxController {
  final dioClient = DioClient();
  final sessionManager = SessionManager();

  final RxBool isLoading = false.obs;

  /// Invoice list
  final RxList<IncomingInvoicesModel> invoices =
      <IncomingInvoicesModel>[].obs;

  /// Total invoices from API
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

      if (accessToken == null || accessToken.isEmpty) {
        Get.snackbar(
          'Error',
          'Access token is not available.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (companyId == null) {
        Get.snackbar(
          'Error',
          'Company ID is not available.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final response =
      await dioClient.getIncomingInvoices(
        companyId: int.parse(
          companyId.toString(),
        ),
        page: currentPage.value,
        limit: limit.value,
        accessToken: accessToken,
      );

      if (response.data != null) {
        final data = response.data;

        final List<dynamic> items =
            data['items'] ?? [];

        totalInvoices.value =
            data['total'] ?? 0;

        invoices.value = items
            .map(
              (item) =>
                  IncomingInvoicesModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
        )
            .toList();

        print('================================');
        print('INVOICES LOADED');
        print('Total: ${totalInvoices.value}');
        print('Current Page: ${currentPage.value}');
        print('Items: ${invoices.length}');
        print('================================');
      }
    } on DioException catch (e) {
      print('================================');
      print('GET INVOICES ERROR');
      print('Status Code: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      print('Message: ${e.message}');
      print('================================');

      Get.snackbar(
        'Error',
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load invoices.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshInvoices() async {
    currentPage.value = 1;
    await getInvoices();
  }
}