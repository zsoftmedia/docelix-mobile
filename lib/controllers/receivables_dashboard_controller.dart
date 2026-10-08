import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/receivables_dashboard_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceivablesDashboardController extends GetxController {
  final DioClient dioClient = DioClient();

  // ============================================================
  // LOADING
  // ============================================================

  RxBool isLoading = false.obs;

  // ============================================================
  // DASHBOARD DATA
  // ============================================================

  Rx<ReceivablesDashboardModel?> receivablesDashboard =
  Rx<ReceivablesDashboardModel?>(null);

  // ============================================================
  // DATE VALUES
  // These are used for API request
  // ============================================================

  Rx<DateTime> fromDate = DateTime(
    DateTime.now().year,
    1,
    1,
  ).obs;

  Rx<DateTime> toDate = DateTime(
    DateTime.now().year,
    12,
    31,
  ).obs;

  // ============================================================
  // DATE TEXT
  // These are used for UI
  // ============================================================

  RxString fromDateText = ''.obs;
  RxString toDateText = ''.obs;

  // ============================================================
  // ON INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    // Set initial date text
    fromDateText.value = formatDateForDisplay(
      fromDate.value,
    );

    toDateText.value = formatDateForDisplay(
      toDate.value,
    );

    // Load dashboard
    getReceivablesDashboard();
  }

  // ============================================================
  // GET RECEIVABLES DASHBOARD
  // ============================================================

  Future<void> getReceivablesDashboard() async {
    try {
      isLoading.value = true;

      // ----------------------------------------------------------
      // COMPANY ID
      // ----------------------------------------------------------

      final companyId =
          int.tryParse(
            SessionManager.accessCompanyid.toString(),
          ) ??
              0;

      // ----------------------------------------------------------
      // ACCESS TOKEN
      // ----------------------------------------------------------

      final accessToken =
          SessionManager.accessToken ?? '';

      // ----------------------------------------------------------
      // VALIDATION
      // ----------------------------------------------------------

      if (companyId == 0) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID not found.',
        );

        return;
      }

      if (accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Access token not found.',
        );

        return;
      }

      // ----------------------------------------------------------
      // API DATE FORMAT
      // YYYY-MM-DD
      // ----------------------------------------------------------

      final String from =
      formatDateForApi(fromDate.value);

      final String to =
      formatDateForApi(toDate.value);

      print('======================================');
      print('Receivables Dashboard API');
      print('Company ID: $companyId');
      print('From: $from');
      print('To: $to');
      print('======================================');

      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response =
      await dioClient.getReceivablesDashboard(
        companyId: companyId,
        from: from,
        to: to,
        accessToken: accessToken,
      );

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      if (response.statusCode == 200) {
        receivablesDashboard.value =
            ReceivablesDashboardModel.fromJson(
              response.data,
            );

        print(
          'Receivables Dashboard Response: ${response.data}',
        );
      } else {
        AppSnackbar.error(
          title: 'Error',
          message:
          'Unable to load receivables dashboard.',
        );
      }
    } catch (e) {
      print(
        'getReceivablesDashboard Error: $e',
      );

      AppSnackbar.error(
        title: 'Error',
        message:
        'Something went wrong while loading receivables.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // SELECT FROM DATE
  // ============================================================

  Future<void> selectFromDate() async {
    final DateTime? pickedDate =
    await showDatePicker(
      context: Get.context!,
      initialDate: fromDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select From Date',
    );

    if (pickedDate == null) {
      return;
    }

    // ----------------------------------------------------------
    // VALIDATE AGAINST TO DATE
    // ----------------------------------------------------------

    if (pickedDate.isAfter(toDate.value)) {
      AppSnackbar.error(
        title: 'Invalid Date',
        message:
        'From date cannot be after the To date.',
      );

      return;
    }

    // ----------------------------------------------------------
    // UPDATE DATE
    // ----------------------------------------------------------

    fromDate.value = pickedDate;

    fromDateText.value =
        formatDateForDisplay(pickedDate);

    // ----------------------------------------------------------
    // REFRESH API
    // ----------------------------------------------------------

    await getReceivablesDashboard();
  }

  // ============================================================
  // SELECT TO DATE
  // ============================================================

  Future<void> selectToDate() async {
    final DateTime? pickedDate =
    await showDatePicker(
      context: Get.context!,
      initialDate: toDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select To Date',
    );

    if (pickedDate == null) {
      return;
    }

    // ----------------------------------------------------------
    // VALIDATE AGAINST FROM DATE
    // ----------------------------------------------------------

    if (pickedDate.isBefore(fromDate.value)) {
      AppSnackbar.error(
        title: 'Invalid Date',
        message:
        'To date cannot be before the From date.',
      );

      return;
    }

    // ----------------------------------------------------------
    // UPDATE DATE
    // ----------------------------------------------------------

    toDate.value = pickedDate;

    toDateText.value =
        formatDateForDisplay(pickedDate);

    // ----------------------------------------------------------
    // REFRESH API
    // ----------------------------------------------------------

    await getReceivablesDashboard();
  }

  // ============================================================
  // FORMAT DATE FOR API
  // Example:
  // 2026-01-01
  // ============================================================

  String formatDateForApi(DateTime date) {
    final String year =
    date.year.toString().padLeft(4, '0');

    final String month =
    date.month.toString().padLeft(2, '0');

    final String day =
    date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // ============================================================
  // FORMAT DATE FOR UI
  // Example:
  // Jan 01, 2026
  // ============================================================

  String formatDateForDisplay(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} '
        '${date.day.toString().padLeft(2, '0')}, '
        '${date.year}';
  }

  // ============================================================
  // FORMAT AMOUNT
  // ============================================================

  String formatAmount(double amount) {
    return '€${amount.toStringAsFixed(2)}';
  }
}