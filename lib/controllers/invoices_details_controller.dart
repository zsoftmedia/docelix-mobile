
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoicesDetailsController extends GetxController {
  final DioClient dioClient = DioClient();

  final RxBool isLoading = false.obs;

  /// Selected invoice
  final Rxn<InvoicesModel> invoice = Rxn<InvoicesModel>();

  @override
  void onInit() {
    super.onInit();

    // Receive invoice from previous screen
    if (Get.arguments is InvoicesModel) {
      invoice.value = Get.arguments as InvoicesModel;
    }
  }

  // ============================================================
  // SET INVOICE
  // ============================================================

  void setInvoice(InvoicesModel value) {
    invoice.value = value;
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshInvoice() async {
    // Later you can call invoice details API here
  }

  // ============================================================
  // DELETE INVOICE
  // ============================================================

  Future<void> deleteInvoice() async {
    if (invoice.value == null) return;

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

      // TODO:
      // Add delete API in DioClient.
      //
      // await dioClient.deleteInvoice(
      //   invoiceId: invoice.value!.id,
      //   companyId: int.parse(companyId.toString()),
      //   accessToken: accessToken,
      // );

      Get.back();

      Get.snackbar(
        'Success',
        'Invoice deleted successfully.',
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
  // DELETE CONFIRMATION
  // ============================================================

  void showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text(
          'Are you sure you want to delete this invoice?',
        ),
        actions: [

          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteInvoice();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}