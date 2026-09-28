import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/company_model.dart';
import 'package:docelix_mobileapp/models/dashboard_model.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:intl/intl.dart';


class DashboardController extends GetxController {

  final dioClient = DioClient();
  final isLoading = false.obs;
  final isCompaniesLoading = false.obs;

  final dashboardData = Rxn<DashboardModel>();
  // Companies
  final companies = <CompanyModel>[].obs;
  final selectedCompany = Rxn<CompanyModel>();

  // Selected month
  final selectedDate = DateTime.now().obs;

  // Display month
  String get selectedMonthText {
    return DateFormat('MMMM yyyy').format(selectedDate.value);
  }

  /*@override
  void onInit() {
    super.onInit();
    getDashboard();
    getCompanies();
  }*/

  @override
  void onInit() {
    super.onInit();

    getCompanies();
  }

  // Open month picker
  Future<void> selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked == null) return;

    selectedDate.value = DateTime(
      picked.year,
      picked.month,
      1,
    );

    await getDashboard();
  }


  // ============================================================
  // GET COMPANIES
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

        // --------------------------------------------------------
        // Select company from SessionManager if available
        // --------------------------------------------------------

        final sessionCompanyId =
            SessionManager.accessCompanyid;

        if (sessionCompanyId != null) {

          final company = companies.firstWhereOrNull(
                (company) => company.id == sessionCompanyId,
          );

          if (company != null) {
            selectedCompany.value = company;
          }
        }

        // --------------------------------------------------------
        // If no company is selected, select first company
        // --------------------------------------------------------

        if (selectedCompany.value == null &&
            companies.isNotEmpty) {

          selectedCompany.value = companies.first;

          await selectCompany(
            companies.first,
            loadDashboard: false,
          );
        }

        // --------------------------------------------------------
        // Load dashboard
        // --------------------------------------------------------

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
  // SELECT COMPANY
  // ============================================================

  Future<void> selectCompany(
      CompanyModel company, {
        bool loadDashboard = true,
      }) async
  {

    selectedCompany.value = company;

    // Save selected company ID
    await SessionManager.saveCompanyid(company.id);
    //SessionManager.accessCompanyid = company.id;

    print("Selected company: ${company.name}");
    print("Selected company ID: ${company.id}");

    if (loadDashboard) {
      await getDashboard();
    }
  }

  // ============================================================
  // GET DASHBOARD
  // ============================================================

  Future<void> getDashboard() async {
    try {
      isLoading.value = true;
      // Get values from SessionManager
      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;
      if (accessToken == null || accessToken.isEmpty) {
        print("Access token not found"); return;
      }
      if (companyId == null)
      {
        print("Company ID not found");
        return;
      }
      final response = await dioClient.getDashboardAccounting(
        companyId: companyId,
        from: '2026-08-31',
        to: '2026-09-29',
        compareFrom: '2026-07-31',
        compareTo: '2026-08-30',
        groupBy: 'month',
        accessToken: accessToken,
      );
      if (response.statusCode == 200) {
        dashboardData.value = DashboardModel.fromJson(response.data);
        final dateString = dashboardData.value?.period?.from;

        print("Dashboard loaded successfully");
        print( "Revenue: " "${dashboardData.value?.kpis?.revenue?.value}", );
        print( "Expenses: " "${dashboardData.value?.kpis?.expenses?.value}", );
        print( "Net Result: " "${dashboardData.value?.kpis?.netResult?.value}", );
        print( "Cash Balance: " "${dashboardData.value?.kpis?.cashBalance?.value}",
        );
      }
    } on DioException catch (e) {

      AppSnackbar.error(
        title: 'Error',
        message:e.toString(),
      );

      print("Dashboard API Error: ${e.message}");
      if (e.response != null) {
        print("Status Code: ${e.response?.statusCode}");
        print("Response: ${e.response?.data}");

        AppSnackbar.error(
          title: 'Error',
          message:'${e.response?.data}',
        );

      }
    } catch (e) {
      print("Dashboard Error: $e");

      AppSnackbar.error(
        title: 'Error',
        message:'${e}',
      );

    } finally {
      isLoading.value = false;
    }
  }

}