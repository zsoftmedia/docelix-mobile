import 'package:dio/dio.dart';
import 'package:docelix_mobileapp/components/app_snackbar.dart';
import 'package:docelix_mobileapp/models/asset_model.dart';
import 'package:docelix_mobileapp/models/bank_transactions_model.dart';
import 'package:docelix_mobileapp/services/dio_client.dart';
import 'package:docelix_mobileapp/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BankTransactionsController extends GetxController {
  final DioClient _dioClient = DioClient();
  final TextEditingController searchController = TextEditingController();

  // MAIN TABS: 0 -> Bank Statements, 1 -> Bank Transactions
  final RxInt selectedTabIndex = 0.obs;

  static const tabs = <String>[
    'Bank Statements',
    'Bank Transactions',
  ];

  void selectTab(int index) {
    selectedTabIndex.value = index;
  }

  // ============================================================
  // TAB 1: BANK STATEMENTS STATE & API
  // ============================================================

  final RxList<BankStatementItem> statements = <BankStatementItem>[].obs;
  final RxBool isLoadingStatements = false.obs;
  final RxInt statementsPage = 1.obs;
  final RxInt totalStatementsCount = 0.obs;

  List<BankStatementItem> get filteredStatements {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return statements;
    return statements.where((item) {
      final name = item.fileName.toLowerCase();
      final status = item.displayStatus.toLowerCase();
      final period = item.periodText.toLowerCase();
      return name.contains(query) || status.contains(query) || period.contains(query);
    }).toList();
  }

  Future<void> fetchStatements() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty || companyId == null || companyId == 0) {
      return;
    }

    try {
      isLoadingStatements.value = true;
      final response = await _dioClient.getBankStatements(
        companyId: companyId,
        accessToken: accessToken,
        page: statementsPage.value,
        limit: 20,
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = BankStatementsResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        statements.assignAll(parsed.items);
        totalStatementsCount.value = parsed.total;
      }
    } catch (e) {
      debugPrint('[BankTransactionsController] fetchStatements Error: $e');
    } finally {
      isLoadingStatements.value = false;
    }
  }

  // ============================================================
  // TAB 2: BANK TRANSACTIONS STATE & API
  // ============================================================

  final RxList<BankTransactionItem> transactions = <BankTransactionItem>[].obs;
  final RxBool isLoadingTransactions = false.obs;
  final RxInt transactionsPage = 1.obs;
  final RxInt totalTransactionsCount = 0.obs;

  final RxString searchQuery = ''.obs;

  List<BankTransactionItem> get filteredTransactions {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return transactions;
    return transactions.where((item) {
      final text = item.bookingText.toLowerCase();
      final counter = (item.counterpartyName ?? '').toLowerCase();
      final iban = (item.counterpartyIban ?? '').toLowerCase();
      final ref = (item.reference ?? '').toLowerCase();
      final date = item.bookingDate.toLowerCase();
      final bank = (item.bankAccount?.bankName ?? '').toLowerCase();
      return text.contains(query) ||
          counter.contains(query) ||
          iban.contains(query) ||
          ref.contains(query) ||
          date.contains(query) ||
          bank.contains(query);
    }).toList();
  }

  Future<void> fetchTransactions() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty || companyId == null || companyId == 0) {
      return;
    }

    try {
      isLoadingTransactions.value = true;
      final response = await _dioClient.getBankTransactions(
        companyId: companyId,
        accessToken: accessToken,
        page: transactionsPage.value,
        limit: 20,
        sort: 'booking_date',
        dir: 'desc',
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = BankTransactionsResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        transactions.assignAll(parsed.items);
        totalTransactionsCount.value = parsed.total;
      }
    } catch (e) {
      debugPrint('[BankTransactionsController] fetchTransactions Error: $e');
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  // ============================================================
  // RECONCILE / CATEGORIZE TRANSACTION STATE & API
  // ============================================================

  final RxList<LedgerAccount> ledgerAccounts = <LedgerAccount>[].obs;
  final RxBool isLoadingAccounts = false.obs;
  final Rxn<LedgerAccount> selectedCounterAccount = Rxn<LedgerAccount>();
  final TextEditingController memoController = TextEditingController();
  final RxBool isSubmittingReconcile = false.obs;

  Future<void> fetchLedgerAccounts() async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty || companyId == null || companyId == 0) {
      return;
    }

    try {
      isLoadingAccounts.value = true;
      final response = await _dioClient.getLedgerAccounts(
        companyId: companyId,
        accessToken: accessToken,
      );

      final data = response.data;
      List<dynamic>? rawItems;
      if (data is List) {
        rawItems = data;
      } else if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['items'] is List) {
          rawItems = map['items'] as List;
        } else if (map['accounts'] is List) {
          rawItems = map['accounts'] as List;
        }
      }

      if (rawItems != null) {
        final parsed = rawItems
            .whereType<Map>()
            .map((item) => LedgerAccount.fromJson(Map<String, dynamic>.from(item)))
            .where((acc) => acc.id > 0)
            .toList()
          ..sort((a, b) => a.code.compareTo(b.code));

        ledgerAccounts.assignAll(parsed);
        if (ledgerAccounts.isNotEmpty && selectedCounterAccount.value == null) {
          selectedCounterAccount.value = ledgerAccounts.first;
        }
      }
    } catch (e) {
      debugPrint('[BankTransactionsController] fetchLedgerAccounts Error: $e');
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  void clearReconcileForm() {
    memoController.clear();
    if (ledgerAccounts.isNotEmpty) {
      selectedCounterAccount.value = ledgerAccounts.first;
    } else {
      selectedCounterAccount.value = null;
    }
  }

  Future<void> postAndMatchTransaction(BankTransactionItem transaction, BuildContext context) async {
    final accessToken = SessionManager.accessToken;
    final companyId = SessionManager.accessCompanyid;

    if (accessToken == null || accessToken.isEmpty || companyId == null || companyId == 0) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Access token or company ID is not available.',
      );
      return;
    }

    final counterAccount = selectedCounterAccount.value;
    if (counterAccount == null || counterAccount.id <= 0) {
      AppSnackbar.error(
        title: 'Validation Error',
        message: 'Please select a counter account.',
      );
      return;
    }

    try {
      isSubmittingReconcile.value = true;

      final response = await _dioClient.matchBankTransaction(
        transactionId: transaction.id,
        companyId: companyId,
        counterAccountId: counterAccount.id,
        note: memoController.text,
        accessToken: accessToken,
      );

      final data = response.data;
      String successMessage = 'Bank transaction reconciled and journal entry posted.';
      if (data is Map) {
        if (data['message'] != null && data['message'].toString().trim().isNotEmpty) {
          successMessage = data['message'].toString();
        }
      }

      AppSnackbar.success(
        title: 'Success',
        message: successMessage,
      );

      clearReconcileForm();
      fetchTransactions();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      String errText = 'Failed to reconcile bank transaction.';
      final resData = e.response?.data;
      if (resData is Map) {
        final msg = resData['message'] ?? resData['error'] ?? resData['detail'];
        if (msg != null && msg.toString().trim().isNotEmpty) {
          errText = msg.toString();
        }
      }
      AppSnackbar.error(
        title: 'Error',
        message: errText,
      );
    } catch (e) {
      AppSnackbar.error(
        title: 'Error',
        message: 'Failed to reconcile bank transaction.',
      );
    } finally {
      isSubmittingReconcile.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchStatements();
    fetchTransactions();
    fetchLedgerAccounts();
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  String formatCurrency(num amount, String? currCode) {
    final code = (currCode ?? 'EUR').toUpperCase();
    final symbol = code == 'EUR' ? '€' : code;
    final absAmount = amount.abs();
    final formatter = NumberFormat('#,##0.00');
    final formattedStr = '$symbol${formatter.format(absAmount)}';
    return amount < 0 ? '-$formattedStr' : '+$formattedStr';
  }

  String formatDateUI(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    try {
      final parsed = DateTime.parse(raw);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    memoController.dispose();
    super.onClose();
  }
}