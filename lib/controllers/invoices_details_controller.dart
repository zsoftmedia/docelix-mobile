
import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/client_model.dart';
import 'package:docelix_mobileapp/models/invoice_item_model.dart';
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

  /// Selected client
  final Rxn<ClientModel> client = Rxn<ClientModel>();

  /// Invoice item list
  final RxList<InvoiceItemModel> invoiceItems =
      <InvoiceItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    // ============================================================
    // RECEIVE INVOICE FROM PREVIOUS SCREEN
    // ============================================================

    if (Get.arguments is InvoicesModel) {
      invoice.value = Get.arguments as InvoicesModel;

      // Load invoice items
      getInvoiceItems();

      // Load client information
      getClient();
    }
  }

  // ============================================================
  // SET INVOICE
  // ============================================================

  void setInvoice(InvoicesModel value) {
    invoice.value = value;

    // Load items for selected invoice
    getInvoiceItems();
  }

  // ============================================================
// GET CLIENT
// ============================================================

  Future<void> getClient() async {
    if (invoice.value == null) {
      return;
    }

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
          message:  'Access token is not available.',
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

      // ----------------------------------------------------------
      // INVOICE CLIENT ID
      // ----------------------------------------------------------

      final int clientId = invoice.value!.clientId;

      final int companyIdInt =
      int.parse(companyId.toString());

      print('Loading client ID: $clientId');
      print('Company ID: $companyIdInt');

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response = await dioClient.getClients(
        companyId: companyIdInt,
        accessToken: accessToken,
      );

      print('Clients Response: ${response.data}');

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final List<ClientModel> clients = data
            .map(
              (json) => ClientModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
            .toList();

        // --------------------------------------------------------
        // FIND CLIENT FOR CURRENT INVOICE
        // --------------------------------------------------------

        final ClientModel? selectedClient = clients.cast<ClientModel?>().firstWhere(
              (item) => item!.id == clientId,
          orElse: () => null,
        );

        client.value = selectedClient;

        if (selectedClient != null) {
          print(
            'Client found: ${selectedClient.name}',
          );
        } else {
          print(
            'Client not found for ID: $clientId',
          );
        }
      } else {
        client.value = null;

        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to load client information.',
        );

      }
    } catch (e) {
      client.value = null;

      print('Get Client Error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to load client information.',
      );

    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GET INVOICE ITEMS
  // ============================================================

  Future<void> getInvoiceItems() async {
    if (invoice.value == null) {
      return;
    }

    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {

        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );

        return;
      }

      // ----------------------------------------------------------
      // INVOICE ID
      // ----------------------------------------------------------

      final int invoiceId = invoice.value!.id;

      print('Loading items for Invoice ID: $invoiceId');

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response = await dioClient.getInvoiceItems(
        invoiceId: invoiceId,
        accessToken: accessToken,
      );

      print('Invoice Items Response: ${response.data}');

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        invoiceItems.assignAll(
          data.map(
                (json) => InvoiceItemModel.fromJson(
              json as Map<String, dynamic>,
            ),
          ),
        );

        print(
          'Invoice Items Loaded: ${invoiceItems.length}',
        );
      } else {
        invoiceItems.clear();

        AppSnackbar.error(
          title: 'Error',
          message: 'Unable to load invoice items.',
        );

      }
    } catch (e) {
      invoiceItems.clear();

      print('Get Invoice Items Error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to load invoice items.',
      );

    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshInvoice() async {
    await getInvoiceItems();
  }

  // ==============================================================
// DELETE INVOICE
// ==============================================================

  Future<void> deleteInvoice() async {
    if (invoice.value == null) return;

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

      final int companyIdInt = int.parse(companyId.toString());

      // ----------------------------------------------------------
      // INVOICE ID
      // ----------------------------------------------------------

      final int invoiceId = invoice.value!.id;

      print('Deleting Invoice ID: $invoiceId');
      print('Company ID: $companyIdInt');

      // ==========================================================
      // STEP 1: DELETE LEDGER JOURNAL ENTRIES
      // ==========================================================

      print('Deleting invoice journal entries...');

      final ledgerResponse =
      await dioClient.deleteInvoiceJournalEntries(
        companyId: companyIdInt,
        sourceId: invoiceId,
        sourceType: 'invoice_issue',
        accessToken: accessToken,
      );

      print(
        'Ledger Delete Response: ${ledgerResponse.data}',
      );

      if (ledgerResponse.statusCode != 200) {

        AppSnackbar.error(
          title: 'Delete Failed',
          message: 'Unable to delete invoice ledger entries.',
        );

        return;
      }

      // ==========================================================
      // STEP 2: DELETE INVOICE
      // ==========================================================

      print('Deleting invoice...');

      final invoiceResponse =
      await dioClient.deleteIncomingInvoice(
        invoiceId: invoiceId,
        accessToken: accessToken,
      );

      print(
        'Invoice Delete Response: ${invoiceResponse.data}',
      );

      if (invoiceResponse.statusCode != 200) {

        AppSnackbar.error(
          title: 'Delete Failed',
          message: 'Unable to delete invoice.',
        );

        return;
      }

      // ==========================================================
      // SUCCESS
      // ==========================================================

      AppSnackbar.success(
        title: 'Success',
        message: 'Invoice deleted successfully.',
      );

      // ----------------------------------------------------------
      // Return to Invoice List
      // ----------------------------------------------------------

      isLoading.value = false;

      Get.back(result: true);
      return;

    } on DioException catch (e) {
      print('Delete Invoice Dio Error: ${e.message}');
      print('Response: ${e.response?.data}');

      String message = 'Unable to delete invoice.';

      if (e.response?.data is Map) {
        message =
            e.response?.data['message'] ??
                e.response?.data['error'] ??
                message;
      }

      AppSnackbar.error(
        title: 'Error',
        message: '$message',
      );


    } catch (e) {
      print('Delete Invoice Error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while deleting the invoice.',
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