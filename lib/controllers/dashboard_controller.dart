import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/models/dashboard_model.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


class DashboardController extends GetxController {

  final dioClient = DioClient();
  final isLoading = false.obs;

  final dashboardData = Rxn<DashboardModel>();
  @override
  void onInit() {
    super.onInit();
    getDashboard();
  }

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
      print("Dashboard API Error: ${e.message}");
      if (e.response != null) {
        print("Status Code: ${e.response?.statusCode}");
        print("Response: ${e.response?.data}");
      }
    } catch (e) {
      print("Dashboard Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

}