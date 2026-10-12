import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/models/general_ledger_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GeneralLedgerController extends GetxController {
  final DioClient _dioClient = DioClient();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingAccounts = false.obs;
  final Rxn<GeneralLedgerReport> report = Rxn<GeneralLedgerReport>();
  final RxList<LedgerAccount> accounts = <LedgerAccount>[].obs;
  final RxList<GeneralLedgerEntryGroup> entries =
      <GeneralLedgerEntryGroup>[].obs;

  final RxnInt selectedAccountId = RxnInt();
  final RxnString selectedSourceType = RxnString();
  final RxString searchQuery = ''.obs;
  final Rx<DateTime> fromDate = DateTime.now().obs;
  final Rx<DateTime> toDate = DateTime.now().obs;
  final RxnInt highlightedJournalId = RxnInt();
  final RxnInt selectedJournalId = RxnInt();
  final RxBool isSearching = false.obs;
  final RxSet<int> expandedJournalIds = <int>{}.obs;

  static const sourceTypeOptions = <MapEntry<String, String>>[
    MapEntry('', 'All Sources'),
    MapEntry('asset_purchase', 'Asset Purchase'),
    MapEntry('asset_depreciation', 'Asset Depreciation'),
    MapEntry('asset_disposal', 'Asset Disposal'),
    MapEntry('invoice_issue', 'Invoice Issue'),
    MapEntry('invoice_payment', 'Invoice Payment'),
    MapEntry('incoming_invoice_expense_unpaid', 'Incoming Invoice'),
    MapEntry('bank_transaction', 'Bank Tx'),
    MapEntry('cash_transaction', 'Cash Tx'),
  ];

  String get currencyCode {
    return SessionManager.accessCorrencycode?.trim().toUpperCase() ?? 'EUR';
  }

  String get currencySymbol {
    switch (currencyCode) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'PKR':
        return 'Rs ';
      default:
        return '$currencyCode ';
    }
  }

  double get openingBalance => report.value?.openingBalance ?? 0;
  double get totalDebit => report.value?.totals.debit ?? 0;
  double get totalCredit => report.value?.totals.credit ?? 0;
  double get closingBalance => report.value?.totals.closingBalance ?? 0;
  int get totalEntries => report.value?.pagination.total ?? entries.length;

  String get fromDateText => DateFormat('dd/MM/yyyy').format(fromDate.value);
  String get toDateText => DateFormat('dd/MM/yyyy').format(toDate.value);

  bool get hasActiveFilters =>
      selectedAccountId.value != null ||
      (selectedSourceType.value != null &&
          selectedSourceType.value!.isNotEmpty) ||
      searchQuery.value.trim().isNotEmpty;

  void openSearch() => isSearching.value = true;

  void closeSearch() {
    isSearching.value = false;
    if (searchQuery.value.isNotEmpty || searchController.text.isNotEmpty) {
      searchController.clear();
      searchQuery.value = '';
      loadReport();
    }
  }

  void toggleExpanded(int journalEntryId) {
    if (expandedJournalIds.contains(journalEntryId)) {
      expandedJournalIds.remove(journalEntryId);
    } else {
      expandedJournalIds.add(journalEntryId);
    }
    expandedJournalIds.refresh();
  }

  bool isExpanded(int journalEntryId) =>
      expandedJournalIds.contains(journalEntryId);

  Map<String, String> parseDateParts(String? raw) {
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    if (parsed == null) {
      return {'day': '--', 'month': '---', 'year': '----'};
    }
    return {
      'day': DateFormat('dd').format(parsed),
      'month': DateFormat('MMM').format(parsed).toUpperCase(),
      'year': DateFormat('yyyy').format(parsed),
    };
  }

  @override
  void onInit() {
    super.onInit();
    _applyArguments(Get.arguments);
    loadAccounts();
    loadReport();
  }

  void _applyArguments(dynamic args) {
    final now = DateTime.now();
    fromDate.value = DateTime(now.year - 1, 12, 31);
    toDate.value = DateTime(now.year, 12, 30);

    if (args is! Map) return;

    final map = Map<String, dynamic>.from(args);
    final journalId = map['journalEntryId'];
    if (journalId is int) {
      highlightedJournalId.value = journalId;
      selectedJournalId.value = journalId;
    }

    final sourceType = map['sourceType']?.toString();
    if (sourceType != null && sourceType.isNotEmpty) {
      selectedSourceType.value = sourceType;
    }

    final from = map['fromDate']?.toString();
    final to = map['toDate']?.toString();
    if (from != null) {
      final parsed = DateTime.tryParse(from);
      if (parsed != null) fromDate.value = parsed;
    }
    if (to != null) {
      final parsed = DateTime.tryParse(to);
      if (parsed != null) toDate.value = parsed;
    }

    final accountId = map['accountId'];
    if (accountId is int) selectedAccountId.value = accountId;
  }

  Future<void> loadAccounts() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;
    if (accessToken == null || companyId == null) return;

    try {
      isLoadingAccounts.value = true;
      final response = await _dioClient.getLedgerAccounts(
        companyId: companyId,
        accessToken: accessToken,
      );
      accounts.assignAll(_parseAccounts(response.data));
    } catch (_) {
      // Optional filter data.
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  Future<void> loadReport() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Access token is not available.',
      );
      return;
    }
    if (companyId == null || companyId == 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Company ID is not available.',
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _dioClient.getGeneralLedger(
        companyId: companyId,
        accessToken: accessToken,
        fromDate: DateFormat('yyyy-MM-dd').format(fromDate.value),
        toDate: DateFormat('yyyy-MM-dd').format(toDate.value),
        accountId: selectedAccountId.value,
        search: searchQuery.value,
        sourceType: selectedSourceType.value,
      );

      final data = response.data;
      if (data is! Map) {
        throw Exception('Unexpected response format');
      }

      final parsed = GeneralLedgerReport.fromJson(
        Map<String, dynamic>.from(data),
      );
      report.value = parsed;
      entries.assignAll(parsed.groupedEntries);

      if (highlightedJournalId.value != null) {
        final exists = entries.any(
          (e) => e.journalEntryId == highlightedJournalId.value,
        );
        if (exists) {
          selectedJournalId.value = highlightedJournalId.value;
        }
      }
    } on DioException catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: _errorMessage(e, 'Failed to load general ledger.'),
      );
    } catch (_) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to load general ledger.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applySearch(String value) {
    searchQuery.value = value;
    loadReport();
  }

  void setAccountFilter(int? accountId) {
    selectedAccountId.value = accountId;
    loadReport();
  }

  void setSourceTypeFilter(String? sourceType) {
    selectedSourceType.value =
        (sourceType == null || sourceType.isEmpty) ? null : sourceType;
    loadReport();
  }

  Future<void> pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      fromDate.value = picked;
      loadReport();
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      toDate.value = picked;
      loadReport();
    }
  }

  void selectEntry(GeneralLedgerEntryGroup entry) {
    selectedJournalId.value = entry.journalEntryId;
  }

  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedAccountId.value = null;
    selectedSourceType.value = null;
    final now = DateTime.now();
    fromDate.value = DateTime(now.year - 1, 12, 31);
    toDate.value = DateTime(now.year, 12, 30);
    loadReport();
  }

  String formatMoney(num value) {
    final formatter = NumberFormat('#,##0.00');
    return '$currencySymbol${formatter.format(value)}';
  }

  String formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy').format(parsed);
  }

  String formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd/MM/yyyy, HH:mm').format(parsed.toLocal());
  }

  String formatCardDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd\nMMM\nyyyy').format(parsed).toUpperCase();
  }

  String accountFilterLabel() {
    final id = selectedAccountId.value;
    if (id == null) return 'All Accounts';
    for (final account in accounts) {
      if (account.id == id) return account.displayLabel;
    }
    return 'Account #$id';
  }

  String sourceTypeFilterLabel() {
    final value = selectedSourceType.value;
    if (value == null || value.isEmpty) return 'All Sources';
    for (final option in sourceTypeOptions) {
      if (option.key == value) return option.value;
    }
    return value.replaceAll('_', ' ');
  }

  List<LedgerAccount> _parseAccounts(dynamic data) {
    List<dynamic>? rawItems;
    if (data is List) {
      rawItems = data;
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['items'] is List) {
        rawItems = map['items'] as List;
      } else if (map['data'] is List) {
        rawItems = map['data'] as List;
      } else if (map['accounts'] is List) {
        rawItems = map['accounts'] as List;
      }
    }
    if (rawItems == null) return [];
    return rawItems
        .whereType<Map>()
        .map((item) => LedgerAccount.fromJson(Map<String, dynamic>.from(item)))
        .where((account) => account.id > 0)
        .toList()
      ..sort((a, b) => a.code.compareTo(b.code));
  }

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    return fallback;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
