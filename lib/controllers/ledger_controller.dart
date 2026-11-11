import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/ledger_account_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LedgerController extends GetxController {
  final DioClient _dioClient = DioClient();

  final RxInt selectedTabIndex = 0.obs;

  static const tabs = <String>[
    'Ledger & Quick Expense Entry',
    'General Ledger',
    'Journal Entries',
    'Bank Transactions',
    'KFZ-Steuerrechner',
  ];

  // ACCOUNTS LIST STATE
  final RxList<LedgerAccountModel> accounts = <LedgerAccountModel>[].obs;
  final RxList<LedgerAccountModel> filteredAccounts = <LedgerAccountModel>[].obs;
  final RxBool isLoading = false.obs;

  // FILTERS STATE
  final RxString searchQuery = ''.obs;
  final RxString selectedAccountType = 'All types'.obs;
  final RxString selectedStatus = 'All statuses'.obs;

  static const accountTypeOptions = <String>[
    'All types',
    'Asset',
    'Liability',
    'Equity',
    'Revenue',
    'Expense',
  ];

  static const statusOptions = <String>[
    'All statuses',
    'Active',
    'Inactive',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void selectAccountType(String type) {
    selectedAccountType.value = type;
    applyFilters();
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
    applyFilters();
  }

  void applyFilters() {
    List<LedgerAccountModel> list = accounts;

    // 1. Account Type Filter
    final typeOpt = selectedAccountType.value.toLowerCase().trim();
    if (typeOpt != 'all types') {
      list = list.where((a) => a.accountType.toLowerCase().trim() == typeOpt).toList();
    }

    // 2. Status Filter
    final statusOpt = selectedStatus.value.toLowerCase().trim();
    if (statusOpt == 'active') {
      list = list.where((a) => a.isActive).toList();
    } else if (statusOpt == 'inactive') {
      list = list.where((a) => !a.isActive).toList();
    }

    // 3. Real-time Search Filter (code, name, subhead, main_head)
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((a) {
        final code = a.code.toLowerCase();
        final name = a.name.toLowerCase();
        final subhead = (a.subhead ?? '').toLowerCase();
        final mainHead = (a.mainHead ?? '').toLowerCase();

        return code.contains(query) ||
            name.contains(query) ||
            subhead.contains(query) ||
            mainHead.contains(query);
      }).toList();
    }

    filteredAccounts.assignAll(list);
  }

  Future<void> fetchAccounts() async {
    final token = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (token == null || token.isEmpty || companyId == null || companyId == 0) {
      return;
    }

    try {
      isLoading.value = true;
      final response = await _dioClient.getLedgerAccounts(
        companyId: companyId,
        accessToken: token,
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> bodyMap = Map<String, dynamic>.from(response.data as Map);
        final rawItems = bodyMap['items'] as List<dynamic>? ?? [];

        final parsed = rawItems
            .whereType<Map>()
            .map((e) => LedgerAccountModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        accounts.assignAll(parsed);
        applyFilters();
      }
    } on DioException catch (e) {
      debugPrint('[LedgerController] DioError: ${e.message}');
      AppSnackbar.error(title: 'Error', message: 'Unable to load ledger accounts.');
    } catch (e) {
      debugPrint('[LedgerController] Exception: $e');
      AppSnackbar.error(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAccounts() async {
    await fetchAccounts();
  }
}