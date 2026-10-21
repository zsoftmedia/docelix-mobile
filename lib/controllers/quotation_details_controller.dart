import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/controllers/quotation_controller.dart';
import 'package:docelix_mobileapp/core/responsive/responsive.dart';
import 'package:docelix_mobileapp/models/quotation_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class QuotationDetailsController extends GetxController {
  final DioClient dioClient = DioClient();

  final Rxn<QuotationModel> quotation = Rxn<QuotationModel>();
  final RxList<QuotationItemModel> offerItems = <QuotationItemModel>[].obs;
  final RxBool isLoadingItems = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isDownloading = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is QuotationModel) {
      quotation.value = Get.arguments as QuotationModel;
      if (quotation.value?.items.isNotEmpty == true) {
        offerItems.assignAll(quotation.value!.items);
      }
      getOfferItems();
    }
  }

  double get totalAmount {
    if (offerItems.isNotEmpty) {
      return offerItems.fold(0.0, (sum, item) => sum + item.total);
    }
    return quotation.value?.totalAmount ?? 0.0;
  }

  Future<void> getOfferItems() async {
    final currentOffer = quotation.value;
    if (currentOffer == null || currentOffer.id <= 0) return;

    try {
      isLoadingItems.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty || companyId == null) {
        return;
      }

      final companyIdInt = int.parse(companyId.toString());

      debugPrint('Fetching items for offer ID: ${currentOffer.id}');

      final response = await dioClient.getOfferItems(
        offerId: currentOffer.id,
        companyId: companyIdInt,
        accessToken: accessToken,
      );

      debugPrint('Get Offer Items Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> items = [];

        if (response.data is List) {
          items = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final map = Map<String, dynamic>.from(response.data as Map);
          items = map['data'] as List<dynamic>? ?? map['items'] as List<dynamic>? ?? [];
        }

        final List<QuotationItemModel> loaded = items
            .map(
              (item) => QuotationItemModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        if (loaded.isNotEmpty) {
          offerItems.assignAll(loaded);
        }

        debugPrint('Offer Items Loaded: ${offerItems.length}');
      }
    } on DioException catch (e) {
      debugPrint('Get Offer Items Dio Error: ${e.message}');
    } catch (e) {
      debugPrint('Get Offer Items Exception: $e');
    } finally {
      isLoadingItems.value = false;
    }
  }

  Future<void> downloadQuotationDocument() async {
    final currentOffer = quotation.value;
    if (currentOffer == null) {
      AppSnackbar.error(
        title: 'Error',
        message: 'No quotation selected.',
      );
      return;
    }

    try {
      isDownloading.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty || companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Authentication token or company ID missing.',
        );
        return;
      }

      final companyIdInt = int.parse(companyId.toString());

      debugPrint('Fetching PDF template settings for company $companyIdInt, docType: offer');

      try {
        final response = await dioClient.getPdfTemplateSettings(
          companyId: companyIdInt,
          docType: 'offer',
          accessToken: accessToken,
        );

        debugPrint('PDF template response status: ${response.statusCode}');
      } catch (e) {
        debugPrint('PDF template settings fetch warning ($e). Generating PDF...');
      }

      final Uint8List pdfBytes = await _generateQuotationPdfLocally(currentOffer, offerItems);

      if (pdfBytes.isNotEmpty) {
        _showDownloadSuccessDialog(pdfBytes, currentOffer.offerNumber);
      } else {
        AppSnackbar.error(
          title: 'Download Failed',
          message: 'Unable to generate quotation PDF.',
        );
      }
    } catch (e) {
      debugPrint('Download Quotation Document Exception: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while downloading quotation document.',
      );
    } finally {
      isDownloading.value = false;
    }
  }

  void _showDownloadSuccessDialog(Uint8List pdfBytes, String offerNumber) {
    Get.dialog(
      ResponsiveDialogBody(
        child: Dialog(
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
                  'Quotation PDF Ready!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quotation_$offerNumber.pdf is ready to view, print or share.',
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
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.back();
                          Printing.sharePdf(
                            bytes: pdfBytes,
                            filename: 'Quotation_$offerNumber.pdf',
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
      ),
    );
  }

  Future<Uint8List> _generateQuotationPdfLocally(
    QuotationModel offer,
    List<QuotationItemModel> items,
  ) async {
    final pdf = pw.Document();

    final String clientNameStr = offer.clientName ?? 'Customer';
    final String clientAddressStr = offer.clientAddress ?? '—';
    final String offerNumStr = offer.offerNumber.isNotEmpty ? offer.offerNumber : 'QUOTATION';

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
                        'QUOTATION',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '#$offerNumStr',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${offer.issueDate}'),
                      pw.Text('Status: ${offer.status.toUpperCase()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Divider(),
              pw.SizedBox(height: 12),

              pw.Text(
                'Customer Information:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                clientNameStr,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (offer.clientEmail != null) pw.Text(offer.clientEmail!),
              if (clientAddressStr != '—') pw.Text(clientAddressStr),

              pw.SizedBox(height: 24),

              pw.TableHelper.fromTextArray(
                headers: ['Description', 'Qty', 'Unit Price', 'VAT %', 'Total'],
                data: items.isNotEmpty
                    ? items.map((item) {
                        return [
                          item.description,
                          '${item.quantity}',
                          formatCurrency(item.unitPrice),
                          '${item.vatRate}%',
                          formatCurrency(item.total),
                        ];
                      }).toList()
                    : [
                        [
                          'Quotation Total',
                          '1',
                          formatCurrency(totalAmount),
                          '0%',
                          formatCurrency(totalAmount),
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
                  4: pw.Alignment.centerRight,
                },
              ),

              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Grand Total:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(
                              formatCurrency(totalAmount),
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

  Future<void> deleteQuotation() async {
    final currentOffer = quotation.value;
    if (currentOffer == null || currentOffer.id <= 0) return;

    final bool? confirmed = await Get.dialog<bool>(
      ResponsiveDialogBody(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Quotation',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A2342),
            ),
          ),
          content: Text(
            'Are you sure you want to delete quotation #${currentOffer.offerNumber}? This action cannot be undone.',
            style: const TextStyle(
              color: Color(0xFF60728D),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF60728D))),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    await _performDeleteQuotation(currentOffer.id);
  }

  Future<void> _performDeleteQuotation(int offerId) async {
    try {
      isDeleting.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Authentication token is missing.',
        );
        return;
      }

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is missing.',
        );
        return;
      }

      final int companyIdInt = int.parse(companyId.toString());

      debugPrint('Deleting offer ID $offerId for Company ID $companyIdInt');

      final response = await dioClient.deleteOffer(
        offerId: offerId,
        companyId: companyIdInt,
        accessToken: accessToken,
      );

      debugPrint('Delete Offer Status: ${response.statusCode}');
      debugPrint('Delete Offer Response: ${response.data}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204 ||
          (response.data is Map && response.data['success'] == true)) {

        while (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
          Get.back();
        }

        Get.back(result: true);

        AppSnackbar.success(
          title: 'Success',
          message: 'Quotation deleted successfully.',
        );

        if (Get.isRegistered<QuotationController>()) {
          Get.find<QuotationController>().refreshQuotations();
        }
      } else {
        AppSnackbar.error(
          title: 'Delete Failed',
          message: 'Unable to delete quotation.',
        );
      }
    } on DioException catch (e) {
      debugPrint('Delete Offer Dio Error: ${e.message}');
      String message = 'Unable to delete quotation.';

      if (e.response?.data is Map) {
        message = e.response?.data['message']?.toString() ??
            e.response?.data['error']?.toString() ??
            message;
      }

      AppSnackbar.error(
        title: 'Delete Failed',
        message: message,
      );
    } catch (e) {
      debugPrint('Delete Offer Exception: $e');

      AppSnackbar.error(
        title: 'Error',
        message: 'Something went wrong while deleting quotation.',
      );
    } finally {
      isDeleting.value = false;
    }
  }

  String getCurrencySymbol(String? code) {
    final String rawCode = (code != null && code.trim().isNotEmpty)
        ? code.trim().toUpperCase()
        : (SessionManager.accessCorrencycode?.trim().toUpperCase() ?? 'EUR');

    switch (rawCode) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'CAD':
        return 'CA\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'JPY':
        return '¥';
      case 'PKR':
        return 'Rs.';
      default:
        return rawCode;
    }
  }

  String formatCurrency(num? amount, [String? currencyCode]) {
    final double value = (amount ?? 0).toDouble();
    final String symbol = getCurrencySymbol(currencyCode);

    final parts = value.toStringAsFixed(2).split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts[1];

    final String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '$symbol $formattedInteger.$decimalPart';
  }
}