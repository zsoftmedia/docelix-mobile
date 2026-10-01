
import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/config/api_constants.dart';
import 'package:docelix_mobileapp/models/client_model.dart';
import 'package:docelix_mobileapp/models/invoice_item_model.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  Future<void> downloadInvoice() async {
    if (invoice.value == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Invoice information is not available.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final invoiceData = invoice.value!;
      final clientData = client.value;
      final items = invoiceItems.toList();

      // Get PDF template settings
      final templateSettings =
      await getPdfTemplateSettings();

      if (templateSettings == null) {
        AppSnackbar.error(
          title: 'Error',
          message:
          'PDF template settings are not available.',
        );
        return;
      }

      // Generate PDF
      final pdfBytes = await generateInvoicePdf(
        invoice: invoiceData,
        client: clientData,
        items: items,
        settings: templateSettings,
      );

      // Save PDF
      await savePdf(
        pdfBytes,
        invoiceData,
      );

      AppSnackbar.success(
        title: 'Success',
        message: 'Invoice downloaded successfully.',
      );
    } catch (e) {
      print('Download Invoice Error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to download invoice.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> getPdfTemplateSettings() async {
    try {
      final companyId = SessionManager.accessCompanyid;

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );
        return null;
      }

      final int companyIdInt = int.parse(
        companyId.toString(),
      );

      print(
        'Getting PDF template settings for company: $companyIdInt',
      );

      final response = await dioClient.getPdfTemplateSettings(
        companyId: companyIdInt,
        docType: 'invoice',
        templateId: 'default',
      );

      print(
        'PDF Template Settings Response: ${response.data}',
      );

      if (response.statusCode == 200 &&
          response.data is List &&
          response.data.isNotEmpty) {

        final firstItem = response.data.first;

        if (firstItem is Map &&
            firstItem['settings'] is Map) {

          return Map<String, dynamic>.from(
            firstItem['settings'],
          );
        }
      }

      print('PDF template settings not found.');

      return null;
    } on DioException catch (e) {
      print(
        'Get PDF Template Settings Dio Error: ${e.message}',
      );

      print(
        'Response: ${e.response?.data}',
      );

      return null;
    } catch (e) {
      print(
        'Get PDF Template Settings Error: $e',
      );

      return null;
    }
  }

  Future<Uint8List> generateInvoicePdf({
    required InvoicesModel invoice,
    required ClientModel? client,
    required List<InvoiceItemModel> items,
    required Map<String, dynamic> settings,
  }) async
  {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // ------------------------------------------------------
            // HEADER
            // ------------------------------------------------------
            pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.Text(
                  '#${invoice.id}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 25),

            // ------------------------------------------------------
            // CLIENT
            // ------------------------------------------------------
            pw.Text(
              'Bill To',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 5),

            pw.Text(
              client?.name ?? 'N/A',
              style: const pw.TextStyle(
                fontSize: 11,
              ),
            ),

            if (client?.addressLine1 != null)
              pw.Text(
                client!.addressLine1!,
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),

            if (client?.city != null)
              pw.Text(
                client!.city!,
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),

            pw.SizedBox(height: 25),

            // ------------------------------------------------------
            // ITEMS
            // ------------------------------------------------------
            pw.TableHelper.fromTextArray(
              headers: [
                'Description',
                'Qty',
                'Unit',
                'VAT',
                'Total',
              ],
              data: items.map((item) {
                return [
                  item.itemDesc ?? '',
                  item.quantity?.toString() ?? '0',
                  item.unitPrice ?? '',
                  item.vatRate?.toString() ?? '0',
                  item.grossAmount?.toString() ?? '0',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 9,
              ),
              cellPadding: const pw.EdgeInsets.all(6),
            ),

            pw.SizedBox(height: 25),

            // ------------------------------------------------------
            // FOOTER
            // ------------------------------------------------------
            pw.Divider(),

            pw.SizedBox(height: 8),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Thank you for your business.',
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> savePdf(
      Uint8List pdfBytes,
      InvoicesModel invoice,
      ) async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'invoice_${invoice.id}.pdf',
    );
  }

}