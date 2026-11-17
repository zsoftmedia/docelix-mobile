import 'package:docelix_mobileapp/models/general_ledger_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class JournalEntriesController extends GetxController {
  final DioClient _dioClient = DioClient();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxList<JournalEntryItem> journalEntries = <JournalEntryItem>[].obs;
  final RxInt currentPage = 1.obs;
  final RxInt limit = 20.obs;
  final RxInt totalJournalEntriesCount = 0.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJournalEntries();
  }

  List<JournalEntryItem> get filteredJournalEntries {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return journalEntries;
    return journalEntries.where((item) {
      final desc = item.description.toLowerCase();
      final date = item.entryDate.toLowerCase();
      final status = item.paymentStatusLabel.toLowerCase();
      final recon = (item.reconciliation?.documentNumber ?? '').toLowerCase();
      final linesDesc = item.lines.map((l) => l.description.toLowerCase()).join(' ');
      final accNames = item.lines.map((l) => (l.account?.name ?? '').toLowerCase()).join(' ');
      final accCodes = item.lines.map((l) => (l.account?.code ?? '').toLowerCase()).join(' ');
      return desc.contains(query) ||
          date.contains(query) ||
          status.contains(query) ||
          recon.contains(query) ||
          linesDesc.contains(query) ||
          accNames.contains(query) ||
          accCodes.contains(query);
    }).toList();
  }

  double get totalPageDebit {
    double sum = 0.0;
    for (final item in filteredJournalEntries) {
      sum += item.totalDebit;
    }
    return sum;
  }

  double get totalPageCredit {
    double sum = 0.0;
    for (final item in filteredJournalEntries) {
      sum += item.totalCredit;
    }
    return sum;
  }

  bool get isBalanced => (totalPageDebit - totalPageCredit).abs() < 0.01;

  String get currencySymbol {
    final code = SessionManager.accessCorrencycode?.trim().toUpperCase() ?? 'EUR';
    switch (code) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'PKR':
        return 'Rs ';
      default:
        return '€';
    }
  }

  String formatMoney(num value) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(value)}';
  }

  Future<void> fetchJournalEntries() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty || companyId == null || companyId == 0) {
      return;
    }

    try {
      isLoading.value = true;
      final response = await _dioClient.getJournalEntries(
        companyId: companyId,
        accessToken: accessToken,
        page: currentPage.value,
        limit: limit.value,
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = JournalEntriesResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        journalEntries.assignAll(parsed.items);
        totalJournalEntriesCount.value = parsed.total;
      }
    } catch (e) {
      debugPrint('[JournalEntriesController] fetchJournalEntries Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}