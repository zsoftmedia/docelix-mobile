import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/company_model.dart';
import 'package:docelix_mobileapp/models/dashboard_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  final dioClient = DioClient();
  final isLoading = false.obs;
  final isCompaniesLoading = false.obs;

  final dashboardData = Rxn<DashboardModel>();
  final companies = <CompanyModel>[].obs;
  final selectedCompany = Rxn<CompanyModel>();

  // ============================================================
  // DATE RANGE SELECTION
  // ============================================================

  late Rx<DateTime> fromDate;
  late Rx<DateTime> toDate;

  // Display date formatting
  String get fromDateText => DateFormat('dd MMM yyyy').format(fromDate.value);
  String get toDateText => DateFormat('dd MMM yyyy').format(toDate.value);

  @override
  void onInit() {
    super.onInit();

    final now = DateTime.now();
    toDate = now.obs;
    fromDate = DateTime(now.year,now.month - 1, now.day).obs;

    getCompanies();
  }

  // Select From Date
  Future<void> selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: fromDate.value,
      firstDate: DateTime(2020),
      lastDate: toDate.value,
    );

    if (picked == null) return;

    fromDate.value = picked;
    await getDashboard();
  }

  // Select To Date
  Future<void> selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: toDate.value,
      firstDate: fromDate.value,
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    toDate.value = picked;
    await getDashboard();
  }

  // ============================================================
  // GET COMPANIES & INITIALIZE COMPANY ID
  // ============================================================

  Future<void> getCompanies() async {
    try {
      isCompaniesLoading.value = true;

      final accessToken = SessionManager.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        print("Access token not found");
        return;
      }

      final response = await dioClient.getCompanies(
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        companies.value = data
            .map(
              (json) => CompanyModel.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList();

        print("Companies loaded: ${companies.length}");

        final sessionCompanyId = SessionManager.accessCompanyid;

        if (sessionCompanyId != null) {
          final company = companies.firstWhereOrNull(
            (company) => company.id == sessionCompanyId,
          );

          if (company != null) {
            selectedCompany.value = company;
          }
        }

        if (selectedCompany.value == null && companies.isNotEmpty) {
          selectedCompany.value = companies.first;

          await selectCompany(
            companies.first,
            loadDashboard: false,
          );
        }

        await getDashboard();
      }
    } on DioException catch (e) {
      print("Companies API Error: ${e.message}");

      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?.toString() ??
            e.message ??
            'Unable to load companies',
      );
    } catch (e) {
      print("Companies Error: $e");

      AppSnackbar.error(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isCompaniesLoading.value = false;
    }
  }

  // ============================================================
  // DYNAMICALLY SELECT COMPANY
  // ============================================================

  Future<void> selectCompany(
    CompanyModel company, {
    bool loadDashboard = true,
  }) async {
    selectedCompany.value = company;

    // Save dynamic Company ID, Name & Currency to SessionManager
    await SessionManager.saveCompanyid(company.id);
    await SessionManager.saveCompanyname(company.name);

    print("Selected Company Name: ${company.name}");
    print("Selected Company ID: ${company.id}");

    if (loadDashboard) {
      await getDashboard();
    }
  }

  // ============================================================
  // GET DASHBOARD BY DYNAMIC COMPANY ID & DATE RANGE
  // ============================================================

  Future<void> getDashboard() async {
    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;
      final int? companyId =
          selectedCompany.value?.id ?? SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        print("Access token not found");
        return;
      }
      if (companyId == null) {
        print("Company ID not found");
        return;
      }

      final fromStr = DateFormat('yyyy-MM-dd').format(fromDate.value);
      final toStr = DateFormat('yyyy-MM-dd').format(toDate.value);

      final prevMonthFrom = DateTime(
        fromDate.value.year,
        fromDate.value.month - 1,
        fromDate.value.day,
      );
      final prevMonthTo = fromDate.value.subtract(const Duration(days: 1));

      final compareFromStr = DateFormat('yyyy-MM-dd').format(prevMonthFrom);
      final compareToStr = DateFormat('yyyy-MM-dd').format(prevMonthTo);

      print("Loading Dashboard for Company ID: $companyId, Date Range: $fromStr to $toStr");

      final response = await dioClient.getDashboardAccounting(
        companyId: companyId,
        from: fromStr,
        to: toStr,
        compareFrom: compareFromStr,
        compareTo: compareToStr,
        groupBy: 'month',
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        dashboardData.value = DashboardModel.fromJson(response.data);

        print("Dashboard loaded successfully for Company ID $companyId");
        print("Revenue: ${dashboardData.value?.kpis?.revenue?.value}");
        print("Expenses: ${dashboardData.value?.kpis?.expenses?.value}");
        print("Net Result: ${dashboardData.value?.kpis?.netResult?.value}");
        print("Cash Balance: ${dashboardData.value?.kpis?.cashBalance?.value}");
      }
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?.toString() ??
            e.message ??
            'Unable to load dashboard',
      );
      print("Dashboard API Error: ${e.message}");
    } catch (e) {
      print("Dashboard Error: $e");

      AppSnackbar.error(
        title: 'Error',
        message: '$e',
      );
    } finally {
      isLoading.value = false;
    }
  }
}