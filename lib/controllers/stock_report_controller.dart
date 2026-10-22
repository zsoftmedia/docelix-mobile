import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/stock_report_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StockReportController extends GetxController {
  final DioClient dioClient = DioClient();

  final Rx<DateTime> fromDate = DateTime.now().obs;
  final Rx<DateTime> toDate = DateTime.now().obs;

  final RxString stockFilter = 'all'.obs; // 'all', 'low', 'out'
  final RxString selectedPreset = 'this_month'.obs; // 'this_month', 'last_month', 'this_year', 'custom'

  final RxList<StockReportRowModel> rows = <StockReportRowModel>[].obs;
  final RxList<StockReportRowModel> filteredRows = <StockReportRowModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectPresetPeriod('this_month', fetch: false);
    fetchStockReport();
  }

  // ============================================================
  // PRESET DATE PERIODS
  // ============================================================

  void selectPresetPeriod(String presetKey, {bool fetch = true}) {
    selectedPreset.value = presetKey;
    final now = DateTime.now();

    switch (presetKey) {
      case 'this_month':
        fromDate.value = DateTime(now.year, now.month, 1);
        toDate.value = now;
        break;

      case 'last_month':
        final lastMonthDate = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
        fromDate.value = lastMonthDate;
        toDate.value = lastDayOfLastMonth;
        break;

      case 'this_year':
        fromDate.value = DateTime(now.year, 1, 1);
        toDate.value = now;
        break;

      default:
        break;
    }

    if (fetch) {
      fetchStockReport();
    }
  }

  // ============================================================
  // DATE PICKERS & VALIDATION
  // ============================================================

  Future<void> pickFromDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value.isAfter(today) ? today : fromDate.value,
      firstDate: DateTime(2000),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF063C70),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0A2342),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final cleanPicked = DateTime(picked.year, picked.month, picked.day);

      if (cleanPicked.isAfter(today)) {
        AppSnackbar.error(
          title: 'Invalid Date',
          message: 'From date cannot exceed current date.',
        );
        return;
      }

      selectedPreset.value = 'custom';
      fromDate.value = picked;

      // VALIDATION: If toDate is before new fromDate, align toDate with fromDate
      if (toDate.value.isBefore(picked)) {
        toDate.value = picked;
      }

      fetchStockReport();
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate.value.isBefore(fromDate.value) ? fromDate.value : toDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF063C70),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0A2342),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final cleanPicked = DateTime(picked.year, picked.month, picked.day);
      final cleanFrom = DateTime(fromDate.value.year, fromDate.value.month, fromDate.value.day);

      // VALIDATION: To date cannot be before From date
      if (cleanPicked.isBefore(cleanFrom)) {
        AppSnackbar.error(
          title: 'Invalid Date Range',
          message: 'To date (${_formatDateUI(cleanPicked)}) cannot be before From date (${_formatDateUI(cleanFrom)}).',
        );
        return;
      }

      selectedPreset.value = 'custom';
      toDate.value = picked;
      fetchStockReport();
    }
  }

  // ============================================================
  // FETCH STOCK REPORT API
  // ============================================================

  Future<void> fetchStockReport() async {
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
      final String fromStr = _formatDateApi(fromDate.value);
      final String toStr = _formatDateApi(toDate.value);

      debugPrint('Fetching Stock Report from $fromStr to $toStr for company $companyIdInt');

      final response = await dioClient.getStockReport(
        companyId: companyIdInt,
        fromDate: fromStr,
        toDate: toStr,
        accessToken: accessToken,
      );

      debugPrint('Stock Report Status Code: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> rowsList = [];

        if (response.data is Map) {
          final map = Map<String, dynamic>.from(response.data as Map);
          rowsList = map['rows'] as List<dynamic>? ?? [];
        } else if (response.data is List) {
          rowsList = response.data as List<dynamic>;
        }

        final List<StockReportRowModel> loadedRows = rowsList
            .map((item) => StockReportRowModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();

        rows.assignAll(loadedRows);
        applyFilters();

        debugPrint('Stock Report Rows Loaded: ${rows.length}');
      } else {
        errorMessage.value = 'Unable to load stock report.';
        AppSnackbar.error(title: 'Error', message: errorMessage.value);
      }
    } on DioException catch (e) {
      debugPrint('Stock Report Dio Error: ${e.message}');
      errorMessage.value = 'Unable to load stock report.';
      AppSnackbar.error(title: 'Error', message: errorMessage.value);
    } catch (e) {
      debugPrint('Stock Report Exception: $e');
      errorMessage.value = 'Something went wrong while loading stock report.';
      AppSnackbar.error(title: 'Error', message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // SEARCH & FILTER LOGIC
  // ============================================================

  void setFilter(String filter) {
    stockFilter.value = filter;
    applyFilters();
  }

  void openSearch() {
    isSearching.value = true;
  }

  void closeSearch() {
    isSearching.value = false;
    searchQuery.value = '';
    applyFilters();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = stockFilter.value;

    filteredRows.assignAll(
      rows.where((row) {
        // Stock status filter
        if (filter == 'low' && !row.isLowStock) return false;
        if (filter == 'out' && !row.isOutOfStock) return false;

        // Search query filter
        if (query.isNotEmpty) {
          final name = row.articleName.toLowerCase();
          final code = row.articleNumber.toLowerCase();
          final cat = (row.category ?? '').toLowerCase();
          return name.contains(query) || code.contains(query) || cat.contains(query);
        }

        return true;
      }).toList(),
    );
  }

  // ============================================================
  // COMPUTED STATS
  // ============================================================

  int get totalItems => rows.length;

  int get totalMovements => rows.fold(0, (sum, r) => sum + r.movements.toInt());

  int get lowStockCount => rows.where((r) => r.isLowStock).length;

  int get outOfStockCount => rows.where((r) => r.isOutOfStock).length;

  // ============================================================
  // EXPORT PDF REPORT
  // ============================================================

  Future<void> exportReportPdf() async {
    try {
      final pdf = pw.Document();

      final String fromStr = _formatDateUI(fromDate.value);
      final String toStr = _formatDateUI(toDate.value);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
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
                        pw.Text('STOCK IN & OUT REPORT',
                            style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900)),
                        pw.SizedBox(height: 2),
                        pw.Text('Period: $fromStr – $toStr'),
                      ],
                    ),
                    pw.Text('Total Items: ${rows.length}'),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(
                  headers: [
                    'Item',
                    'Code',
                    'Opening',
                    'Stock In',
                    'Stock Out',
                    'Closing',
                    'Min Stock',
                    'Status'
                  ],
                  data: rows.map((r) {
                    return [
                      r.articleName,
                      r.articleNumber,
                      '${_formatNum(r.opening)} ${r.unitCode}',
                      '${_formatNum(r.qtyIn)} ${r.unitCode}',
                      '${_formatNum(r.qtyOut)} ${r.unitCode}',
                      '${_formatNum(r.closing)} ${r.unitCode}',
                      '${_formatNum(r.minStock)}',
                      r.status.toUpperCase(),
                    ];
                  }).toList(),
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
        filename: 'Stock_Report_${fromStr.replaceAll('.', '')}_$toStr.pdf',
      );
    } catch (e) {
      debugPrint('Export Stock Report PDF Error: $e');
      AppSnackbar.error(
        title: 'Error',
        message: 'Unable to export PDF report.',
      );
    }
  }

  // ============================================================
  // FORMATTING HELPERS
  // ============================================================

  String _formatDateApi(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateUI(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  String _formatNum(double num) {
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    return num.toStringAsFixed(2);
  }
}