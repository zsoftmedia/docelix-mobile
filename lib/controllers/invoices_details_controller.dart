import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_button.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/components/app_textfield.dart';
import 'package:docelix_mobileapp/controllers/invoices_controller.dart';
import 'package:docelix_mobileapp/models/client_model.dart';
import 'package:docelix_mobileapp/models/invoice_item_model.dart';
import 'package:docelix_mobileapp/models/invoices_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/colors_list.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoicesDetailsController extends GetxController {
  final DioClient dioClient = DioClient();

  final RxBool isLoading = false.obs;
  final RxBool isSendingEmail = false.obs;

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

      final int clientId = invoice.value!.clientId;
      final int companyIdInt = int.parse(companyId.toString());

      print('Loading client ID: $clientId');
      print('Company ID: $companyIdInt');

      final response = await dioClient.getClients(
        companyId: companyIdInt,
        accessToken: accessToken,
      );

      print('Clients Response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        final List<ClientModel> clients = data
            .map(
              (json) => ClientModel.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();

        final ClientModel? selectedClient = clients.cast<ClientModel?>().firstWhere(
              (item) => item!.id == clientId,
          orElse: () => null,
        );

        client.value = selectedClient;

        if (selectedClient != null) {
          print('Client found: ${selectedClient.name}');
        } else {
          print('Client not found for ID: $clientId');
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

      final int invoiceId = invoice.value!.id;

      print('Loading items for Invoice ID: $invoiceId');

      final response = await dioClient.getInvoiceItems(
        invoiceId: invoiceId,
        accessToken: accessToken,
      );

      print('Invoice Items Response: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        invoiceItems.assignAll(
          data.map(
            (json) => InvoiceItemModel.fromJson(
              json as Map<String, dynamic>,
            ),
          ),
        );

        print('Invoice Items Loaded: ${invoiceItems.length}');
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

      final int companyIdInt = int.parse(companyId.toString());
      final int invoiceId = invoice.value!.id;

      print('Deleting Invoice ID: $invoiceId');
      print('Company ID: $companyIdInt');

      try {
        final ledgerResponse = await dioClient.deleteInvoiceJournalEntries(
          companyId: companyIdInt,
          sourceId: invoiceId,
          sourceType: 'invoice_issue',
          accessToken: accessToken,
        );
        print('Ledger Delete Response: ${ledgerResponse.data}');
      } catch (e) {
        debugPrint('Ledger journal entries delete warning: $e');
      }

      final invoiceResponse = await dioClient.deleteInvoice(
        invoiceId: invoiceId,
        accessToken: accessToken,
      );

      print('Invoice Delete Response: ${invoiceResponse.data}');

      if (invoiceResponse.statusCode == 200 ||
          invoiceResponse.statusCode == 201 ||
          invoiceResponse.statusCode == 204) {

        while (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
          Get.back();
        }

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Invoice deleted successfully.',
        );

        if (Get.isRegistered<InvoicesController>()) {
          Get.find<InvoicesController>().refreshInvoices();
        }
      } else {
        AppSnackbar.error(
          title: 'Delete Failed',
          message: 'Unable to delete invoice.',
        );
      }
    } on DioException catch (e) {
      print('Delete Invoice Dio Error: ${e.message}');
      print('Response: ${e.response?.data}');

      String message = 'Unable to delete invoice.';

      if (e.response?.data is Map) {
        message = e.response?.data['message'] ??
            e.response?.data['error'] ??
            message;
      }

      AppSnackbar.error(
        title: 'Error',
        message: message,
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

  // ============================================================
  // SHOW SEND INVOICE EMAIL DIALOG
  // ============================================================

  void showSendInvoiceDialog() {
    final selectedInvoice = invoice.value;

    if (selectedInvoice == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'No invoice selected.',
      );
      return;
    }

    final toEmailController = TextEditingController(
      text: client.value?.email?.trim() ?? '',
    );

    final subjectController = TextEditingController(
      text: 'Invoice #${selectedInvoice.invoiceNumber}',
    );

    final companyName = SessionManager.accessCompanyname?.toString() ?? '';

    final bodyController = TextEditingController(
      text: 'Hello,\n\n'
          'Please find your invoice #${selectedInvoice.invoiceNumber}.\n\n'
          'Best regards,\n'
          '$companyName',
    );

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    color: colorsList.iconColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Send Invoice Email',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorsList.textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: colorsList.iconColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'To Email *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorsList.textColor,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: toEmailController,
                hintText: 'client@example.com',
                prefixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              const Text(
                'Subject *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorsList.textColor,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: subjectController,
                hintText: 'Email subject',
                prefixIcon: Icons.subject_rounded,
              ),

              const SizedBox(height: 14),

              const Text(
                'Message *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorsList.textColor,
                ),
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: bodyController,
                hintText: 'Email message body...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 4,
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(
                          color: colorsList.borderColor,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => AppButton(
                        text: isSendingEmail.value
                            ? 'Sending...'
                            : 'Send Email',
                        icon: Icons.send_rounded,
                        height: 48,
                        backgroundColor: colorsList.colorButton,
                        foregroundColor: Colors.white,
                        borderRadius: 10,
                        isLoading: isSendingEmail.value,
                        onPressed: () {
                          sendCustomInvoiceEmail(
                            invoiceId: selectedInvoice.id,
                            to: toEmailController.text.trim(),
                            subject: subjectController.text.trim(),
                            body: bodyController.text.trim(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ============================================================
  // SEND INVOICE EMAIL API
  // ============================================================

  Future<void> sendCustomInvoiceEmail({
    required int invoiceId,
    required String to,
    required String subject,
    required String body,
  }) async {
    if (to.isEmpty || subject.isEmpty || body.isEmpty) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Missing email, subject OR message.',
      );
      return;
    }

    if (!GetUtils.isEmail(to)) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please enter a valid email address.',
      );
      return;
    }

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

    try {
      isSendingEmail.value = true;

      final int companyIdInt = int.parse(companyId.toString());

      print('Sending invoice email to: $to');

      final response = await dioClient.sendInvoice(
        invoiceId: invoiceId,
        companyId: companyIdInt,
        to: to,
        subject: subject,
        text: body,
        accessToken: accessToken,
      );

      print('Send Invoice Response Status: ${response.statusCode}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202 ||
          response.statusCode == 204) {
        Get.back();

        AppSnackbar.success(
          title: 'Success',
          message: 'Invoice email sent successfully.',
        );
      } else {
        AppSnackbar.error(
          title: 'Send Failed',
          message: 'Unable to send invoice email.',
        );
      }
    } on DioException catch (e) {
      print('Send Invoice Dio Error: ${e.message}');
      print('Response: ${e.response?.data}');

      String message = 'Unable to send invoice email.';

      if (e.response?.data is Map) {
        message = e.response?.data['message']?.toString() ??
            e.response?.data['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Send Failed',
        message: message,
      );
    } catch (e) {
      print('Send Invoice Exception: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while sending invoice email.',
      );
    } finally {
      isSendingEmail.value = false;
    }
  }

  // ============================================================
  // DOWNLOAD INVOICE PDF
  // ============================================================

  Future<void> downloadInvoicePdf() async {
    final selectedInvoice = invoice.value;

    if (selectedInvoice == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'No invoice selected.',
      );
      return;
    }

    final accessToken = SessionManager.accessToken;

    if (accessToken == null || accessToken.isEmpty) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Access token is not available.',
      );
      return;
    }

    try {
      isLoading.value = true;

      final invoiceId = selectedInvoice.id;

      print('Downloading PDF for invoice ID: $invoiceId');

      Uint8List? pdfBytes;

      try {
        final response = await dioClient.downloadInvoicePdf(
          invoiceId: invoiceId,
          accessToken: accessToken,
        );

        if (response.statusCode == 200 &&
            response.data != null &&
            response.data!.isNotEmpty) {
          pdfBytes = Uint8List.fromList(response.data!);
        }
      } catch (e) {
        debugPrint(
            'Server endpoint /invoices/$invoiceId/pdf unavailable ($e). Generating PDF locally...');
      }

      pdfBytes ??= await _generateInvoicePdfLocally(selectedInvoice);

      if (pdfBytes.isNotEmpty) {
        _showDownloadSuccessDialog(pdfBytes, selectedInvoice);
      } else {
        AppSnackbar.error(
          title: 'Download Failed',
          message: 'Unable to generate or download invoice PDF.',
        );
      }
    } catch (e) {
      print('Unexpected PDF Download Error: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while downloading the PDF.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOCAL PDF GENERATION FALLBACK
  // ============================================================

  Future<Uint8List> _generateInvoicePdfLocally(InvoicesModel inv) async {
    final pdf = pw.Document();

    final clientName = client.value?.name ?? 'Client';
    final itemsList = invoiceItems;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '#${inv.invoiceNumber}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${inv.issueDate}'),
                      pw.Text('Status: ${inv.status.toUpperCase()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 12),

              pw.Text(
                'Billed To:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                clientName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (client.value?.email != null) pw.Text(client.value!.email!),
              if (client.value?.phone != null) pw.Text(client.value!.phone!),

              pw.SizedBox(height: 24),

              pw.TableHelper.fromTextArray(
                headers: ['Description', 'Qty', 'Unit Price', 'Total'],
                data: itemsList.isNotEmpty
                    ? itemsList.map((item) {
                        return [
                          item.itemDesc,
                          '${item.quantity}',
                          '€${item.unitPrice.toStringAsFixed(2)}',
                          '€${item.grossAmount.toStringAsFixed(2)}',
                        ];
                      }).toList()
                    : [
                        [
                          'Invoice Total',
                          '1',
                          '€${inv.paidAmount.toStringAsFixed(2)}',
                          '€${inv.paidAmount.toStringAsFixed(2)}'
                        ]
                      ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue900,
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),

              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Amount:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                              '${inv.currencyCode.isEmpty ? '€' : inv.currencyCode} ${inv.paidAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // SUCCESS DIALOG
  // ============================================================

  void _showDownloadSuccessDialog(Uint8List pdfBytes, InvoicesModel inv) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Invoice Downloaded Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'invoice_${inv.invoiceNumber}.pdf is ready to view or open.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF667085),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(
                          color: Color(0xFFD1D5DB),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        Printing.sharePdf(
                          bytes: pdfBytes,
                          filename: 'invoice_${inv.invoiceNumber}.pdf',
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: const Text('Open PDF'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        backgroundColor: const Color(0xFF063C70),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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