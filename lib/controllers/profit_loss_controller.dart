import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/dashboard_model.dart';
import 'package:docelix_mobileapp/models/profit_loss_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProfitLossController extends GetxController {
  final DioClient _dioClient = DioClient();

  final RxBool isLoading = false.obs;
  final Rxn<ProfitLossModel> reportData = Rxn<ProfitLossModel>();
  final Rxn<DashboardModel> accountingData = Rxn<DashboardModel>();

  // Period Selection
  final RxString selectedPeriod = 'this_month'.obs;
  final RxBool compareLastYear = false.obs;

  static const periodOptions = <MapEntry<String, String>>[
    MapEntry('this_month', 'This Month'),
    MapEntry('previous_month', 'Previous Month'),
    MapEntry('this_quarter', 'This Quarter'),
    MapEntry('previous_quarter', 'Previous Quarter'),
    MapEntry('fy_current', 'Fy Current'),
    MapEntry('fy_previous', 'Fy Previous'),
    MapEntry('custom', 'Custom range'),
  ];

  late Rx<DateTime> fromDate;
  late Rx<DateTime> toDate;

  String get fromDateText => DateFormat('dd.MM.yyyy').format(fromDate.value);
  String get toDateText => DateFormat('dd.MM.yyyy').format(toDate.value);
  String get periodHeaderLabel => '${DateFormat('dd MMM yyyy').format(fromDate.value)} – ${DateFormat('dd MMM yyyy').format(toDate.value)}';

  String get companyName => accountingData.value?.company?.name ?? SessionManager.accessCompanyname ?? 'Company';

  String get currencySymbol {
    final code = accountingData.value?.company?.currencyCode ?? SessionManager.accessCorrencycode ?? 'EUR';
    switch (code.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'PKR':
        return 'Rs.';
      default:
        return code;
    }
  }

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    toDate = now.obs;
    fromDate = DateTime(now.year, now.month, 1).obs;
    fetchReport();
  }

  void selectPeriod(String periodKey) {
    selectedPeriod.value = periodKey;
    final now = DateTime.now();

    switch (periodKey) {
      case 'this_month':
        fromDate.value = DateTime(now.year, now.month, 1);
        toDate.value = now;
        break;

      case 'previous_month':
        final prevMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayPrevMonth = DateTime(now.year, now.month, 0);
        fromDate.value = prevMonth;
        toDate.value = lastDayPrevMonth;
        break;

      case 'this_quarter':
        final startMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        fromDate.value = DateTime(now.year, startMonth, 1);
        toDate.value = now;
        break;

      case 'previous_quarter':
        final currentQuarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final prevQuarterStartMonth = currentQuarterStartMonth - 3;
        fromDate.value = DateTime(now.year, prevQuarterStartMonth, 1);
        toDate.value = DateTime(now.year, currentQuarterStartMonth, 0);
        break;

      case 'fy_current':
        fromDate.value = DateTime(now.year, 1, 1);
        toDate.value = DateTime(now.year, 12, 31);
        break;

      case 'fy_previous':
        fromDate.value = DateTime(now.year - 1, 1, 1);
        toDate.value = DateTime(now.year - 1, 12, 31);
        break;

      case 'custom':
        break;

      default:
        fromDate.value = DateTime(now.year, now.month, 1);
        toDate.value = now;
        break;
    }

    if (periodKey != 'custom') {
      fetchReport();
    }
  }

  Future<void> selectFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(2020),
      lastDate: toDate.value,
    );
    if (picked != null) {
      selectedPeriod.value = 'custom';
      fromDate.value = picked;
      fetchReport();
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value,
      firstDate: fromDate.value,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      selectedPeriod.value = 'custom';
      toDate.value = picked;
      fetchReport();
    }
  }

  void toggleCompareLastYear(bool val) {
    compareLastYear.value = val;
  }

  void resetFilters() {
    selectedPeriod.value = 'this_month';
    compareLastYear.value = false;
    final now = DateTime.now();
    toDate.value = now;
    fromDate.value = DateTime(now.year, now.month, 1);
    fetchReport();
  }

  Future<void> fetchReport() async {
    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (token == null || token.isEmpty || companyId == null || companyId == 0) {
      return;
    }

    try {
      isLoading.value = true;

      final fromStr = DateFormat('yyyy-MM-dd').format(fromDate.value);
      final toStr = DateFormat('yyyy-MM-dd').format(toDate.value);

      final prevFromStr = DateFormat('yyyy-MM-dd').format(
        DateTime(fromDate.value.year - 1, fromDate.value.month, fromDate.value.day),
      );
      final prevToStr = DateFormat('yyyy-MM-dd').format(
        DateTime(toDate.value.year - 1, toDate.value.month, toDate.value.day),
      );

      final responses = await Future.wait([
        _dioClient.getProfitLossReport(
          companyId: companyId,
          fromDate: fromStr,
          toDate: toStr,
          accessToken: token,
        ),
        _dioClient.getDashboardAccounting(
          companyId: companyId,
          from: fromStr,
          to: toStr,
          compareFrom: prevFromStr,
          compareTo: prevToStr,
          groupBy: 'month',
          accessToken: token,
        ),
      ]);

      if (responses[0].statusCode == 200 && responses[0].data != null) {
        reportData.value = ProfitLossModel.fromJson(Map<String, dynamic>.from(responses[0].data as Map));
      }

      if (responses[1].statusCode == 200 && responses[1].data != null) {
        accountingData.value = DashboardModel.fromJson(Map<String, dynamic>.from(responses[1].data as Map));
      }
    } on DioException catch (e) {
      debugPrint('[ProfitLossController] DioError: ${e.message}');
      AppSnackbar.error(title: 'Error', message: 'Unable to load Profit & Loss report.');
    } catch (e) {
      debugPrint('[ProfitLossController] Exception: $e');
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Calculated Metrics
  double get totalRevenue => reportData.value?.revenue.total ?? 0.0;
  double get totalExpenses => reportData.value?.expenses.total ?? 0.0;
  double get netProfit => reportData.value?.netIncome ?? (totalRevenue - totalExpenses);

  double get netMargin {
    if (totalRevenue <= 0) return 100.0;
    return ((netProfit / totalRevenue) * 100);
  }

  double get expenseRatio {
    if (totalRevenue <= 0) return 0.0;
    return ((totalExpenses / totalRevenue) * 100);
  }

  String formatCurrency(num amount) {
    final value = amount.toDouble();
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '$currencySymbol $integerPart.${parts[1]}';
  }
}