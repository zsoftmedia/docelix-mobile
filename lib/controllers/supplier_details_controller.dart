import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/purchase_invoices_model.dart';
import 'package:docelix_mobileapp/models/supplier_ledger_model.dart';
import 'package:docelix_mobileapp/models/supplier_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SupplierDetailsController extends GetxController {
  final DioClient dioClient = DioClient();

  final Rxn<SupplierModel> supplier = Rxn<SupplierModel>();
  final RxInt selectedTab = 0.obs;

  final RxList<PurchaseInvoicesModel> purchases = <PurchaseInvoicesModel>[].obs;
  final RxBool isLoadingPurchases = false.obs;

  final Rxn<SupplierLedgerModel> supplierLedger = Rxn<SupplierLedgerModel>();
  final RxBool isLoadingLedger = false.obs;

  final List<String> tabs = const [
    'Overview',
    'Purchases',
    /*'Payments',*/
    'Supplier Ledger',
  ];

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is SupplierModel) {
      supplier.value = Get.arguments as SupplierModel;
      fetchSupplierPurchases();
      fetchSupplierLedger();
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    if (index == 1 && purchases.isEmpty && !isLoadingPurchases.value) {
      fetchSupplierPurchases();
    } else if (index == 3 && supplierLedger.value == null && !isLoadingLedger.value) {
      fetchSupplierLedger();
    }
  }

  Future<void> openEditSupplier() async {
    final currentSupplier = supplier.value;
    if (currentSupplier == null) return;

    final result = await Get.toNamed('/EditSupplierScreen', arguments: currentSupplier);
    if (result != null && result is SupplierModel) {
      supplier.value = result;
    } else if (result == true) {
      fetchSupplierPurchases();
      fetchSupplierLedger();
    }
  }

  Future<void> exportStatement() async {
    final currentSupplier = supplier.value;
    if (currentSupplier == null) return;

    try {
      final pdf = pw.Document();
      final String suppName = currentSupplier.name;

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
                        pw.Text('SUPPLIER STATEMENT',
                            style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900)),
                        pw.SizedBox(height: 4),
                        pw.Text(suppName,
                            style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Date: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}'),
                        pw.Text('Purchases: ${formatCurrency(currentSupplier.purchasesTotal, null)}'),
                        pw.Text('Paid: ${formatCurrency(currentSupplier.paidTotal, null)}'),
                        pw.Text('Outstanding: ${formatCurrency(currentSupplier.outstanding, null)}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Text('Supplier Purchases Summary:',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.TableHelper.fromTextArray(
                  headers: ['Invoice #', 'Date', 'Total', 'Status'],
                  data: purchases.isNotEmpty
                      ? purchases.map((p) {
                          return [
                            p.invoiceNumber ?? '—',
                            p.invoiceDate ?? '—',
                            formatCurrency(p.totalAmount, p.currency),
                            p.status.toUpperCase(),
                          ];
                        }).toList()
                      : [
                          ['No purchases recorded', '—', '—', '—']
                        ],
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white),
                  headerDecoration:
                      const pw.BoxDecoration(color: PdfColors.blue900),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Supplier_Statement_${suppName.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      debugPrint('Export Statement Error: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to export statement.',
      );
    }
  }

  Future<void> fetchSupplierPurchases() async {
    final currentSupplier = supplier.value;
    if (currentSupplier == null) return;

    try {
      isLoadingPurchases.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty || companyId == null) {
        return;
      }

      final companyIdInt = int.parse(companyId.toString());

      debugPrint(
          'Fetching purchases for supplier ID ${currentSupplier.id}, company: $companyIdInt');

      final response = await dioClient.getSupplierPurchases(
        companyId: companyIdInt,
        supplierId: currentSupplier.id,
        accessToken: accessToken,
      );

      debugPrint('Supplier Purchases Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> items = [];

        if (response.data is Map) {
          final Map<String, dynamic> responseData =
              Map<String, dynamic>.from(response.data as Map);
          items = responseData['data'] as List<dynamic>? ?? [];
        } else if (response.data is List) {
          items = response.data as List<dynamic>;
        }

        final List<PurchaseInvoicesModel> loadedPurchases = items
            .map(
              (item) => PurchaseInvoicesModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();

        purchases.assignAll(loadedPurchases);

        debugPrint('Supplier Purchases Loaded: ${purchases.length}');
      } else {
        purchases.clear();
      }
    } catch (e) {
      debugPrint('Fetch Supplier Purchases Error: $e');
      purchases.clear();
    } finally {
      isLoadingPurchases.value = false;
    }
  }

  Future<void> fetchSupplierLedger() async {
    final currentSupplier = supplier.value;
    if (currentSupplier == null) return;

    try {
      isLoadingLedger.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty || companyId == null) {
        return;
      }

      final companyIdInt = int.parse(companyId.toString());

      debugPrint(
          'Fetching supplier ledger for ID ${currentSupplier.id}, company: $companyIdInt');

      final response = await dioClient.getSupplierLedger(
        companyId: companyIdInt,
        supplierId: currentSupplier.id,
        accessToken: accessToken,
      );

      debugPrint('Supplier Ledger Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(response.data as Map);

        supplierLedger.value = SupplierLedgerModel.fromJson(data);

        debugPrint(
            'Supplier Ledger Entries Loaded: ${supplierLedger.value?.entries.length}');
      } else {
        supplierLedger.value = null;
      }
    } catch (e) {
      debugPrint('Fetch Supplier Ledger Error: $e');
      supplierLedger.value = null;
    } finally {
      isLoadingLedger.value = false;
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