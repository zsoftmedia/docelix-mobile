import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/transaction_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ============================================================
// JOURNAL GROUP MODEL (FOR EXPANDABLE DETAILS CARD)
// ============================================================

class JournalGroupModel {
  final int journalEntryId;
  final int sourceId;
  final String sourceType;
  final String entryDate;
  final String description;
  final String status;
  final List<TransactionItemModel> lines;
  final RxBool isExpanded;

  JournalGroupModel({
    required this.journalEntryId,
    required this.sourceId,
    required this.sourceType,
    required this.entryDate,
    required this.description,
    required this.status,
    required this.lines,
    bool initiallyExpanded = false,
  }) : isExpanded = initiallyExpanded.obs;

  double get totalDebit => lines.fold(0.0, (sum, line) => sum + line.debit);
  double get totalCredit => lines.fold(0.0, (sum, line) => sum + line.credit);

  double get displayAmount {
    if (totalDebit > 0) return totalDebit;
    if (totalCredit > 0) return totalCredit;
    return 0.0;
  }
}

class TransactionController extends GetxController {
  final DioClient dioClient = DioClient();

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  final RxList<TransactionItemModel> transactions = <TransactionItemModel>[].obs;
  final RxList<TransactionItemModel> filteredTransactions = <TransactionItemModel>[].obs;

  final RxList<JournalGroupModel> journalGroups = <JournalGroupModel>[].obs;
  final RxList<JournalGroupModel> filteredGroups = <JournalGroupModel>[].obs;

  final Rx<TransactionModel> ledger = TransactionModel().obs;
  final RxInt totalTransactions = 0.obs;

  final Rx<DateTime> fromDate = DateTime(2025, 12, 31).obs;
  final Rx<DateTime> toDate = DateTime(2026, 12, 30).obs;

  @override
  void onInit() {
    super.onInit();
    getGeneralLedger();
  }

  String formatApiDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String get fromDateText => formatApiDate(fromDate.value);
  String get toDateText => formatApiDate(toDate.value);

  Future<void> selectFromDate() async {
    final DateTime? selected = await showDatePicker(
      context: Get.context!,
      initialDate: fromDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    if (selected.isAfter(toDate.value)) {
      AppSnackbar.error(
        title: 'Invalid Date',
        message: 'From date cannot be after To date.',
      );
      return;
    }

    fromDate.value = selected;
    await getGeneralLedger();
  }

  Future<void> selectToDate() async {
    final DateTime? selected = await showDatePicker(
      context: Get.context!,
      initialDate: toDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) return;

    if (selected.isBefore(fromDate.value)) {
      AppSnackbar.error(
        title: 'Invalid Date',
        message: 'To date cannot be before From date.',
      );
      return;
    }

    toDate.value = selected;
    await getGeneralLedger();
  }

  Map<String, String> parseDateParts(String dateStr) {
    if (dateStr.trim().isEmpty) {
      return {'day': '--', 'month': '---', 'year': '----'};
    }

    try {
      final parsed = DateTime.parse(dateStr);
      final months = [
        'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
        'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
      ];

      return {
        'day': parsed.day.toString().padLeft(2, '0'),
        'month': months[parsed.month - 1],
        'year': parsed.year.toString(),
      };
    } catch (_) {
      return {'day': '--', 'month': '---', 'year': '----'};
    }
  }

  void buildJournalGroups(List<TransactionItemModel> items) {
    final Map<String, List<TransactionItemModel>> map = {};

    for (final item in items) {
      final String key = (item.journalEntryId != 0)
          ? 'entry_${item.journalEntryId}'
          : 'date_${item.entryDate}_${item.sourceType}_${item.sourceId}_${item.description}';

      map.putIfAbsent(key, () => []).add(item);
    }

    final List<JournalGroupModel> groups = [];

    map.forEach((key, lineList) {
      final first = lineList.first;

      groups.add(
        JournalGroupModel(
          journalEntryId: first.journalEntryId,
          sourceId: first.sourceId,
          sourceType: first.sourceType,
          entryDate: first.entryDate,
          description: first.description.isNotEmpty
              ? first.description
              : (first.lineDescription.isNotEmpty ? first.lineDescription : 'Journal Entry'),
          status: first.status.isNotEmpty ? first.status : 'posted',
          lines: lineList,
        ),
      );
    });

    journalGroups.assignAll(groups);
    filteredGroups.assignAll(groups);
  }

  Future<void> getGeneralLedger() async {
    try {
      isLoading.value = true;

      final accessToken = SessionManager.accessToken;
      final companyId = SessionManager.accessCompanyid;

      if (accessToken == null || accessToken.isEmpty) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Access token is not available.',
        );
        return;
      }

      if (companyId == null) {
        AppSnackbar.error(
          title: 'Error',
          message: 'Company ID is not available.',
        );
        return;
      }

      final int companyIdInt = int.parse(companyId.toString());

      final String from = formatApiDate(fromDate.value);
      final String to = formatApiDate(toDate.value);

      final response = await dioClient.getGeneralLedger(
        companyId: companyIdInt,
        fromDate: from,
        toDate: to,
        accessToken: accessToken,
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(response.data);

        final TransactionModel result = TransactionModel.fromJson(data);

        ledger.value = result;
        transactions.assignAll(result.transactions);
        filteredTransactions.assignAll(result.transactions);

        buildJournalGroups(result.transactions);
        totalTransactions.value = journalGroups.length;
      } else {
        transactions.clear();
        filteredTransactions.clear();
        journalGroups.clear();
        filteredGroups.clear();
        totalTransactions.value = 0;
      }
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.response?.data?['message']?.toString() ??
            e.message ??
            'Unable to load transactions.',
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTransactions() async {
    await getGeneralLedger();
  }

  void searchTransactions(String value) {
    searchQuery.value = value;
    final String query = value.trim().toLowerCase();

    if (query.isEmpty) {
      filteredTransactions.assignAll(transactions);
      filteredGroups.assignAll(journalGroups);
      return;
    }

    final List<TransactionItemModel> results = transactions.where((transaction) {
      final String entryDate = transaction.entryDate.toLowerCase();
      final String description = transaction.description.toLowerCase();
      final String lineDescription = transaction.lineDescription.toLowerCase();
      final String sourceType = transaction.sourceType.toLowerCase();
      final String status = transaction.status.toLowerCase();
      final String accountCode = transaction.account.code.toLowerCase();
      final String accountName = transaction.account.name.toLowerCase();

      return entryDate.contains(query) ||
          description.contains(query) ||
          lineDescription.contains(query) ||
          sourceType.contains(query) ||
          status.contains(query) ||
          accountCode.contains(query) ||
          accountName.contains(query);
    }).toList();

    filteredTransactions.assignAll(results);

    final List<JournalGroupModel> groupResults = journalGroups.where((group) {
      final String date = group.entryDate.toLowerCase();
      final String desc = group.description.toLowerCase();
      final String source = group.sourceType.toLowerCase();
      final String journalId = group.journalEntryId.toString();
      final String refId = group.sourceId.toString();

      final bool matchLines = group.lines.any((line) =>
          line.account.name.toLowerCase().contains(query) ||
          line.account.code.toLowerCase().contains(query) ||
          line.lineDescription.toLowerCase().contains(query));

      return date.contains(query) ||
          desc.contains(query) ||
          source.contains(query) ||
          journalId.contains(query) ||
          refId.contains(query) ||
          matchLines;
    }).toList();

    filteredGroups.assignAll(groupResults);
  }

  void openSearch() {
    isSearching.value = true;
    searchQuery.value = '';
    filteredTransactions.assignAll(transactions);
    filteredGroups.assignAll(journalGroups);
  }

  void closeSearch() {
    isSearching.value = false;
    searchQuery.value = '';
    filteredTransactions.assignAll(transactions);
    filteredGroups.assignAll(journalGroups);
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

  String formatCurrency(num? amount, String? currencyCode) {
    final double value = (amount ?? 0).toDouble();
    final String symbol = getCurrencySymbol(currencyCode);

    final parts = value.toStringAsFixed(2).split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts[1];

    final String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    return '$symbol$formattedInteger.$decimalPart';
  }
}